import 'package:elevate_mobile/domain/entities/activity/activity.dart';
import 'package:elevate_mobile/presentation/widgets/activity/activity_type_icon.dart';
import 'package:flutter/material.dart';

class ActivityFeedTile extends StatelessWidget {
  final Activity item;

  const ActivityFeedTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ActivityTypeIcon(type: item.type),
        title: Text(item.description),
        subtitle: Text('${item.teamName} · ${item.type}'),
        trailing: Text('+${item.points}'),
      ),
    );
  }
}
