import 'package:elevate_mobile/domain/entities/team/team_badge_info.dart';

class TeamBadgeModel {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String? iconCode;
  final String? conditionType;
  final int? conditionValue;

  const TeamBadgeModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.iconCode,
    this.conditionType,
    this.conditionValue,
  });

  factory TeamBadgeModel.fromJson(Map<String, dynamic> e) {
    return TeamBadgeModel(
      id: _int(e['id'] ?? e['Id']),
      code: '${e['code'] ?? e['Code'] ?? ''}',
      name: '${e['name'] ?? e['Name'] ?? ''}',
      description: _string(e['description'] ?? e['Description']),
      iconCode: _string(e['iconCode'] ?? e['IconCode']),
      conditionType: _string(e['conditionType'] ?? e['ConditionType']),
      conditionValue: _intNullable(e['conditionValue'] ?? e['ConditionValue']),
    );
  }

  TeamBadgeInfo toEntity() => TeamBadgeInfo(
        id: id,
        code: code,
        name: name,
        description: description,
        iconCode: iconCode,
        conditionType: conditionType,
        conditionValue: conditionValue,
      );

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  static int? _intNullable(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  static String? _string(dynamic v) {
    if (v == null) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }
}
