/// Represents a single skill level option (e.g. Beginner, Intermediate, Advanced).
class SkillLevel {
  const SkillLevel({
    required this.imagePath,
    required this.title,
    required this.subTitle,
  });

  final String imagePath;
  final String title;
  final String subTitle;
}
