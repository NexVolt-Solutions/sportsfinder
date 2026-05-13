enum MySpor { beginner, intermediate, advanced }

class MySport {
  final String name;
  final String skill;

  /// e.g. API `sport.category` — "field_team" shown as human-readable subtitle.
  final String category;

  MySport({required this.name, required this.skill, this.category = ''});
}
