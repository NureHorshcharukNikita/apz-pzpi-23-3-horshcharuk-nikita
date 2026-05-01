class TeamMember {
  final int id;
  final String name;
  final int level;
  final String? tierName;
  final int currentXp;
  final int nextLevelXp;
  final int points;
  final int rank;
  final String teamRole;

  const TeamMember({
    required this.id,
    required this.name,
    required this.level,
    required this.tierName,
    required this.currentXp,
    required this.nextLevelXp,
    required this.points,
    required this.rank,
    this.teamRole = 'Member',
  });
}