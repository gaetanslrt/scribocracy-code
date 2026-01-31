import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/background_scaffold.dart';
import 'package:scribocracy_new/widgets/glass_container.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/models/web_page.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  final Function(String) onUrlSelected;

  const FavoritesScreen({super.key, required this.onUrlSelected});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<WebPage> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // On appelle la nouvelle méthode stricte
    final data = await ref.read(databaseProvider).getFavorites();
    if (mounted) {
      setState(() {
        _favorites = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(WebPage page) async {
    await ref.read(databaseProvider).toggleFavorite(page.url);
    _loadFavorites(); // Recharger la liste
  }

  // Helper Favicon
  String _getFaviconUrl(String url) {
    if (url.isEmpty) return "";
    try {
      final uri = Uri.parse(url);
      String domain = uri.host;
      if (domain.isEmpty) domain = url;
      return "https://www.google.com/s2/favicons?domain=$domain&sz=128";
    } catch (e) { return ""; }
  }

  IconData _getIconForUrl(String url) {
    if (url.contains('google')) return Icons.search;
    if (url.contains('youtube')) return Icons.play_arrow_rounded;
    return Icons.public;
  }
  
  Color _getColorForUrl(String url) => url.contains('youtube') ? Colors.redAccent : AppTheme.asterBlue;

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text("Mes Favoris", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
        centerTitle: false,
      ),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.habanero))
        : _favorites.isEmpty 
          ? Center(child: Text("Aucun favori épinglé.", style: Theme.of(context).textTheme.bodyMedium))
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 colonnes de carrés
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8, // Un peu plus haut que large pour le texte
              ),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final page = _favorites[index];
                
                return GestureDetector(
                  onTap: () {
                    widget.onUrlSelected(page.url);
                    Navigator.pop(context);
                  },
                  onLongPress: () {
                    // Suppression au long press
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: const Text("Retirer des favoris ?"),
                      actions: [
                        TextButton(child: const Text("Annuler"), onPressed: () => Navigator.pop(ctx)),
                        TextButton(child: const Text("Retirer", style: TextStyle(color: Colors.red)), onPressed: () {
                          _removeFavorite(page);
                          Navigator.pop(ctx);
                        }),
                      ],
                    ));
                  },
                  child: Column(
                    children: [
                      // LE CARRÉ GLASS
                      GlassContainer(
                        width: 60, height: 60, 
                        borderRadius: BorderRadius.circular(18), 
                        opacity: 0.6, hasShadow: false,
                        borderColor: AppTheme.asterBlue.withOpacity(0.2),
                        padding: const EdgeInsets.all(12),
                        child: page.url.isNotEmpty 
                            ? Image.network(
                                _getFaviconUrl(page.url),
                                errorBuilder: (context, error, stackTrace) => Icon(_getIconForUrl(page.url), color: _getColorForUrl(page.url), size: 28),
                              )
                            : Icon(_getIconForUrl(page.url), color: _getColorForUrl(page.url), size: 28)
                      ),
                      const SizedBox(height: 8),
                      // LE TITRE
                      Text(
                        page.title ?? "Site", 
                        textAlign: TextAlign.center, 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis, 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                          height: 1.2
                        )
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}