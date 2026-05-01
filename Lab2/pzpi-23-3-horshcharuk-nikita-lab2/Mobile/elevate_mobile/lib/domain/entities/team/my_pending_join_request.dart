class MyPendingJoinRequest {
  final int id;
  final int teamId;
  final String teamName;
  final String status;
  final DateTime requestedAt;

  const MyPendingJoinRequest({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.status,
    required this.requestedAt,
  });
}
