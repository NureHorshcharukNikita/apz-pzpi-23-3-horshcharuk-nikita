import 'package:elevate_mobile/domain/entities/achievement/achievement.dart';
import 'package:elevate_mobile/presentation/widgets/achievements/achievement_subtitle.dart';
import 'package:flutter/material.dart';

class AchievementListTile extends StatelessWidget {
  final Achievement achievement;

  const AchievementListTile({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    return Card(
      child: ListTile(
        isThreeLine: true,
        leading: Icon(
          Icons.emoji_events,
          color: a.earned ? Colors.amber : Colors.grey,
        ),
        title: Text(a.title),
        subtitle: AchievementSubtitle(achievement: a),
        trailing: a.earned ? const Icon(Icons.check) : null,
      ),
    );
  }
}
