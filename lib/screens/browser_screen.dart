import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' show ImageFilter;
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/glass_container.dart';
// import 'package:scribocracy_new/widgets/background_scaffold.dart'; // Non utilisé ici
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
import 'package:scribocracy_new/services/dark_mode_service.dart';

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
  bool _isDownloadMenuOpen = false;
  bool _isBottomBarHidden = false;

  // DONNÉES LIVE
  Map<String, dynamic>? _weatherData;
  bool _isCurrentPageFavorite = false;

  bool get _anyOverlayOpen => _isMenuOpen || _isTabSwitcherOpen;

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

  // Helper pour savoir si on est sur un moteur de recherche
  bool _isSearchEngine(String url) {
    if (url.isEmpty) return false;
    return url.contains('google.') ||
        url.contains('bing.com') ||
        url.contains('duckduckgo.com');
  }

  // --- LOGIQUE TÉLÉCHARGEMENT ---
  void _showDownloadOption(String imageUrl) {
    if (_isDownloadMenuOpen) return;
    setState(() => _isDownloadMenuOpen = true);
    HapticFeedback.mediumImpact();

    // On récupère le thème actuel pour le menu contextuel
    final isDark = ref.read(darkModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GlassContainer(
        blur: 10,
        opacity: 0.6,
        // Adaptation du fond du menu contextuel
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Enregistrer cette image ?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Playfair Display',
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(color: AppTheme.greyText),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.habanero,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Téléchargement en cours..."),
                            duration: Duration(milliseconds: 1000),
                          ),
                        );
                        bool success = await DownloadService()
                            .downloadImageToGallery(imageUrl);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Image enregistrée !"
                                    : "Erreur téléchargement",
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          );
                        }
                      },
                      child: const Text("Enregistrer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() => _isDownloadMenuOpen = false);
    });
  }

  // --- LOGIQUE ONGLETS ---
  void _addNewTab() {
    final newController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'ImageDownloader',
        onMessageReceived: (message) => _showDownloadOption(message.message),
      )
      ..addJavaScriptChannel(
        'ImageDownloader',
        onMessageReceived: (message) => _showDownloadOption(message.message),
      )
      ..addJavaScriptChannel(
        'ScrollListener',
        onMessageReceived: (message) {
          // 1. VÉRIFICATION MOTEUR DE RECHERCHE
          // Si on est sur Google/Bing/DDG, on force la barre visible et on arrête là.
          if (_isSearchEngine(_tabs[_currentTabIndex].url)) {
            if (_isBottomBarHidden) {
              setState(() => _isBottomBarHidden = false);
            }
            return;
          }

          // 2. LOGIQUE DE SCROLL NORMALE
          final direction = message.message;
          if (direction == 'down' && !_isBottomBarHidden) {
            setState(() => _isBottomBarHidden = true);
          } else if (direction == 'up' && _isBottomBarHidden) {
            setState(() => _isBottomBarHidden = false);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            final uri = Uri.parse(url);
            if (url.toLowerCase().endsWith('.pdf')) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            if (!url.startsWith('http://') && !url.startsWith('https://')) {
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  return NavigationDecision.prevent;
                }
              } catch (e) {
                debugPrint("Erreur lien externe: $e");
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            _updateCurrentTab((tab) {
              tab.isLoading = true;
              if (url != 'about:blank') tab.url = url;
            });
            if (_isSearchEngine(url) && _isBottomBarHidden) {
              setState(() => _isBottomBarHidden = false);
            }
            if (!_isTabSwitcherOpen) {
              setState(() {
                if (url != 'about:blank') _urlController.text = url;
              });
              _checkFavoriteStatus(url);
            }
          },
          onPageFinished: (String url) async {
            final isDark = ref.read(darkModeProvider);
            if (isDark) {
              _tabs[_currentTabIndex].controller.runJavaScript(
                DarkModeService.darkThemeScript,
              );
            }
            _tabs[_currentTabIndex].controller.runJavaScript(
              AdBlockService.blockerScript,
            );

            // --- NOUVEAU SCRIPT DE SCROLL INTELLIGENT ---
            // Il introduit une tolérance : il faut remonter de 150px pour déclencher le 'up'
            const scrollScript = """
                var lastScrollTop = 0;
                var upScrollStart = 0; // Point de départ de la remontée
                
                window.addEventListener("scroll", function() {
                   var st = window.pageYOffset || document.documentElement.scrollTop;
                   
                   // A. SCROLL VERS LE BAS
                   if (st > lastScrollTop) {
                       upScrollStart = st; // On reset le compteur de montée
                       // On cache dès qu'on descend un peu (plus de 50px)
                       if (st > 50) { 
                           ScrollListener.postMessage('down');
                       }
                   } 
                   // B. SCROLL VERS LE HAUT
                   else {
                       // On ne déclenche 'up' QUE si on a remonté de plus de 150px
                       // par rapport au point le plus bas atteint (upScrollStart)
                       if (upScrollStart - st > 150) {
                           ScrollListener.postMessage('up');
                       }
                   }
                   lastScrollTop = st <= 0 ? 0 : st;
                }, false);
             """;
            _tabs[_currentTabIndex].controller.runJavaScript(scrollScript);

            String? title;
            try {
              title = await _tabs[_currentTabIndex].controller.getTitle();
            } catch (e) {}
            _updateCurrentTab((tab) {
              tab.isLoading = false;
              tab.title = title ?? "Onglet";
            });
            if (url.startsWith('http')) {
              await ref.read(databaseProvider).recordVisit(url, title ?? "");
              _refreshDashboard();
            }
          },
        ),
      );

    final newTab = BrowserTab(
      id: DateTime.now().toString(),
      controller: newController,
    );
    setState(() {
      _tabs.add(newTab);
      _currentTabIndex = _tabs.length - 1;
      _showDashboard = true;
      _isTabSwitcherOpen = false;
      _urlController.clear();
    });
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
    if (mounted) setState(() => updateFn(_tabs[_currentTabIndex]));
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
        final engine = ref.read(searchEngineProvider);
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
    // CORRECTION : On ne charge que les favoris, pas l'historique complet
    // Assurez-vous que votre databaseService a bien une méthode getFavorites()
    // (C'est celle utilisée par votre écran FavoritesScreen)
    final links = await ref.read(databaseProvider).getFavorites();

    if (mounted) {
      setState(() {
        // On stocke les favoris dans la variable du dashboard
        _dashboardLinks = links;
      });
    }
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

  // --- READER MODE & AI ---
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

  // --- HELPERS VISUELS ---
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

  // =========================================================================
  // ========================== MÉTHODE BUILD ================================
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    // 1. Récupération du thème
    final isDark = ref.watch(darkModeProvider);

    // 2. Définition des couleurs DYNAMIQUES
    final Color appBackground = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final Color pageBackground = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightBackground;

    ref.listen(darkModeProvider, (previous, next) {
      if (next) {
        _activeController.runJavaScript(DarkModeService.darkThemeScript);
      } else {
        _activeController.runJavaScript(DarkModeService.removeDarkThemeScript);
      }
    });

    return Scaffold(
      backgroundColor: appBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. CONTENU PRINCIPAL (RESTORED & FIXED)
          AnimatedScale(
            scale: _anyOverlayOpen ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutQuart,
              decoration: BoxDecoration(
                color: pageBackground,
                borderRadius: BorderRadius.circular(_anyOverlayOpen ? 24 : 0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        // Barre de progression (Loading)
                        if (_tabs[_currentTabIndex].isLoading &&
                            !_showDashboard)
                          const LinearProgressIndicator(
                            value: null,
                            color: AppTheme.primaryBrand,
                            backgroundColor: Colors.transparent,
                            minHeight: 2,
                          ),
                        // La WebView (Libre de scroller !)
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

                  // DASHBOARD
                  AnimatedOpacity(
                    opacity: _showDashboard ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !_showDashboard,
                      child: _buildDashboard(isDark),
                    ),
                  ),

                  // VOILE DIMMING (Focus)
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
                        child: Container(color: Colors.black.withOpacity(0.2)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. BARRE DU BAS (RÉDUITE MAIS VISIBLE)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            // LOGIQUE : On ne cache complètement la barre QUE si un overlay (Menu/Recherche) est ouvert.
            // Si on scroll (_isBottomBarHidden), elle reste à 0 mais changera de forme.
            bottom: _anyOverlayOpen ? -150 : 0,
            child: _buildBottomBar(isDark), // On passe le style
          ),

          // 3. OVERLAYS
          _buildAnimatedOverlay(
            isOpen: _isMenuOpen,
            child: _buildMenuContent(isDark),
          ),
          _buildAnimatedOverlay(
            isOpen: _isTabSwitcherOpen,
            child: _buildTabSwitcherContent(isDark),
          ),
          if (_isSearchMode)
            Positioned.fill(child: _buildSearchOverlay(isDark)),
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

  // --- WIDGETS DÉCOUPÉS AVEC THÈME APPLIQUÉ ---

  // --- DASHBOARD (MODIFIÉ : Titre remonté + Grille Favoris) ---
  Widget _buildDashboard(bool isDark) {
    final Color textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    // On garde bgColor comme couleur de secours si l'image ne charge pas
    final Color bgColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightBackground;

    final favorites = _dashboardLinks.take(8).toList();

    return Container(
      // 1. L'IMAGE DE FOND
      decoration: BoxDecoration(
        color: bgColor, // Couleur de fond (au cas où)
        image: DecorationImage(
          // Remplacez par le chemin de votre image
          image: AssetImage(
            isDark
                ? 'assets/images/dark-gradient-background.png'
                : 'assets/images/light-gradient-background.png',
          ),
          fit: BoxFit.cover, // L'image couvre tout l'écran
        ),
      ),
      child: Stack(
        children: [
          // 2. LE VOILE DE PROTECTION (Overlay)
          // C'est ça qui rend le texte lisible par-dessus n'importe quelle image

          // 3. MÉTÉO (inchangé)
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
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: textColor,
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
                          color: AppTheme
                              .greyText, // On garde le gris, il ressortira grâce au voile
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
          ),

          // 4. CONTENU CENTRAL (inchangé)
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.23,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // TITRE
                    Text(
                      "Scribocracy",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 44,
                        color: textColor,
                        letterSpacing: -1.5,
                        // Optionnel : Une petite ombre portée pour aider la lisibilité
                        shadows: [
                          Shadow(
                            color: isDark ? Colors.black54 : Colors.white54,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // GRILLE FAVORIS
                    if (favorites.isEmpty)
                      Column(
                        children: [
                          Icon(
                            Icons.star_outline_rounded,
                            size: 40,
                            color: AppTheme.greyText.withOpacity(0.8),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Vos favoris apparaîtront ici",
                            style: TextStyle(
                              color: textColor.withOpacity(
                                0.7,
                              ), // Texte un peu plus contrasté
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    else
                      Wrap(
                        spacing: 20,
                        runSpacing: 25,
                        alignment: WrapAlignment.center,
                        children: favorites.map((page) {
                          return _buildDashboardFavoriteItem(
                            page,
                            isDark,
                            textColor,
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER : ITEM DE LA GRILLE FAVORIS ---
  Widget _buildDashboardFavoriteItem(
    WebPage page,
    bool isDark,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: () => _loadUrlOrSearch(page.url),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // L'Icône (Favicon)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18), // Arrondi "Tech"
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
                width: 1,
              ),
              boxShadow: [
                if (!isDark) // Ombre seulement en mode clair
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(12), // Padding interne pour l'image
            child: page.url.isEmpty
                ? Icon(Icons.public, color: textColor.withOpacity(0.5))
                : Image.network(
                    _getFaviconUrl(page.url),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si pas de favicon
                      return Icon(
                        Icons.public,
                        color: textColor.withOpacity(0.2),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 10), // Espace Icône/Texte
          // Le Titre du site
          SizedBox(
            width: 70, // Largeur max pour couper le texte
            child: Text(
              page.title?.trim().isEmpty == true ? "Site" : page.title!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    // Définition palette locale
    final Color glassColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;
    final Color iconColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final Color borderColor = isDark
        ? AppTheme.darkBorder
        : AppTheme.lightBorder;

    // EST-CE QUE LA BARRE EST RÉDUITE ?
    // Elle est réduite si on scroll vers le bas (_isBottomBarHidden) ET qu'on n'est pas sur le dashboard
    final bool isReduced = _isBottomBarHidden && !_showDashboard;

    return SafeArea(
      top: false,
      child: GestureDetector(
        // SI RÉDUIT : Un clic n'importe où sur la barre la ré-ouvre
        onTap: isReduced
            ? () => setState(() => _isBottomBarHidden = false)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // Marge externe : On la colle plus au bord si réduite
          padding: EdgeInsets.symmetric(
            horizontal: isReduced
                ? 120
                : 10, // Plus compacte horizontalement si réduite
            vertical: isReduced ? 7 : 10,
          ),
          child: GlassContainer(
            // Animation des formes
            borderRadius: BorderRadius.circular(isReduced ? 30 : 26),
            blur: 7,
            opacity: 0.6,
            color: glassColor,
            borderColor: borderColor.withOpacity(0.3),
            // Padding interne réduit quand la barre est petite
            padding: EdgeInsets.symmetric(
              vertical: isReduced ? 0 : 3,
              horizontal: isReduced ? 0 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- GROUPE GAUCHE (Retour + Favoris) ---
                _AnimatedWidthWrapper(
                  visible: !isReduced, // Caché si réduit
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: _showDashboard
                              ? iconColor.withOpacity(0.3)
                              : iconColor,
                        ),
                        onPressed: _showDashboard
                            ? null
                            : () async {
                                if (await _activeController.canGoBack())
                                  _activeController.goBack();
                              },
                      ),
                      const SizedBox(width: 12),
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
                                  ? const Color(0xFFFFB703)
                                  : iconColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // --- CENTRE (Barre d'adresse) ---
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isReduced) {
                        // Si réduit, le clic sert d'abord à agrandir la barre
                        setState(() => _isBottomBarHidden = false);
                      } else {
                        // Si déjà grand, on ouvre la recherche
                        _openSearchMode();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isReduced ? 25 : 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        // Si réduit : Fond transparent (pour s'intégrer à la glass bar). Sinon fond normal.
                        color: isReduced
                            ? Colors.transparent
                            : (isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : AppTheme.accentBrand.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centré quand réduit
                        children: [
                          // Cadenas (Disparaît si réduit pour épurer)
                          if (!isReduced) ...[
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: iconColor.withOpacity(0.5),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // URL / Titre
                          Flexible(
                            // Flexible permet au texte de prendre la place sans erreur
                            child: Text(
                              _showDashboard
                                  ? "Rechercher..."
                                  : (_tabs[_currentTabIndex].title.isEmpty
                                        ? "Recherche"
                                        : Uri.tryParse(_urlController.text)
                                                  ?.host
                                                  .replaceFirst('www.', '') ??
                                              _tabs[_currentTabIndex].title),
                              style: TextStyle(
                                color: iconColor.withOpacity(
                                  isReduced ? 1.0 : 0.9,
                                ), // Plus visible si réduit
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Bouton Refresh (Disparaît si réduit)
                          if (!_showDashboard && !isReduced) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (_tabs[_currentTabIndex].isLoading) {
                                  _activeController.reload();
                                } else {
                                  _activeController.reload();
                                }
                              },
                              child: Icon(
                                _tabs[_currentTabIndex].isLoading
                                    ? Icons.close_rounded
                                    : Icons.refresh_rounded,
                                size: 16,
                                color: iconColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // --- GROUPE DROITE (Onglets + Menu) ---
                _AnimatedWidthWrapper(
                  visible: !isReduced, // Caché si réduit
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _toggleTabSwitcher,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: iconColor, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _tabs.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _toggleMenu,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrand,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBrand.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent(bool isDark) {
    final Color bgColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightBackground;
    final Color textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final Color cardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(color: textColor),
                    ),
                    GestureDetector(
                      onTap: _toggleMenu,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : AppTheme.asterBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: textColor, size: 24),
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
                      const _MenuSectionTitle(
                        title: "INTELLIGENCE ARTIFICIELLE",
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _AIActionButton(
                            icon: Icons.flash_on_rounded,
                            label: "Résumé",
                            color: Colors.amber[800]!,
                            textColor: textColor,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, "Résumé concis.");
                            },
                          ),
                          _AIActionButton(
                            icon: Icons.format_list_bulleted_rounded,
                            label: "Points Clés",
                            color: AppTheme.asterBlue,
                            textColor: textColor,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, "Points clés.");
                            },
                          ),
                          _AIActionButton(
                            icon: Icons.translate_rounded,
                            label: "Traduire",
                            color: Colors.purple[300]!,
                            textColor: textColor,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, "Traduis en FR.");
                            },
                          ),
                          _AIActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: "Discussion",
                            color: Colors.teal,
                            textColor: textColor,
                            onTap: () async {
                              final c = await _getPageContent();
                              _launchAIChat(c, null);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const _MenuSectionTitle(title: "NAVIGATION"),
                      const SizedBox(height: 15),
                      _MenuTile(
                        icon: Icons.bookmarks_outlined,
                        title: "Mes Favoris",
                        bgColor: cardColor,
                        textColor: textColor,
                        onTap: () async {
                          setState(() => _isMenuOpen = false);
                          bool linkSelected = false;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FavoritesScreen(
                                onUrlSelected: (url) {
                                  linkSelected = true;
                                  _loadUrlOrSearch(url);
                                },
                              ),
                            ),
                          );
                          if (!linkSelected && mounted)
                            setState(() => _isMenuOpen = true);
                        },
                      ),
                      _MenuTile(
                        icon: Icons.history,
                        title: "Historique",
                        bgColor: cardColor,
                        textColor: textColor,
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
                          if (!linkSelected && mounted)
                            setState(() => _isMenuOpen = true);
                        },
                      ),
                      const SizedBox(height: 40),
                      const _MenuSectionTitle(title: "OUTILS"),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.chrome_reader_mode_outlined,
                        title: "Mode Lecture Zen",
                        bgColor: cardColor,
                        textColor: textColor,
                        onTap: _openReaderMode,
                      ),
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        title: "Paramètres",
                        bgColor: cardColor,
                        textColor: textColor,
                        onTap: () {
                          setState(() => _isMenuOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
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

  Widget _buildTabSwitcherContent(bool isDark) {
    final Color glassColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final Color textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final Color cardColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;

    return GlassContainer(
      blur: 7,
      opacity: 0.6, // Très opaque
      color: glassColor,
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
                    ).textTheme.displayLarge?.copyWith(color: textColor),
                  ),
                  GestureDetector(
                    onTap: _toggleTabSwitcher,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: textColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: glassColor,
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
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? Border.all(color: AppTheme.habanero, width: 3)
                            : Border.all(
                                color: textColor.withOpacity(0.1),
                                width: 1,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
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
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _closeTab(index),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black26
                                    : Colors.grey[200], // Placeholder
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.public,
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
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

  Widget _buildSearchOverlay(bool isDark) {
    final Color bgColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final Color textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final Color hintColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: GlassContainer(
            blur: 7 * value,
            opacity: 0.6 * value, // Fond opaque pour bien lire
            borderRadius: BorderRadius.zero,
            hasShadow: false,
            color: bgColor,
            child: child!,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          color: textColor.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: textColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: AppTheme.habanero,
                      selectionColor: AppTheme.asterBlue.withOpacity(0.3),
                      selectionHandleColor: AppTheme.habanero,
                    ),
                  ),
                  child: TextField(
                    controller: _urlController,
                    focusNode: _searchFocusNode,
                    onSubmitted: _loadUrlOrSearch,
                    onChanged: _onSearchTextChanged,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.2,
                      letterSpacing: -0.5,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "What's on your mind ?",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontFamily: 'Playfair Display',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.only(
                        top: 30,
                        bottom: 20,
                      ),
                    ),
                  ),
                ),
              ),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: AppTheme.asterBlue.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          page.title ?? page.url,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          page.url,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            color: AppTheme.greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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

// --- WIDGETS AUXILIAIRES ADAPTÉS ---

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
  final Color bgColor;
  final Color textColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
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
  final Color textColor;
  final VoidCallback onTap;

  const _AIActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
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
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// Petit helper pour animer la disparition des icônes
class _AnimatedWidthWrapper extends StatelessWidget {
  final bool visible;
  final Widget child;

  const _AnimatedWidthWrapper({required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: visible ? null : 0, // Si pas visible, largeur 0
        child: visible
            ? child
            : const SizedBox(), // Si pas visible, rien ne s'affiche
      ),
    );
  }
}
