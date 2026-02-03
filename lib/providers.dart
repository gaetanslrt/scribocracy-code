import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribocracy_new/models/chat.dart';
import 'package:scribocracy_new/services/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider((ref) => DatabaseService());
final searchEngineProvider = StateProvider<String>((ref) => 'google');
// État du mode sombre (Par défaut : false)
final darkModeProvider = StateProvider<bool>((ref) => false);

final chatsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getAllChats();
});
