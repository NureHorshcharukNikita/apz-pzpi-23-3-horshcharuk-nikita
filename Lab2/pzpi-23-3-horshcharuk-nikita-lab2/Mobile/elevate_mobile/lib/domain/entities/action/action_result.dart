class ActionResult {
  final int actionEventId;
  final int userId;
  final int teamId;
  final int pointsAwarded;
  final int totalTeamPoints;
  final String? newTeamLevelName;
  final List<String> newBadges;

  const ActionResult({
    required this.actionEventId,
    required this.userId,
    required this.teamId,
    required this.pointsAwarded,
    required this.totalTeamPoints,
    this.newTeamLevelName,
    required this.newBadges,
  });
}