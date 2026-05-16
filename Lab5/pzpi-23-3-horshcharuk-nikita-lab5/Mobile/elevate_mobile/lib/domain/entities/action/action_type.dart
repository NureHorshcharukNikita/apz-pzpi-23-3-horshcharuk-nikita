class ActionType {
  final int id;
  final int teamId;
  final String code;
  final String name;
  final String? description;
  final int defaultPoints;
  final String? category;
  final bool isActive;

  const ActionType({
    required this.id,
    required this.teamId,
    required this.code,
    required this.name,
    this.description,
    required this.defaultPoints,
    this.category,
    required this.isActive,
  });
}