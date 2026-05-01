class TeamLevelThreshold {
  final int id;
  final int orderIndex;
  final int requiredPoints;
  final String name;

  const TeamLevelThreshold({
    required this.id,
    required this.orderIndex,
    required this.requiredPoints,
    required this.name,
  });

  String get displayTitle {
    final t = name.trim();
    return t.isEmpty ? 'Level $orderIndex' : t;
  }
}
