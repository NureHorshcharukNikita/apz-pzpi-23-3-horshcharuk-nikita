class Activity {
  final String id;
  final int teamId;
  final String teamName;
  final String type;
  final String description;
  final int points;
  final DateTime date;

  const Activity({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.type,
    required this.description,
    required this.points,
    required this.date,
  });
}