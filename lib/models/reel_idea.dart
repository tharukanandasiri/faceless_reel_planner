import 'package:hive/hive.dart';

part 'reel_idea.g.dart';

@HiveType(typeId: 0)
class ReelIdea extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String scriptText;

  @HiveField(3)
  String? backgroundImageUrl;

  @HiveField(4)
  String status; // e.g., 'Idea', 'Scripting', 'Ready'

  ReelIdea({
    required this.id,
    required this.title,
    required this.scriptText,
    this.backgroundImageUrl,
    this.status = 'Idea',
  });
}
