import 'package:elevate_mobile/domain/entities/action/action_type.dart';
import 'package:flutter/material.dart';

class TeamActionTypeCard extends StatelessWidget {
  final ActionType action;
  final VoidCallback onDo;

  const TeamActionTypeCard({
    super.key,
    required this.action,
    required this.onDo,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final desc = action.description?.trim();
    final secondaryLine =
        (desc != null && desc.isNotEmpty) ? desc : action.code;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (secondaryLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryLine.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.4,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '+${action.defaultPoints} pts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onDo,
              child: const Text('Do'),
            ),
          ],
        ),
      ),
    );
  }
}
