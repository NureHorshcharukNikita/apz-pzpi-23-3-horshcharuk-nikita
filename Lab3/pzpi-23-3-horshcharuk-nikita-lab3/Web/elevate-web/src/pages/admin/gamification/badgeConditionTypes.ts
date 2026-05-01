export const BADGE_CONDITION_POINTS = 'PointsReached'
export const BADGE_CONDITION_LEVEL = 'LevelOrder'

export function isBadgeLevelCondition(conditionType: string | null | undefined): boolean {
  const s = (conditionType ?? '').trim().toLowerCase()
  return s === 'levelorder' || s === 'teamlevel'
}
