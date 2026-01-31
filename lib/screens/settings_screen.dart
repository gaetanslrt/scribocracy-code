import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/background_scaffold.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/services/database.dart'; // Pour vider l'historique

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEngine = ref.watch(searchEngineProvider);

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text("Paramètres", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
        centerTitle: false,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1 : MOTEUR DE RECHERCHE
            _SectionTitle(title: "MOTEUR DE RECHERCHE"),
            const SizedBox(height: 15),
            
            // On crée des cartes pour chaque choix
            _EngineCard(
              title: "Google", 
              icon: Icons.search, 
              value: "google", 
              groupValue: currentEngine, 
              onTap: () => ref.read(searchEngineProvider.notifier).state = 'google'
            ),
            _EngineCard(
              title: "DuckDuckGo", 
              icon: Icons.privacy_tip_outlined, 
              value: "ddg", 
              groupValue: currentEngine, 
              onTap: () => ref.read(searchEngineProvider.notifier).state = 'ddg'
            ),
            _EngineCard(
              title: "Bing", 
              icon: Icons.saved_search, 
              value: "bing", 
              groupValue: currentEngine, 
              onTap: () => ref.read(searchEngineProvider.notifier).state = 'bing'
            ),

            const SizedBox(height: 40),

            // SECTION 2 : DONNÉES PRIVÉES
            _SectionTitle(title: "CONFIDENTIALITÉ"),
            const SizedBox(height: 15),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white)
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
                title: const Text("Vider l'historique", style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkText)),
                subtitle: const Text("Supprime tous les sites visités", style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                onTap: () {
                  showDialog(context: context, builder: (ctx) => AlertDialog(
                    title: const Text("Tout effacer ?"),
                    content: const Text("Cette action est irréversible."),
                    actions: [
                      TextButton(child: const Text("Annuler"), onPressed: () => Navigator.pop(ctx)),
                      TextButton(
                        child: const Text("Confirmer", style: TextStyle(color: Colors.red)), 
                        onPressed: () async {
                          // Appel à la base de données
                          await ref.read(databaseProvider).clearHistory();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Historique effacé.")));
                        }
                      ),
                    ],
                  ));
                },
              ),
            ),

            const SizedBox(height: 40),

            // SECTION 3 : À PROPOS
            Center(
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, color: AppTheme.asterBlue, size: 40),
                  const SizedBox(height: 10),
                  Text("Scribocracy", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
                  const Text("Version 1.0 • Éidition Zen", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// PETITS WIDGETS LOCAUX
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(color: AppTheme.asterBlue, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, fontFamily: 'Montserrat'));
}

class _EngineCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const _EngineCard({required this.title, required this.icon, required this.value, required this.groupValue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.habanero.withOpacity(0.05) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.habanero : Colors.transparent,
            width: 2
          )
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.habanero : AppTheme.greyText),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(
              fontWeight: FontWeight.w600, 
              color: isSelected ? AppTheme.darkText : AppTheme.greyText,
              fontFamily: 'Montserrat'
            )),
            const Spacer(),
            if (isSelected) 
              const Icon(Icons.check_circle, color: AppTheme.habanero, size: 20)
          ],
        ),
      ),
    );
  }
}