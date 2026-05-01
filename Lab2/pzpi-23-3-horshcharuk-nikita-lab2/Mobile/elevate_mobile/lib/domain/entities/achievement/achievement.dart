class Achievement {
  final String id;
  final String title;
  final String description;
  final bool earned;
  final DateTime? earnedAt;
  final int? teamId;
  final String? teamName;
  final String? requirement;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.earned,
    this.earnedAt,
    this.teamId,
    this.teamName,
    this.requirement,
  });
}