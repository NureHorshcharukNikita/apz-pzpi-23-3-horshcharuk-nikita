import 'package:elevate_mobile/domain/entities/team/team_join_request.dart';

class TeamJoinRequestModel {
  final int id;
  final int teamId;
  final int userId;
  final String userFullName;
  final String status;
  final DateTime requestedAt;

  const TeamJoinRequestModel({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.userFullName,
    required this.status,
    required this.requestedAt,
  });

  TeamJoinRequest toEntity() => TeamJoinRequest(
        id: id,
        teamId: teamId,
        userId: userId,
        userFullName: userFullName,
        status: status,
        requestedAt: requestedAt,
      );

  factory TeamJoinRequestModel.fromJson(Map<String, dynamic> e) {
    return TeamJoinRequestModel(
      id: _int(e['id'] ?? e['Id']),
      teamId: _int(e['teamId'] ?? e['TeamId']),
      userId: _int(e['userId'] ?? e['UserId']),
      userFullName:
          '${e['userFullName'] ?? e['UserFullName'] ?? ''}'.trim(),
      status: '${e['status'] ?? e['Status'] ?? ''}',
      requestedAt: DateTime.parse(
        '${e['requestedAt'] ?? e['RequestedAt']}',
      ),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }
}
