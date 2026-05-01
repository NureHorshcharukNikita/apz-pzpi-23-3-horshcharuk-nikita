class TeamBadgeInfo {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String? iconCode;
  final String? conditionType;
  final int? conditionValue;

  const TeamBadgeInfo({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.iconCode,
    this.conditionType,
    this.conditionValue,
  });
}
