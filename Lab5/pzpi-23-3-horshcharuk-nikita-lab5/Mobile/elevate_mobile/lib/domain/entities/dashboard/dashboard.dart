class Dashboard {
  final int teamId;
  final String teamName;
  final int level;
  final int points;
  final int rank;

  final int currentXp;
  final int nextLevelXp;
  final bool atMaxTier;
  final String? tierName;

  final List<String> recentAchievements;

  const Dashboard({
    required this.teamId,
    required this.teamName,
    required this.level,
    required this.points,
    required this.rank,
    required this.currentXp,
    required this.nextLevelXp,
    this.atMaxTier = false,
    this.tierName,
    required this.recentAchievements,
  });
}