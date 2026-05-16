import 'package:elevate_mobile/core/error/app_error.dart';
import 'package:elevate_mobile/domain/usecases/dashboard/get_dashboard_usecase.dart';
import 'package:elevate_mobile/providers/dashboard/dashboard_provider.dart';
import 'package:elevate_mobile/presentation/states/dashboard/dashboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardViewModelProvider =
StateNotifierProvider<DashboardViewModel, DashboardState>(
      (ref) => DashboardViewModel(
    ref.read(getDashboardUseCaseProvider),
  ),
);

class DashboardViewModel extends StateNotifier<DashboardState> {
  final GetDashboardUseCase getDashboard;

  DashboardViewModel(this.getDashboard) : super(const DashboardState.initial()) {
    load();
  }

  Future<void> load({bool showLoadingIndicator = true}) async {
    try {
      if (showLoadingIndicator) {
        state = const DashboardState.loading();
      }

      final dashboards = await getDashboard();

      state = DashboardState.loaded(dashboards);
    } catch (e) {
      state = DashboardState.error(mapError(e));
    }
  }
}