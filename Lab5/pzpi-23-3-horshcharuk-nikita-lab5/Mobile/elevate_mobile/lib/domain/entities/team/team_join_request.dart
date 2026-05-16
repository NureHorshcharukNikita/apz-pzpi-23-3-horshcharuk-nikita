class TeamJoinRequest {
  final int id;
  final int teamId;
  final int userId;
  final String userFullName;
  final String status;
  final DateTime requestedAt;

  const TeamJoinRequest({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.userFullName,
    required this.status,
    required this.requestedAt,
  });
}
