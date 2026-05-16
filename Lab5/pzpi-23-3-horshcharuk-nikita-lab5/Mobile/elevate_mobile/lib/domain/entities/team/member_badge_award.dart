class MemberBadgeAward {
  final int userTeamBadgeId;
  final int teamBadgeId;
  final String badgeName;
  final DateTime awardedAt;

  const MemberBadgeAward({
    required this.userTeamBadgeId,
    required this.teamBadgeId,
    required this.badgeName,
    required this.awardedAt,
  });
}
