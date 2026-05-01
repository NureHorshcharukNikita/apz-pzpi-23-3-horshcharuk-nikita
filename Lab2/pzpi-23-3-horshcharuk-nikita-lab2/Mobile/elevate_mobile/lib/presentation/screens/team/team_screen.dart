import 'dart:async';

import 'package:elevate_mobile/presentation/screens/team/team_screen/team_screen_discover_tab.dart';
import 'package:elevate_mobile/presentation/screens/team/team_screen/team_screen_my_teams_tab.dart';
import 'package:elevate_mobile/providers/team/refresh_teams_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamScreen extends ConsumerStatefulWidget {
  final bool showScaffold;
  final int initialTab;

  const TeamScreen({
    super.key,
    this.showScaffold = false,
    this.initialTab = 0,
  });

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  late VoidCallback _teamsTabListener;
  late int _lastSyncedTeamsTabIndex;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _lastSyncedTeamsTabIndex = controller.index;
    _teamsTabListener = () {
      if (!mounted) return;
      final idx = controller.index;
      if (idx == _lastSyncedTeamsTabIndex) return;
      _lastSyncedTeamsTabIndex = idx;
      unawaited(refreshTeamsHub(ref));
    };
    controller.addListener(_teamsTabListener);
  }

  @override
  void didUpdateWidget(covariant TeamScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab &&
        controller.index != widget.initialTab) {
      controller.animateTo(widget.initialTab);
      _lastSyncedTeamsTabIndex = widget.initialTab;
      unawaited(refreshTeamsHub(ref));
    }
  }

  @override
  void dispose() {
    controller.removeListener(_teamsTabListener);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        TabBar(
          controller: controller,
          tabs: const [
            Tab(text: "My Teams"),
            Tab(text: "Discover"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: const [
              TeamMyTeamsTab(),
              TeamDiscoverTeamsTab(),
            ],
          ),
        ),
      ],
    );

    if (!widget.showScaffold) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teams"),
      ),
      body: content,
    );
  }
}
