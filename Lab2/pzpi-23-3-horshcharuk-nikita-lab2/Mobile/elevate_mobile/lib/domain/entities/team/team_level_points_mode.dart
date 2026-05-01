enum TeamLevelPointsMode {
  relativeSegments,

  absoluteTotals,
}

TeamLevelPointsMode teamLevelPointsModeFromApiInt(int v) {
  if (v == 0) return TeamLevelPointsMode.relativeSegments;
  return TeamLevelPointsMode.absoluteTotals;
}

int teamLevelPointsModeToApiInt(TeamLevelPointsMode m) =>
    m == TeamLevelPointsMode.relativeSegments ? 0 : 1;
