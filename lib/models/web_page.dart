import 'package:isar/isar.dart';

part 'web_page.g.dart';

@collection
class WebPage {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String url;

  String? title;
  
  @Index()
  late DateTime lastVisited;

  int visitCount; // Pour trier par popularité
  
  bool isFavorite; // Pour les épinglés

  String? faviconUrl; // (Optionnel pour plus tard)

  WebPage({
    required this.url,
    this.title,
    required this.lastVisited,
    this.visitCount = 1,
    this.isFavorite = false,
  });
}