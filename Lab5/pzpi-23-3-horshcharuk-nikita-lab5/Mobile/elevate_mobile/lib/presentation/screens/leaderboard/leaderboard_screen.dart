import 'package:elevate_mobile/presentation/viewmodels/leaderboard/leaderboard_viewmodel.dart';
import 'package:elevate_mobile/presentation/widgets/load_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardViewModelProvider);
    final vm = ref.watch(leaderboardViewModelProvider.notifier);

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
            children: [
              _Filter("day", "Day", vm),
              _Filter("week", "Week", vm),
              _Filter("month", "Month", vm),
              _Filter("all", "All", vm),
            ],
          ),
        ),

        Expanded(
          child: state.when(
            initial: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e) => Center(
                  child: LoadErrorView(
                    message: e,
                    onRetry: () => vm.load(),
                  ),
                ),
            loaded: (users) => RefreshIndicator(
              onRefresh: () => vm.load(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        user.position.toString(),
                      ),
                    ),
                    title: Text(user.name),
                    trailing: Text("${user.points} pts"),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Filter extends StatelessWidget {
  final String value;
  final String label;
  final LeaderboardViewModel vm;

  const _Filter(
      this.value,
      this.label,
      this.vm,
      );

  @override
  Widget build(BuildContext context) {
    final selected = vm.currentPeriod == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        vm.load(value);
      },
    );
  }
}