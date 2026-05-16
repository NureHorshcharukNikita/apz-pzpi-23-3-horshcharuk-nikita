import 'package:elevate_mobile/domain/entities/team/team.dart';
import 'package:elevate_mobile/presentation/widgets/team_details/team_details_member_card.dart';
import 'package:elevate_mobile/presentation/states/team/team_members_state.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_members_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamDetailsMembersSection extends ConsumerWidget {
  final int teamId;
  final Team team;
  final TeamMembersState membersState;
  final int? myUserId;
  final bool isCreator;
  final bool canManageMemberProgress;

  const TeamDetailsMembersSection({
    super.key,
    required this.teamId,
    required this.team,
    required this.membersState,
    required this.myUserId,
    required this.isCreator,
    required this.canManageMemberProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Members',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        membersState.when(
          initial: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e) => LoadErrorView(
            message: e,
            compact: true,
            onRetry: () => ref
                .read(teamMembersViewModelProvider(teamId).notifier)
                .load(),
          ),
          loaded: (members) {
            if (members.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No members'),
                ),
              );
            }

            return Column(
              children: members
                  .map(
                    (member) => TeamDetailsMemberCard(
                      team: team,
                      member: member,
                      myUserId: myUserId,
                      isCreator: isCreator,
                      canManageMemberProgress: canManageMemberProgress,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
