import 'package:isar/isar.dart';

part 'chat.g.dart';

@collection
class ChatSession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime lastModified;

  String? title; // Titre de la conversation (ex: "Résumé projet Alpha")
  
  List<ChatMessage> messages; // Liste des messages intégrés

  ChatSession({
    required this.lastModified,
    this.title,
    this.messages = const [],
  });
}

@embedded
class ChatMessage {
  String? role; // "user" ou "ai"
  String? content;
  DateTime? timestamp;

  ChatMessage({this.role, this.content, this.timestamp});
}