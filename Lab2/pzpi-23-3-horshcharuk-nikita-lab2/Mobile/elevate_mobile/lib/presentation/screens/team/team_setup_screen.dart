import 'package:elevate_mobile/presentation/screens/team/team_setup/team_setup_flow.dart';
import 'package:elevate_mobile/presentation/screens/team/team_setup/team_setup_list_helpers.dart';
import 'package:elevate_mobile/presentation/widgets/team_setup/team_setup_tab_stack.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_details_viewmodel.dart';
import 'package:elevate_mobile/presentation/viewmodels/team/team_setup_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:elevate_mobile/providers/actions/actions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSetupScreen extends ConsumerStatefulWidget {
  final int teamId;

  const TeamSetupScreen({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends ConsumerState<TeamSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _teamName = TextEditingController();
  final _teamDesc = TextEditingController();
  final _teamMaxMembers = TextEditingController(text: '10');

  final _searchLevels = TextEditingController();
  final _searchBadges = TextEditingController();
  final _searchActions = TextEditingController();

  bool _teamFieldsSynced = false;
  bool _unlimitedMembers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant TeamSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamId != widget.teamId) {
      _teamFieldsSynced = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _teamName.dispose();
    _teamDesc.dispose();
    _teamMaxMembers.dispose();
    _searchLevels.dispose();
    _searchBadges.dispose();
    _searchActions.dispose();
    super.dispose();
  }

  void _onFabPressed(TeamSetupFlow flow) {
    ref.read(teamDetailsViewModelProvider(widget.teamId)).maybeWhen(
          loaded: (team) {
            final levels =
                TeamSetupListHelpers.sortedLevels(team.levelThresholds);
            final idx = _tabController.index;
            if (idx == 1) {
              flow.showAddLevelSheet(
                context,
                team.levelPointsMode,
                levels,
              );
            } else if (idx == 2) {
              flow.showAddBadgeSheet(context, levels);
            } else if (idx == 3) {
              flow.showAddActionSheet(context);
            }
          },
          orElse: () {},
        );
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamDetailsViewModelProvider(widget.teamId));
    final actionTypesAsync =
        ref.watch(teamSetupActionTypesProvider(widget.teamId));
    final scheme = Theme.of(context).colorScheme;
    final teamBusy =
        ref.watch(teamSetupViewModelProvider(widget.teamId)).teamOperationBusy;
    final flow = TeamSetupFlow(ref: ref, teamId: widget.teamId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team setup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Team'),
            Tab(text: 'Levels'),
            Tab(text: 'Badges'),
            Tab(text: 'Actions'),
          ],
        ),
      ),
      floatingActionButton: teamState.maybeWhen(
        loaded: (_) {
          final i = _tabController.index;
          if (i < 1 || i > 3) return null;
          return FloatingActionButton(
            onPressed: () => _onFabPressed(flow),
            tooltip: 'Add',
            child: const Icon(Icons.add),
          );
        },
        orElse: () => null,
      ),
      body: teamState.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e) => Center(
          child: LoadErrorView(
            message: e,
            onRetry: () => ref
                .read(teamDetailsViewModelProvider(widget.teamId).notifier)
                .load(),
          ),
        ),
        loaded: (team) {
          if (!_teamFieldsSynced) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _teamFieldsSynced) return;
              setState(() {
                _teamName.text = team.name;
                _teamDesc.text = team.description ?? '';
                _unlimitedMembers = !team.hasMemberLimit;
                _teamMaxMembers.text = team.hasMemberLimit &&
                        team.maxMembers != null
                    ? '${team.maxMembers}'
                    : '10';
                _teamFieldsSynced = true;
              });
            });
          }

          return TeamSetupTabStack(
            tabController: _tabController,
            team: team,
            teamId: widget.teamId,
            scheme: scheme,
            teamBusy: teamBusy,
            actionTypesAsync: actionTypesAsync,
            teamName: _teamName,
            teamDesc: _teamDesc,
            teamMaxMembers: _teamMaxMembers,
            searchLevels: _searchLevels,
            searchBadges: _searchBadges,
            searchActions: _searchActions,
            unlimitedMembers: _unlimitedMembers,
            onUnlimitedMembersChanged: teamBusy
                ? null
                : (v) => setState(() => _unlimitedMembers = v),
            bumpSearch: () => setState(() {}),
            flow: flow,
          );
        },
      ),
    );
  }
}
