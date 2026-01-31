import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Assurez-vous d'avoir intl dans pubspec, sinon retirez le formatage complexe
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/background_scaffold.dart';
import 'package:scribocracy_new/widgets/glass_container.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/models/web_page.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final Function(String) onUrlSelected;

  const HistoryScreen({super.key, required this.onUrlSelected});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<WebPage> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await ref.read(databaseProvider).getFullHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int id) async {
    await ref.read(databaseProvider).deletePage(id);
    _loadHistory(); // Recharger après suppression
  }
  
  Future<void> _clearAll() async {
    await ref.read(databaseProvider).clearHistory();
    _loadHistory();
  }

  // Helper pour récupérer le favicon
  String _getFaviconUrl(String url) {
    if (url.isEmpty) return "";
    try {
      final uri = Uri.parse(url);
      String domain = uri.host;
      if (domain.isEmpty) domain = url;
      return "https://www.google.com/s2/favicons?domain=$domain&sz=64";
    } catch (e) { return ""; }
  }

  // Groupe les éléments par date (Aujourd'hui, Hier, etc.)
  Map<String, List<WebPage>> _groupHistory() {
    Map<String, List<WebPage>> grouped = {};
    final now = DateTime.now();
    
    for (var page in _history) {
      final diff = now.difference(page.lastVisited).inDays;
      String label = "Plus tôt";
      
      if (diff == 0 && page.lastVisited.day == now.day) label = "Aujourd'hui";
      else if (diff == 1 || (diff == 0 && page.lastVisited.day != now.day)) label = "Hier";
      
      if (!grouped.containsKey(label)) grouped[label] = [];
      grouped[label]!.add(page);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedHistory = _groupHistory();

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text("Historique", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.habanero),
            onPressed: () {
               // Confirmation dialog avant de tout supprimer
               showDialog(context: context, builder: (ctx) => AlertDialog(
                 title: const Text("Effacer l'historique ?"),
                 content: const Text("Cette action est irréversible."),
                 actions: [
                   TextButton(child: const Text("Annuler"), onPressed: () => Navigator.pop(ctx)),
                   TextButton(child: const Text("Effacer", style: TextStyle(color: Colors.red)), onPressed: () {
                     _clearAll();
                     Navigator.pop(ctx);
                   }),
                 ],
               ));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.habanero))
        : _history.isEmpty 
          ? Center(child: Text("Aucun historique.", style: Theme.of(context).textTheme.bodyMedium))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: groupedHistory.keys.length,
              itemBuilder: (context, index) {
                String key = groupedHistory.keys.elementAt(index);
                List<WebPage> pages = groupedHistory[key]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                      child: Text(key, style: const TextStyle(color: AppTheme.habanero, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                    ),
                    ...pages.map((page) => Dismissible(
                      key: Key(page.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent.withOpacity(0.2),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      onDismissed: (_) => _deleteItem(page.id),
                      child: GestureDetector(
                        onTap: () {
                          widget.onUrlSelected(page.url); // Callback vers le navigateur
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white)
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppTheme.asterBlue.withOpacity(0.1), shape: BoxShape.circle),
                                child: Image.network(
                                  _getFaviconUrl(page.url),
                                  errorBuilder: (c,e,s) => const Icon(Icons.public, color: AppTheme.asterBlue, size: 20),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      page.title ?? "Sans titre",
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.darkText),
                                    ),
                                    Text(
                                      page.url,
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: AppTheme.greyText),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${page.lastVisited.hour}:${page.lastVisited.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontSize: 11, color: Colors.black26),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )).toList()
                  ],
                );
              },
            ),
    );
  }
}