import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/core/utils/date_format_ua.dart';
import 'package:elevate_mobile/domain/entities/team/member_badge_award.dart';
import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/domain/entities/team/team_member.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/team/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamDetailsMemberBadgesDialog extends ConsumerStatefulWidget {
  final int teamId;
  final TeamMember member;
  final Team team;

  const TeamDetailsMemberBadgesDialog({
    super.key,
    required this.teamId,
    required this.member,
    required this.team,
  });

  @override
  ConsumerState<TeamDetailsMemberBadgesDialog> createState() =>
      _TeamDetailsMemberBadgesDialogState();
}

class _TeamDetailsMemberBadgesDialogState
    extends ConsumerState<TeamDetailsMemberBadgesDialog> {
  var _reloadToken = 0;

  Future<List<MemberBadgeAward>> _fetch() => ref
      .read(teamRepositoryProvider)
      .getMemberBadgeAwards(widget.teamId, widget.member.id);

  void _refresh() {
    setState(() => _reloadToken++);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Badges — ${widget.member.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<MemberBadgeAward>>(
          key: ValueKey(_reloadToken),
          future: _fetch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return LoadErrorView.fromError(
                snapshot.error,
                compact: true,
                title: 'Could not load badges',
                onRetry: _refresh,
              );
            }
            final awards = snapshot.data ?? [];
            final badges = widget.team.badges ?? [];
            final awardedIds = awards.map((a) => a.teamBadgeId).toSet();
            final available =
                badges.where((b) => !awardedIds.contains(b.id)).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (awards.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('No badges yet.'),
                    )
                  else
                    ...awards.map(
                      (a) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(a.badgeName),
                        subtitle: Text(formatDateUa(a.awardedAt)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(teamRepositoryProvider)
                                  .revokeMemberBadgeAward(
                                    widget.teamId,
                                    widget.member.id,
                                    a.userTeamBadgeId,
                                  );
                              _refresh();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(mapError(e))),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  const Divider(),
                  const Text(
                    'Add badge',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (available.isEmpty)
                    const Text(
                      'All defined team badges are already awarded, or none exist.',
                    )
                  else
                    ...available.map(
                      (b) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(b.name),
                        subtitle:
                            (b.description != null && b.description!.isNotEmpty)
                                ? Text(b.description!)
                                : null,
                        onTap: () async {
                          try {
                            await ref.read(teamRepositoryProvider).grantMemberBadge(
                                  widget.teamId,
                                  widget.member.id,
                                  b.id,
                                );
                            _refresh();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(mapError(e))),
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
