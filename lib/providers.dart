import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribocracy_new/models/note.dart';
import 'package:scribocracy_new/services/database.dart';

// 1. Fournisseur de la Base de données
final databaseProvider = Provider<DatabaseService>((ref) => DatabaseService());

// 2. Fournisseur du terme de recherche
final searchQueryProvider = StateProvider<String>((ref) => '');

// 3. Fournisseur intelligent des notes (Filtre + Flux temps réel)
final notesProvider = StreamProvider<List<Note>>((ref) {
  final dbService = ref.watch(databaseProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return dbService.watchAllNotes();
  } else {
    return dbService.searchNotes(query);
  }
});
