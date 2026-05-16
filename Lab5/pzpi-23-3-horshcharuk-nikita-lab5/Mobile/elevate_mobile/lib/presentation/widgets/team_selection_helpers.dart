import 'package:elevate_mobile/domain/entities/dashboard/dashboard.dart';

int? effectiveTeamIdForDashboards(List<Dashboard> dashboards, int? selectedId) {
  if (dashboards.isEmpty) return null;
  if (selectedId != null &&
      dashboards.any((d) => d.teamId == selectedId)) {
    return selectedId;
  }
  return dashboards.first.teamId;
}

Dashboard? dashboardForSelection(List<Dashboard> dashboards, int? selectedId) {
  final id = effectiveTeamIdForDashboards(dashboards, selectedId);
  if (id == null) return null;
  for (final d in dashboards) {
    if (d.teamId == id) return d;
  }
  return null;
}
