import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/core/router/app_router.dart';
import 'package:elevate_mobile/core/utils/date_format_ua.dart';
import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';
import 'package:elevate_mobile/domain/entities/team/my_pending_join_request.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/presentation/screens/team/team_screen/team_screen_helpers.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TeamMyTeamsSectionHeader extends StatelessWidget {
  const TeamMyTeamsSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class TeamMyTeamsSectionEmpty extends StatelessWidget {
  const TeamMyTeamsSectionEmpty({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class TeamMyTeamRowCard extends ConsumerWidget {
  const TeamMyTeamRowCard({
    super.key,
    required this.team,
    required this.dash,
  });

  final Team team;
  final Dashboard? dash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final progress = myTeamRowProgressForList(team, dash);
    final tierLabel = progress.tierName?.trim();
    final hasTier = tierLabel != null && tierLabel.isNotEmpty;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: const Icon(Icons.groups),
        title: Text(
          team.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                progress.level != null
                    ? 'Level ${progress.level}'
                    : 'No tier yet',
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (hasTier)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.military_tech,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tierLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await context.push<void>(
            AppRoutes.teamDetailsById(team.id),
          );
          if (context.mounted) await refreshTeamsHub(ref);
        },
      ),
    );
  }
}

class TeamPendingApplicationRowCard extends ConsumerWidget {
  const TeamPendingApplicationRowCard({super.key, required this.request});

  final MyPendingJoinRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Icon(Icons.hourglass_top, color: scheme.primary),
        title: Text(
          request.teamName,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Applied ${formatDateUa(request.requestedAt)} · Pending',
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: TextButton(
          onPressed: () async {
            try {
              await ref
                  .read(cancelMyJoinRequestUseCaseProvider)
                  .call(request.teamId);
              await refreshTeamsHub(ref);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Join request cancelled')),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mapError(e))),
              );
            }
          },
          child: const Text('Cancel'),
        ),
        onTap: () async {
          await context.push<void>(
            AppRoutes.teamDetailsById(request.teamId),
          );
          if (context.mounted) await refreshTeamsHub(ref);
        },
      ),
    );
  }
}
