export type GamificationLevelRow = {
  teamLevelID: number
  teamID: number
  name: string
  requiredPoints: number
  orderIndex: number
}

export type GamificationBadgeRow = {
  teamBadgeID: number
  teamID: number
  code: string
  name: string
  description?: string | null
  iconCode?: string | null
  conditionType?: string | null
  conditionValue?: number | null
}

export type GamificationActionRow = {
  actionTypeID: number
  teamID: number
  code: string
  name: string
  description?: string | null
  defaultPoints: number
  category?: string | null
  isActive: boolean
}

export type NewLevelForm = { name: string; requiredPoints: string; orderIndex: string }

export type NewBadgeForm = {
  code: string
  name: string
  description: string
  iconCode: string
  conditionType: string
  conditionValue: string
}

export type NewActionForm = {
  code: string
  name: string
  description: string
  defaultPoints: string
  category: string
  isActive: boolean
}
