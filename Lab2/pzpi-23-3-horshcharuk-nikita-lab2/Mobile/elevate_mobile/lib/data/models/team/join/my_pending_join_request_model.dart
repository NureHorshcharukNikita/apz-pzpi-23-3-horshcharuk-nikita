import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';

class MyPendingJoinRequestModel {
  final int id;
  final int teamId;
  final String teamName;
  final String status;
  final DateTime requestedAt;

  const MyPendingJoinRequestModel({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.status,
    required this.requestedAt,
  });

  MyPendingJoinRequest toEntity() => MyPendingJoinRequest(
        id: id,
        teamId: teamId,
        teamName: teamName,
        status: status,
        requestedAt: requestedAt,
      );

  factory MyPendingJoinRequestModel.fromJson(Map<String, dynamic> e) {
    return MyPendingJoinRequestModel(
      id: _int(e['id'] ?? e['Id']),
      teamId: _int(e['teamId'] ?? e['TeamId']),
      teamName: '${e['teamName'] ?? e['TeamName'] ?? ''}'.trim(),
      status: '${e['status'] ?? e['Status'] ?? ''}',
      requestedAt: _parseDateTime(e['requestedAt'] ?? e['RequestedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (v is DateTime) return v;
    final s = v.toString().trim();
    if (s.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return DateTime.tryParse(s) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }
}
