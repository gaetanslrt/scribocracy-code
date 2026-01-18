import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  @Index(type: IndexType.value, caseSensitive: false)
  late String content;

  @Index()
  late DateTime modifiedTime;

  late List<String> images;
  late List<String> tags;

  // NOUVEAUX CHAMPS : GEO_INTEL
  // On met des "double?" (nullable) car une note peut ne pas avoir de localisation
  double? latitude;
  double? longitude;

  Note({
    required this.title,
    required this.content,
    required this.modifiedTime,
    this.images = const [],
    this.tags = const [],
    this.latitude,
    this.longitude,
  });
}