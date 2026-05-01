import 'dart:math' as math;

import 'package:elevate_mobile/domain/entities/team/team_level_threshold.dart';

typedef _Milestone = ({int orderIndex, int cumulativePoints, String? anchorName});

double _exponentialInterp(double t, double k) {
  t = t.clamp(0.0, 1.0);
  if (k.abs() < 1e-9) return t;
  return (math.exp(k * t) - 1) / (math.exp(k) - 1);
}

const double _defaultCurveK = 2.0;

List<_Milestone> _buildEffectiveMilestones(
  List<TeamLevelThreshold> raw, {
  double curveK = _defaultCurveK,
}) {
  if (raw.isEmpty) return const [];

  final merged = <int, TeamLevelThreshold>{};
  for (final l in raw) {
    final existing = merged[l.orderIndex];
    if (existing == null || l.requiredPoints > existing.requiredPoints) {
      merged[l.orderIndex] = l;
    }
  }

  final anchors = merged.values.toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  final maxOrder = anchors.map((e) => e.orderIndex).reduce(math.max);
  if (maxOrder < 1) return const [];

  final anchorPoints = <int, int>{
    for (final a in anchors) a.orderIndex: math.max(0, a.requiredPoints),
  };
  final anchorNames = <int, String?>{
    for (final a in anchors)
      a.orderIndex: a.name.trim().isEmpty ? null : a.name.trim(),
  };

  final anchorOrders = anchors.map((e) => e.orderIndex).toList()..sort();

  var lastP = 0;
  for (final o in anchorOrders) {
    var p = anchorPoints[o]!;
    if (p < lastP) anchorPoints[o] = lastP;
    lastP = anchorPoints[o]!;
  }

  final result = <_Milestone>[];
  var prevO = 0;
  var prevP = 0;

  for (final nextO in anchorOrders) {
    var nextP = anchorPoints[nextO]!;

    if (nextO > prevO + 1) {
      for (var o = prevO + 1; o < nextO; o++) {
        final t = (o - prevO) / (nextO - prevO);
        var rawC = prevP + (nextP - prevP) * _exponentialInterp(t, curveK);
        var c = rawC.round();
        if (result.isNotEmpty) {
          c = math.max(c, result.last.cumulativePoints + 1);
        }
        if (c >= nextP) {
          c = math.max(prevP + 1, nextP - 1);
        }
        result.add((orderIndex: o, cumulativePoints: c, anchorName: null));
      }
    }

    if (nextP <= prevP) {
      nextP = (result.isNotEmpty ? result.last.cumulativePoints : prevP) + 1;
    }

    result.add((
      orderIndex: nextO,
      cumulativePoints: nextP,
      anchorName: anchorNames[nextO],
    ));
    prevO = nextO;
    prevP = nextP;
  }

  return result;
}

({
  int level,
  int currentXp,
  int nextLevelXp,
  String? tierName,
  int? nextMilestoneTotal,
  bool atMaxTier,
}) computeTeamLevelProgress(
  int teamPoints,
  List<TeamLevelThreshold> levelsOrdered,
) {
  final milestones = _buildEffectiveMilestones(levelsOrdered);
  if (milestones.isEmpty) {
    return (
      level: 0,
      currentXp: 0,
      nextLevelXp: 0,
      tierName: null,
      nextMilestoneTotal: null,
      atMaxTier: false,
    );
  }

  var currentIdx = -1;
  for (var i = 0; i < milestones.length; i++) {
    if (teamPoints >= milestones[i].cumulativePoints) {
      currentIdx = i;
    } else {
      break;
    }
  }

  if (currentIdx < 0) {
    final first = milestones.first;
    final need = first.cumulativePoints;
    return (
      level: 0,
      currentXp: teamPoints,
      nextLevelXp: need > 0 ? need : 1,
      tierName: null,
      nextMilestoneTotal: need,
      atMaxTier: false,
    );
  }

  final current = milestones[currentIdx];
  final displayTier = tierNameVisible(teamPoints, current.anchorName);

  if (currentIdx + 1 >= milestones.length) {
    final overflow = math.max(0, teamPoints - current.cumulativePoints);
    return (
      level: current.orderIndex,
      currentXp: overflow,
      nextLevelXp: 0,
      tierName: displayTier,
      nextMilestoneTotal: null,
      atMaxTier: true,
    );
  }

  final next = milestones[currentIdx + 1];
  final currentXp = math.max(0, teamPoints - current.cumulativePoints);
  final span = math.max(1, next.cumulativePoints - current.cumulativePoints);
  return (
    level: current.orderIndex,
    currentXp: currentXp,
    nextLevelXp: span,
    tierName: displayTier,
    nextMilestoneTotal: next.cumulativePoints,
    atMaxTier: false,
  );
}

String? tierNameVisible(int teamPoints, String? anchorName) {
  if (teamPoints <= 0) return null;
  final t = anchorName?.trim();
  if (t == null || t.isEmpty) return null;
  return t;
}
