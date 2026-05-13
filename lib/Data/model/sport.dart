/// Represents a sport option in the choose-sport flow.
class Sport {
  const Sport({
    required this.imagePath,
    required this.title,
    this.id,
    this.iconKey,
    this.category,
    this.isPopular = false,
  });

  final String imagePath;
  final String title;
  final String? id;
  final String? iconKey;
  final String? category;
  final bool isPopular;
}
