import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:scribocracy_new/models/note.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/screens/edit.dart';
import 'package:scribocracy_new/theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsyncValue = ref.watch(notesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("SYSTEM_READY", style: TextStyle(fontFamily: 'ShareTechMono', fontSize: 10, color: AppTheme.neonCyan)),
                      Text("SCRIBOCRACY_", style: Theme.of(context).textTheme.displayLarge),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.neonCyan),
                      shape: BoxShape.rectangle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.qr_code_2, color: AppTheme.neonCyan),
                  )
                ],
              ),
              
              const SizedBox(height: 25),
              
              // 2. Search Bar
              TextField(
                cursorColor: AppTheme.neonCyan,
                style: const TextStyle(color: AppTheme.neonCyan, fontFamily: 'ShareTechMono'),
                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                decoration: InputDecoration(
                  hintText: "> SEARCH_PROTOCOL...",
                  prefixIcon: const Icon(Icons.terminal, color: AppTheme.neonCyan),
                  suffixIcon: Icon(Icons.search, color: Colors.grey[800]),
                ),
              ),
              const SizedBox(height: 25),

              // 3. Grille
              Expanded(
                child: notesAsyncValue.when(
                  data: (notes) => notes.isEmpty
                      ? Center(
                          child: Text("> NO_DATA_FOUND_", style: Theme.of(context).textTheme.bodyLarge),
                        )
                      : MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return _CyberCard(note: notes[index], ref: ref);
                          },
                        ),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonCyan)),
                  error: (e, s) => Center(child: Text("SYS_ERR: $e", style: const TextStyle(color: Colors.red))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditScreen())),
        child: const Icon(Icons.add_sharp, size: 30),
      ),
    );
  }
}

class _CyberCard extends StatelessWidget {
  final Note note;
  final WidgetRef ref;

  const _CyberCard({required this.note, required this.ref});

  @override
  Widget build(BuildContext context) {
    final String? coverImage = note.images.isNotEmpty ? note.images.first : null;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(note: note))),
      onLongPress: () {
         showDialog(context: context, builder: (ctx) => AlertDialog(
            backgroundColor: Colors.black,
            shape: const BeveledRectangleBorder(side: BorderSide(color: AppTheme.dangerRed)),
            title: Text("PURGE DATA?", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.dangerRed)),
            actions: [
              TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("ABORT")),
              TextButton(onPressed: (){
                ref.read(databaseProvider).deleteNote(note.id);
                Navigator.pop(ctx);
              }, child: const Text("EXECUTE", style: TextStyle(color: AppTheme.dangerRed))),
            ],
          ));
      },
      child: Container(
        decoration: ShapeDecoration(
          color: AppTheme.carbon,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), 
              bottomRight: Radius.circular(15)
            ),
            side: BorderSide(color: Colors.white10, width: 1),
          ),
          shadows: [
            BoxShadow(color: AppTheme.neonCyan.withOpacity(0.05), blurRadius: 10, spreadRadius: 0)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            if (coverImage != null)
              ClipPath(
                clipper: ShapeBorderClipper(
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15))
                  )
                ),
                child: Image.file(
                  File(coverImage),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(height: 50, color: Colors.grey[900], child: const Icon(Icons.broken_image)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TAGS
                  if (note.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: note.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.neonCyan, width: 0.5),
                            color: AppTheme.neonCyan.withOpacity(0.1),
                          ),
                          child: Text(
                            tag, 
                            style: const TextStyle(fontSize: 8, fontFamily: 'Orbitron', color: AppTheme.neonCyan)
                          ),
                        )).toList(),
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       // PARTIE GAUCHE (GPS ou Ligne)
                       // On utilise Expanded pour qu'il prenne la place dispo sans pousser la date
                       Expanded(
                         child: note.latitude != null 
                           ? Row(
                               children: [
                                 const Icon(Icons.gps_fixed, size: 12, color: AppTheme.dangerRed),
                                 const SizedBox(width: 4),
                                 // "Flexible" permet au texte de se couper (...) si l'écran est vraiment trop petit
                                 const Flexible(
                                   child: Text(
                                     "LOCKED", // J'ai raccourci "LOC_LOCKED" pour gagner de la place
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                     style: TextStyle(fontSize: 10, color: AppTheme.dangerRed, fontFamily: 'Orbitron')
                                   ),
                                 )
                               ],
                             )
                           : Align(
                               alignment: Alignment.centerLeft,
                               child: Container(width: 30, height: 2, color: AppTheme.neonCyan),
                             ),
                       ),
                       
                       // Petit espace de sécurité
                       const SizedBox(width: 8),

                       // PARTIE DROITE (DATE)
                       // J'ai retiré l'heure (HH:mm) sur l'accueil pour alléger le visuel, 
                       // mais vous pouvez la remettre si vous voulez.
                       Text(
                         DateFormat('MM.dd').format(note.modifiedTime), 
                         style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace')
                       ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (note.title.isNotEmpty)
                    Text(
                      note.title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    maxLines: coverImage != null ? 3 : 6,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}