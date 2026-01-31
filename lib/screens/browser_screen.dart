import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' show ImageFilter;
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/glass_container.dart';
import 'package:scribocracy_new/widgets/background_scaffold.dart';
import 'package:scribocracy_new/screens/chat_screen.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/models/web_page.dart';
import 'package:scribocracy_new/models/browser_tab.dart';
import 'package:scribocracy_new/screens/reader_screen.dart';
import 'package:scribocracy_new/screens/favorites_screen.dart';
import 'package:scribocracy_new/screens/history_screen.dart';
import 'package:scribocracy_new/services/weather_service.dart';
import 'package:scribocracy_new/screens/settings_screen.dart';
import 'package:scribocracy_new/services/ad_block_service.dart';
import 'package:scribocracy_new/services/download_service.dart';
import 'package:flutter/services.dart'; // Pour HapticFeedback
import 'package:url_launcher/url_launcher.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  // GESTION DES ONGLETS
  List<BrowserTab> _tabs = [];
  int _currentTabIndex = 0;

  // ÉTATS UI
  bool _showDashboard = true;
  bool _isSearchMode = false;
  bool _isMenuOpen = false;
  bool _isTabSwitcherOpen = false;

  bool _isDownloadMenuOpen = false; // Empêche l'ouverture multiple

  bool _isBottomBarHidden = false; // Pour cacher la barre au scroll

  // DONNÉES LIVE
  Map<String, dynamic>? _weatherData;
  bool _isCurrentPageFavorite = false;

  bool get _anyOverlayOpen => _isMenuOpen || _isTabSwitcherOpen;

      // NOUVEAU GETTER : Pilote uniquement l'animation de recul
  // On ne recule que pour le Menu ou les Onglets. PAS pour la Recherche.
  bool get _shouldRecoil => _isMenuOpen || _isTabSwitcherOpen;

  // Éléments UI Globaux
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<WebPage> _dashboardLinks = [];
  List<WebPage> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
    _addNewTab();

    WeatherService().getCurrentWeather().then((data) {
      if (mounted && data != null) {
        setState(() => _weatherData = data);
      }
    });
  }

void _showDownloadOption(String imageUrl) {
    // SÉCURITÉ : Si déjà ouvert, on ignore les appels suivants
    if (_isDownloadMenuOpen) return;
    
    setState(() => _isDownloadMenuOpen = true); // On verrouille
    
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Pour que le clavier ne cache pas le menu si besoin
      builder: (ctx) => GlassContainer(
        blur: 20,
        opacity: 0.8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Aperçu de l'image
              Container(
                height: 150, // Un peu plus grand pour bien voir
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,5))]
                ),
              ),
              const SizedBox(height: 20),
              const Text("Enregistrer cette image ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display')),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Annuler", style: TextStyle(color: AppTheme.greyText)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.habanero,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder()
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx); 
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Téléchargement en cours..."), duration: Duration(milliseconds: 1000))
                        );
                        
                        // Note: Assurez-vous d'avoir bien importé DownloadService
                        bool success = await DownloadService().downloadImageToGallery(imageUrl);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? "Image enregistrée !" : "Erreur téléchargement"),
                              backgroundColor: success ? Colors.green : Colors.redAccent,
                            )
                          );
                        }
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      // DÉVERROUILLAGE : Quand le menu se ferme (par clic ou retour arrière), on libère le verrou
      setState(() => _isDownloadMenuOpen = false);
    });
  }
  // --- LOGIQUE ONGLETS ---

  void _addNewTab() {
    final newController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      
      // A. CANAUX DE COMMUNICATION (JS -> Flutter)
      ..addJavaScriptChannel(
        'ImageDownloader', // Votre gestionnaire d'images existant
        onMessageReceived: (message) => _showDownloadOption(message.message),
      )
      ..addJavaScriptChannel(
        'ScrollListener', // NOUVEAU : Pour détecter le scroll
        onMessageReceived: (message) {
          final direction = message.message;
          if (direction == 'down' && !_isBottomBarHidden) {
            setState(() => _isBottomBarHidden = true); // On cache en descendant
          } else if (direction == 'up' && _isBottomBarHidden) {
            setState(() => _isBottomBarHidden = false); // On montre en montant
          }
        },
      )
      
      // B. NAVIGATION DELEGATE (Redirections)
      ..setNavigationDelegate(
        NavigationDelegate(
          // NOUVEAU : Interception des liens spéciaux (Apps, Store, Tel, Mail)
          // NOUVEAU : Interception des liens spéciaux (Apps, Store, Tel, Mail)
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            
            // Si c'est du web classique, on laisse passer
            if (url.startsWith('http://') || url.startsWith('https://')) {
              return NavigationDecision.navigate;
            }

            // Sinon (intent://, tel:, mailto:, market://...), on essaie d'ouvrir l'app externe
            try {
              final uri = Uri.parse(url);
              
              // CORRECTION : L'import a été retiré d'ici car il est déjà en haut du fichier
              
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent; // On bloque la navigation dans la WebView
              }
            } catch (e) {
              debugPrint("Erreur ouverture app externe: $e");
            }
            
            // Si on ne sait pas quoi faire, on bloque pour éviter l'écran d'erreur rouge
            return NavigationDecision.prevent;
          },

          onPageStarted: (String url) {
             _updateCurrentTab((tab) { tab.isLoading = true; if (url != 'about:blank') tab.url = url; });
             if (!_isTabSwitcherOpen) {
               setState(() { if (url != 'about:blank') _urlController.text = url; });
               _checkFavoriteStatus(url);
             }
          },
          onPageFinished: (String url) async {
             // 1. Injections existantes (AdBlock + Image Detector)
             _tabs[_currentTabIndex].controller.runJavaScript(AdBlockService.blockerScript);
             // ... (Votre script imageDetector avec le Timer ici) ...
             
             // 2. NOUVEAU : Injection du Détecteur de Scroll
             // Ce script compare la position actuelle avec la précédente pour savoir si on monte ou descend
             const scrollScript = """
                var lastScrollTop = 0;
                window.addEventListener("scroll", function() {
                   var st = window.pageYOffset || document.documentElement.scrollTop;
                   if (st > lastScrollTop && st > 100){
                       ScrollListener.postMessage('down'); // On descend
                   } else {
                       ScrollListener.postMessage('up'); // On monte
                   }
                   lastScrollTop = st <= 0 ? 0 : st;
                }, false);
             """;
             _tabs[_currentTabIndex].controller.runJavaScript(scrollScript);

             // ... Fin du chargement ...
             String? title; 
             try { title = await _tabs[_currentTabIndex].controller.getTitle(); } catch(e){}
             _updateCurrentTab((tab) { tab.isLoading = false; tab.title = title ?? "Onglet"; });
             if (url.startsWith('http')) { 
               await ref.read(databaseProvider).recordVisit(url, title ?? ""); 
               _refreshDashboard(); 
             }
          },
        ),
      ); 

    // ... Création du Tab (inchangé) ...
    final newTab = BrowserTab(id: DateTime.now().toString(), controller: newController);
    setState(() { _tabs.add(newTab); _currentTabIndex = _tabs.length - 1; _showDashboard = true; _isTabSwitcherOpen = false; _urlController.clear(); });
  }

  void _closeTab(int index) {
    if (_tabs.length <= 1) {
      setState(() {
        _tabs[0].controller.loadRequest(Uri.parse('about:blank'));
        _tabs[0].title = "Nouvel onglet";
        _tabs[0].url = "";
        _showDashboard = true;
        _urlController.clear();
        _isCurrentPageFavorite = false;
      });
      return;
    }
    setState(() {
      _tabs.removeAt(index);
      if (_currentTabIndex >= index && _currentTabIndex > 0) _currentTabIndex--;
      _urlController.text = _tabs[_currentTabIndex].url;
      _showDashboard = _tabs[_currentTabIndex].url.isEmpty;
      if (!_showDashboard) _checkFavoriteStatus(_tabs[_currentTabIndex].url);
    });
  }

  void _switchToTab(int index) {
    setState(() {
      _currentTabIndex = index;
      _isTabSwitcherOpen = false;
      _urlController.text = _tabs[index].url;
      _showDashboard = _tabs[index].url.isEmpty;
      if (!_showDashboard) _checkFavoriteStatus(_tabs[index].url);
    });
  }

  void _updateCurrentTab(Function(BrowserTab) updateFn) {
    if (mounted)
      setState(() {
        updateFn(_tabs[_currentTabIndex]);
      });
  }

  WebViewController get _activeController => _tabs[_currentTabIndex].controller;

  // --- LOGIQUE METIER ---

  void _loadUrlOrSearch(String input) {
    if (input.isEmpty) {
      _closeSearchMode();
      return;
    }

    setState(() {
      _showDashboard = false;
      _isSearchMode = false;
      _isMenuOpen = false;
      _suggestions = [];
    });
    _searchFocusNode.unfocus();

    Uri? uri = Uri.tryParse(input);
    bool isUrl = uri != null && uri.hasScheme && uri.host.isNotEmpty;
    _tabs[_currentTabIndex].url = input;

    if (!isUrl) {
      if (input.contains('.') && !input.contains(' ')) {
        _activeController.loadRequest(Uri.parse('https://$input'));
      } else {
        // LOGIQUE DE MOTEUR DE RECHERCHE DYNAMIQUE
        final engine = ref.read(searchEngineProvider); // On lit la préférence
        final query = Uri.encodeComponent(input);

        String searchUrl;
        switch (engine) {
          case 'ddg':
            searchUrl = 'https://duckduckgo.com/?q=$query';
            break;
          case 'bing':
            searchUrl = 'https://www.bing.com/search?q=$query';
            break;
          case 'google':
          default:
            searchUrl = 'https://www.google.com/search?q=$query';
            break;
        }

        _activeController.loadRequest(Uri.parse(searchUrl));
      }
    } else {
      _activeController.loadRequest(uri);
    }
  }

  Future<void> _refreshDashboard() async {
    final links = await ref.read(databaseProvider).getDashboardLinks();
    if (mounted) setState(() => _dashboardLinks = links);
  }

  Future<void> _checkFavoriteStatus(String url) async {
    if (url.isEmpty || url == 'about:blank') {
      if (mounted) setState(() => _isCurrentPageFavorite = false);
      return;
    }
    final isFav = await ref.read(databaseProvider).isFavorite(url);
    if (mounted) setState(() => _isCurrentPageFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    final url = _tabs[_currentTabIndex].url;
    if (url.isEmpty || !url.startsWith('http')) return;

    await ref.read(databaseProvider).toggleFavorite(url);
    await _checkFavoriteStatus(url);
    await _refreshDashboard();
  }

  void _onSearchTextChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final results = await ref.read(databaseProvider).findSuggestions(query);
    setState(() => _suggestions = results);
  }

  // --- READER MODE ---
  Future<void> _openReaderMode() async {
    if (_tabs[_currentTabIndex].url.isEmpty) return;
    try {
      const extractionScript = """
      (function() {
        const candidates = document.querySelectorAll('article, main, .content, .post, .article, .entry-content, body');
        let bestCandidate = document.body;
        let maxScore = 0;
        candidates.forEach(node => {
           const pCount = node.querySelectorAll('p').length;
           let score = pCount;
           if(node.className.includes('article')) score += 5;
           if (score > maxScore) { maxScore = score; bestCandidate = node; }
        });
        return bestCandidate.innerHTML;
      })();
      """;
      final result = await _activeController.runJavaScriptReturningResult(
        extractionScript,
      );
      String htmlContent = result.toString();
      if (htmlContent.startsWith('"') && htmlContent.endsWith('"')) {
        htmlContent = htmlContent
            .substring(1, htmlContent.length - 1)
            .replaceAll('\\"', '"')
            .replaceAll('\\n', '\n')
            .replaceAll('\\u003C', '<');
      }
      if (!mounted) return;
      setState(() => _isMenuOpen = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            title: _tabs[_currentTabIndex].title,
            htmlContent: htmlContent,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mode lecture indisponible ici.")),
      );
    }
  }

  // --- HELPERS ---
  String _getFaviconUrl(String url) {
    if (url.isEmpty) return "";
    try {
      final uri = Uri.parse(url);
      String domain = uri.host.isEmpty ? url : uri.host;
      return "https://www.google.com/s2/favicons?domain=$domain&sz=128";
    } catch (e) {
      return "";
    }
  }

  IconData _getIconForUrl(String url) {
    if (url.contains('google')) return Icons.search;
    if (url.contains('youtube')) return Icons.play_arrow_rounded;
    return Icons.public;
  }

  Color _getColorForUrl(String url) =>
      url.contains('youtube') ? Colors.redAccent : AppTheme.asterBlue;

  // --- CONTROLES UI ---
  void _openSearchMode() {
    setState(() {
      _isSearchMode = true;
      _isMenuOpen = false;
      _suggestions = [];
      _urlController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _urlController.text.length,
      );
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isSearchMode) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearchMode() {
    setState(() => _isSearchMode = false);
    _searchFocusNode.unfocus();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isSearchMode = false;
      if (_isMenuOpen) FocusScope.of(context).unfocus();
    });
  }

  void _toggleTabSwitcher() {
    setState(() {
      _isTabSwitcherOpen = !_isTabSwitcherOpen;
      _isMenuOpen = false;
      _isSearchMode = false;
    });
  }

  Future<String> _getPageContent() async {
    if (_showDashboard) return "";
    try {
      final Object result = await _activeController
          .runJavaScriptReturningResult("document.body.innerText");
      String pageContent = result.toString();
      if (pageContent.startsWith('"') && pageContent.endsWith('"'))
        pageContent = pageContent.substring(1, pageContent.length - 1);
      pageContent = pageContent.replaceAll('\\n', '\n').replaceAll('\\t', ' ');
      if (pageContent.length > 300000)
        pageContent = pageContent.substring(0, 300000);
      return "TITRE: ${_tabs[_currentTabIndex].title}\nURL: ${_urlController.text}\nCONTENU:\n$pageContent";
    } catch (e) {
      return "";
    }
  }

  void _launchAIChat(String content, String? initialPrompt) {
    setState(() => _isMenuOpen = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(systemContext: content, initialInput: initialPrompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. CONTENU
          AnimatedScale(
            scale: _anyOverlayOpen ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuart,
              decoration: BoxDecoration(
                color: AppTheme.lusterWhite,
                borderRadius: BorderRadius.circular(_anyOverlayOpen ? 24 : 0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        if (_tabs[_currentTabIndex].isLoading &&
                            !_showDashboard)
                          LinearProgressIndicator(
                            value: null,
                            color: AppTheme.habanero,
                            backgroundColor: Colors.transparent,
                            minHeight: 2,
                          ),
                        Expanded(
                          child: IndexedStack(
                            index: _currentTabIndex,
                            children: _tabs
                                .map(
                                  (tab) =>
                                      WebViewWidget(controller: tab.controller),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _showDashboard ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_showDashboard,
                      child: _buildDashboard(),
                    ),
                  ),
                  if (_anyOverlayOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMenuOpen = false;
                            _isTabSwitcherOpen = false;
                            _isSearchMode = false;
                          });
                          _searchFocusNode.unfocus();
                        },
                        child: Container(color: Colors.black12),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- 2. BARRE DU BAS (ANIMÉE AU SCROLL) ---
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300), 
            curve: Curves.easeInOut,
            left: 0, 
            right: 0, 
            // LOGIQUE : 
            // Si Overlay ouvert (Menu/Search) -> On cache (-100)
            // Si Scroll vers le bas (_isBottomBarHidden) -> On cache (-100)
            // Sinon -> On affiche (0)
            bottom: (_anyOverlayOpen || _isBottomBarHidden) ? -100 : 0, 
            child: _buildBottomBar(),
          ),

          // 3. OVERLAYS
          _buildAnimatedOverlay(
            isOpen: _isMenuOpen,
            child: _buildMenuContent(),
          ),
          _buildAnimatedOverlay(
            isOpen: _isTabSwitcherOpen,
            child: _buildTabSwitcherContent(),
          ),
          if (_isSearchMode) Positioned.fill(child: _buildSearchOverlay()),
        ],
      ),
    );
  }

  Widget _buildAnimatedOverlay({required bool isOpen, required Widget child}) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuart,
      left: 0,
      right: 0,
      top: isOpen ? 0 : MediaQuery.of(context).size.height,
      bottom: isOpen ? 0 : -MediaQuery.of(context).size.height,
      child: child,
    );
  }

  // --- DASHBOARD ---
  Widget _buildDashboard() {
    return Container(
      color: AppTheme.lusterWhite,
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 24,
            child: _weatherData == null
                ? const SizedBox()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${_weatherData!['temp']}°",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.darkText,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${WeatherService().getWeatherLabel(_weatherData!['code'])}\nParis",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
          ),
          Center(
            child: Text(
              "Scribocracy",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                color: AppTheme.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BARRE DU BAS (MODIFIÉE) ---
  Widget _buildBottomBar() {
    // On utilise SafeArea pour que la barre flotte au dessus du "Home Indicator"
    return SafeArea(
      top: false, // On ne s'occupe que du bas
      child: Padding(
        // Marges externes pour l'effet "Volant" (Gauche/Droite/Bas)
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: GlassContainer(
          // On augmente l'arrondi pour le style "Capsule"
          borderRadius: BorderRadius.circular(26),
          // Un peu plus de flou pour la lisibilité sans fond opaque
          blur: 15,
          opacity: 0.4,
          borderColor: Colors.black12.withOpacity(0.1), // Bordure plus subtile
          // Padding interne réduit pour affiner la barre
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // La barre prend juste la place nécessaire
            children: [
              // 1. BOUTON RETOUR
              IconButton(
                // On réduit légèrement la zone de clic pour compacter
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: _showDashboard ? Colors.black26 : AppTheme.darkText,
                ),
                onPressed: _showDashboard
                    ? null
                    : () async {
                        if (await _activeController.canGoBack())
                          _activeController.goBack();
                      },
              ),

              const SizedBox(width: 12),

              // 2. BOUTON FAVORIS (Collé au retour)
              if (!_showDashboard)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      _isCurrentPageFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 22,
                      color: _isCurrentPageFavorite
                          ? AppTheme.habanero
                          : AppTheme.darkText,
                    ),
                  ),
                ),

              // 3. BARRE DE RECHERCHE (Plus fine)
              Expanded(
                child: GestureDetector(
                  onTap: _openSearchMode,
                  child: Container(
                    height: 36, // HAUTEUR RÉDUITE (était 40)
                    decoration: BoxDecoration(
                      color: AppTheme.asterBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18), // Arrondi ajusté
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 14,
                          color: AppTheme.darkText.withOpacity(0.5),
                        ), // Icône plus petite
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _showDashboard
                                ? "Rechercher..."
                                : (_tabs[_currentTabIndex].title.isEmpty
                                      ? "Recherche"
                                      : Uri.tryParse(
                                              _urlController.text,
                                            )?.host.replaceFirst('www.', '') ??
                                            _tabs[_currentTabIndex].title),
                            style: TextStyle(
                              color: AppTheme.darkText.withOpacity(1),
                              fontSize: 12, // Texte affiné
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 4. COMPTEUR ONGLETS
              GestureDetector(
                onTap: _toggleTabSwitcher,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.darkText, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tabs.length.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 5. BOUTON MENU
              GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  padding: const EdgeInsets.all(8), // Padding réduit
                  decoration: BoxDecoration(
                    color: AppTheme.habanero,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.habanero.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 16,
                  ), // Icône plus petite
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MENU CONTENU (NAVIGATION CORRIGÉE) ---
  Widget _buildMenuContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.lusterWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Menu",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    GestureDetector(
                      onTap: _toggleMenu,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppTheme.darkText,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MenuSectionTitle(title: "INTELLIGENCE ARTIFICIELLE"),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _AIActionButton(
                            icon: Icons.flash_on_rounded,
                            label: "Résumé",
                            color: Colors.amber[800]!,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, "Résumé concis.");
                            },
                          ),
                          _AIActionButton(
                            icon: Icons.format_list_bulleted_rounded,
                            label: "Points Clés",
                            color: AppTheme.asterBlue,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, "Points clés.");
                            },
                          ),
                          _AIActionButton(
                            icon: Icons.translate_rounded,
                            label: "Traduire",
                            color: Colors.purple[300]!,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, "Traduis en FR.");
                            },
                          ),
                          _AIActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: "Discussion",
                            color: Colors.teal,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, null);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      _MenuSectionTitle(title: "NAVIGATION"),
                      const SizedBox(height: 15),

                      // NAVIGATION CORRIGÉE : On utilise await et un flag pour savoir si on doit rouvrir le menu
                      _MenuTile(
                        icon: Icons.bookmarks_outlined,
                        title: "Mes Favoris",
                        onTap: () async {
                          setState(
                            () => _isMenuOpen = false,
                          ); // Ferme visuellement pour la transition
                          bool linkSelected =
                              false; // Flag pour savoir si l'utilisateur a cliqué un lien

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FavoritesScreen(
                                onUrlSelected: (url) {
                                  linkSelected = true;
                                  _loadUrlOrSearch(
                                    url,
                                  ); // Si on charge une URL, on ne rouvre pas le menu
                                },
                              ),
                            ),
                          );

                          // Si on n'a PAS cliqué sur un lien (donc juste fait retour), on rouvre le menu
                          if (!linkSelected && mounted) {
                            setState(() => _isMenuOpen = true);
                          }
                        },
                      ),

                      _MenuTile(
                        icon: Icons.history,
                        title: "Historique",
                        onTap: () async {
                          setState(() => _isMenuOpen = false);
                          bool linkSelected = false;

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryScreen(
                                onUrlSelected: (url) {
                                  linkSelected = true;
                                  _loadUrlOrSearch(url);
                                },
                              ),
                            ),
                          );

                          if (!linkSelected && mounted) {
                            setState(() => _isMenuOpen = true);
                          }
                        },
                      ),

                      const SizedBox(height: 40),
                      _MenuSectionTitle(title: "OUTILS"),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.chrome_reader_mode_outlined,
                        title: "Mode Lecture Zen",
                        onTap: _openReaderMode,
                      ),
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        title: "Paramètres",
                        onTap: () {
                          setState(() => _isMenuOpen = false); // Ferme le menu
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SettingsScreen(), // Ouvre les réglages
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB SWITCHER & SEARCH (INCHANGÉS MAIS INCLUS) ---
  Widget _buildTabSwitcherContent() {
    return GlassContainer(
      blur: 15,
      opacity: 0.4,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Onglets",
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: _toggleTabSwitcher,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.7,
                ),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isActive = index == _currentTabIndex;
                  return GestureDetector(
                    onTap: () => _switchToTab(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.lusterWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? Border.all(color: AppTheme.habanero, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _getFaviconUrl(tab.url),
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: tab.url.isEmpty
                                      ? const Icon(
                                          Icons.public,
                                          size: 12,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tab.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _closeTab(index),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.public,
                                  color: Colors.black12,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: _addNewTab,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.habanero,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.habanero.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Nouvel Onglet",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH OVERLAY (ZEN MODE) ---
  // --- SEARCH OVERLAY (ZEN MODE) ---
  Widget _buildSearchOverlay() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: GlassContainer(
            blur: 7 * value,
            opacity: 0.4 * value,
            borderRadius: BorderRadius.zero,
            hasShadow: false,
            // CORRECTION ICI : Ajout du "!"
            child: child!, 
          ),
        );
      },
      // Ce Scaffold est passé comme "child" au builder ci-dessus pour éviter de le reconstruire à chaque frame
      child: Scaffold( 
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bouton Fermer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _closeSearchMode,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05), 
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.close, color: AppTheme.darkText, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 2. Champ de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: AppTheme.habanero, 
                      selectionColor: AppTheme.asterBlue.withOpacity(0.3), 
                      selectionHandleColor: AppTheme.habanero
                    )
                  ),
                  child: TextField(
                    controller: _urlController, 
                    focusNode: _searchFocusNode, 
                    onSubmitted: _loadUrlOrSearch, 
                    onChanged: _onSearchTextChanged,
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.darkText, 
                      height: 1.2, 
                      letterSpacing: -0.5, 
                      fontFamily: 'Montserrat'
                    ),
                    textAlign: TextAlign.left, 
                    keyboardType: TextInputType.text, 
                    textInputAction: TextInputAction.search, 
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Qu'avez-vous en tête ?", 
                      hintStyle: TextStyle(
                        color: AppTheme.greyText.withOpacity(0.5), 
                        fontFamily: 'Playfair Display', 
                        fontStyle: FontStyle.italic
                      ), 
                      border: InputBorder.none, 
                      focusedBorder: InputBorder.none, 
                      enabledBorder: InputBorder.none, 
                      filled: false, 
                      contentPadding: const EdgeInsets.only(top: 30, bottom: 20)
                    ),
                  ),
                ),
              ),

              // 3. Suggestions
              Expanded(
                child: _suggestions.isEmpty 
                  ? const SizedBox() 
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24), 
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final page = _suggestions[index];
                        return GestureDetector(
                          onTap: () => _loadUrlOrSearch(page.url), 
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0), 
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history, 
                                  color: AppTheme.asterBlue.withOpacity(0.7), 
                                  size: 20
                                ), 
                                const SizedBox(width: 15), 
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      Text(
                                        page.title ?? page.url, 
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis, 
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat', 
                                          fontWeight: FontWeight.w600, 
                                          fontSize: 16, 
                                          color: AppTheme.darkText
                                        )
                                      ), 
                                      Text(
                                        page.url, 
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis, 
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat', 
                                          fontSize: 12, 
                                          color: AppTheme.greyText
                                        )
                                      )
                                    ]
                                  )
                                )
                              ]
                            )
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIAIRES ---
class _MenuSectionTitle extends StatelessWidget {
  final String title;
  const _MenuSectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppTheme.asterBlue,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
      fontFamily: 'Montserrat',
    ),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppTheme.darkText, size: 20),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppTheme.darkText,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.greyText,
          ),
        ],
      ),
    ),
  );
}

class _AIActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AIActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.greyText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
