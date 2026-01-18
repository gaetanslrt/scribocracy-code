import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribocracy_new/models/note.dart';

class DatabaseService {
  late Future<Isar> db;

  DatabaseService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [NoteSchema], // Généré par Isar
        directory: dir.path,
        inspector: true, // Permet de visualiser la DB en temps réel
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Sauvegarder ou Mettre à jour (Isar gère l'upsert via l'ID)
  Future<void> saveNote(Note note) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  // Supprimer
  Future<void> deleteNote(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });
  }

  // Flux de données en temps réel (Le secret de la performance)
  Stream<List<Note>> watchAllNotes() async* {
    final isar = await db;
    yield* isar.notes
        .where()
        .sortByModifiedTimeDesc()
        .watch(fireImmediately: true);
  }

  // Recherche Super Rapide
  Stream<List<Note>> searchNotes(String query) async* {
    final isar = await db;
    yield* isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .sortByModifiedTimeDesc()
        .watch(fireImmediately: true);
  }
}
