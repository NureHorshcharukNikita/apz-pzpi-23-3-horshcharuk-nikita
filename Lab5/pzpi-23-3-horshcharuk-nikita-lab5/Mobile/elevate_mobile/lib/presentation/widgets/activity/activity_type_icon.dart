import 'package:flutter/material.dart';

class ActivityTypeIcon extends StatelessWidget {
  final String type;

  const ActivityTypeIcon({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'points':
        return const Icon(Icons.add_circle);
      case 'badge':
        return const Icon(Icons.emoji_events);
      case 'level':
        return const Icon(Icons.trending_up);
      case 'kudos':
        return const Icon(Icons.favorite);
      default:
        return const Icon(Icons.bolt);
    }
  }
}
