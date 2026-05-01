import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_member_actions.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_member_badges_dialog.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_progress_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamDetailsMemberCard extends ConsumerWidget {
  final Team team;
  final TeamMember member;
  final int? myUserId;
  final bool isCreator;
  final bool canManageMemberProgress;

  const TeamDetailsMemberCard({
    super.key,
    required this.team,
    required this.member,
    required this.myUserId,
    required this.isCreator,
    required this.canManageMemberProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog = teamDetailsProgressFromTeamLevels(team, member.points);

    final displayLevel = prog.level;
    final displayCx = prog.currentXp;
    final displayNx = prog.nextLevelXp;
    final displayTier = prog.tierName ?? member.tierName;
    final atMax = prog.atMaxTier;

    final span = atMax
        ? 1.0
        : (displayNx == 0 ? 0.0 : displayCx / displayNx);

    final scheme = Theme.of(context).colorScheme;

    final canKickMember = isCreator && member.id != myUserId;
    final showMenu = canManageMemberProgress || canKickMember;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer,
              ),
              alignment: Alignment.center,
              child: Text(
                '${member.rank}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teamDetailsMemberSubtitle(displayLevel, displayTier),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: span.clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    atMax
                        ? 'Highest tier · +$displayCx XP beyond last milestone'
                        : '$displayCx / $displayNx XP in this tier'
                            '${prog.nextMilestoneTotal != null ? ' · next at ${prog.nextMilestoneTotal} total' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${member.points} pts',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showMenu) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'points') {
                    await teamDetailsEditMemberTeamPoints(
                      context,
                      ref,
                      team.id,
                      member,
                    );
                  } else if (value == 'badges') {
                    if (!context.mounted) return;
                    await showDialog<void>(
                      context: context,
                      builder: (ctx) => TeamDetailsMemberBadgesDialog(
                        teamId: team.id,
                        member: member,
                        team: team,
                      ),
                    );
                  } else if (value == 'kick') {
                    await teamDetailsConfirmRemoveMember(
                      context,
                      ref,
                      team.id,
                      member,
                    );
                  }
                },
                itemBuilder: (context) => [
                  if (canManageMemberProgress) ...[
                    const PopupMenuItem(
                      value: 'points',
                      child: Text('Edit team points'),
                    ),
                    const PopupMenuItem(
                      value: 'badges',
                      child: Text('Manage badges'),
                    ),
                  ],
                  if (canKickMember)
                    const PopupMenuItem(
                      value: 'kick',
                      child: Text('Remove from team'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
