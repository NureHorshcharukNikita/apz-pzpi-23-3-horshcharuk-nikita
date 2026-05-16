export type TeamLevelPointsModeApi = 0 | 1

export function levelPointsModeFromDb(value: unknown): TeamLevelPointsModeApi {
  if (value === 0 || value === '0') return 0
  return 1
}

export type LevelRowForPoints = {
  teamLevelID: number
  orderIndex: number
  requiredPoints: number
}

export function sortLevelsByOrder(levels: LevelRowForPoints[]): LevelRowForPoints[] {
  return [...levels].sort((a, b) => a.orderIndex - b.orderIndex || a.teamLevelID - b.teamLevelID)
}

export function prevCumulativeBeforeOrder(
  sortedAsc: LevelRowForPoints[],
  order: number,
  excludeLevelId?: number,
): number {
  let prev = 0
  for (const l of sortedAsc) {
    if (excludeLevelId != null && l.teamLevelID === excludeLevelId) continue
    if (l.orderIndex < order) {
      prev = l.requiredPoints
    }
  }
  return prev
}

export function segmentForLevel(level: LevelRowForPoints, sortedAsc: LevelRowForPoints[]): number {
  const prev = prevCumulativeBeforeOrder(sortedAsc, level.orderIndex, level.teamLevelID)
  return level.requiredPoints - prev
}

export function cumulativeFromLevelFormInput(params: {
  mode: TeamLevelPointsModeApi
  orderIndex: number
  pointsField: number
  sortedAsc: LevelRowForPoints[]
  excludeLevelId?: number
}): number {
  const prev = prevCumulativeBeforeOrder(
    params.sortedAsc,
    params.orderIndex,
    params.excludeLevelId,
  )
  if (params.mode === 0) {
    return prev + params.pointsField
  }
  return params.pointsField
}
