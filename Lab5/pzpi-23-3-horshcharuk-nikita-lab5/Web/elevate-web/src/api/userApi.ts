import { isAxiosError } from 'axios'
import { api } from './client'

export type UserTeamMembership = {
  teamId: number
  teamName: string
  teamRole: string
  teamPoints: number
  level: number | null
  teamLevel: string | null
  createdByUserId: number | null
}

export type UserTeamBadge = {
  teamId: number
  teamName: string
  badgeName: string
  awardedAt: string
}

export type UserProfileMe = {
  id: number
  login: string
  firstName: string
  lastName: string
  email: string
  role: string
  isActive: boolean
  createdAt: string
  lastLoginAt: string | null
  avatarUrl: string | null
  teams: UserTeamMembership[]
  recentBadges: UserTeamBadge[]
}

export type TeamDashboardRow = {
  teamId: number
  teamName: string
  level: number
  points: number
  rank: number
  currentXp: number
  nextLevelXp: number
  atMaxTier: boolean
  tierName: string | null
  recentAchievements: string[]
}

export type UserAchievement = {
  id: string
  title: string
  description: string
  earned: boolean
  earnedAt: string | null
  teamId: number
  teamName: string
  requirement: string | null
}

export type UserActivityItem = {
  id: string
  teamId: number
  teamName: string
  type: string
  description: string
  points: number
  date: string
}

export type MyPendingJoinRequest = {
  id: number
  teamId: number
  teamName: string
  status: string
  requestedAt: string
}

export type TeamListItem = {
  id: number
  name: string
  description: string | null
  createdAt: string
  createdByUserId: number | null
  memberCount: number
  maxMembers: number | null
}

export type TeamMemberRow = {
  userId: number
  fullName: string
  teamRole: string
  teamPoints: number
  level: number
  teamLevel: string | null
  currentXp: number
  nextLevelXp: number
  atMaxTier: boolean
}

export type TeamLevelRow = {
  id: number
  name: string
  requiredPoints: number
  orderIndex: number
}

export type TeamBadgeRow = {
  id: number
  code: string
  name: string
  description: string | null
  iconCode: string | null
  conditionType: string | null
  conditionValue: number | null
}

export type TeamDetail = TeamListItem & {
  members: TeamMemberRow[]
  levels: TeamLevelRow[]
  badges: TeamBadgeRow[]
  levelPointsMode: number
}

export type TeamJoinRequestRow = {
  id: number
  teamId: number
  userId: number
  userFullName: string
  status: string
  requestedAt: string
}

export type MemberBadgeAward = {
  userTeamBadgeId: number
  teamBadgeId: number
  badgeName: string
  awardedAt: string
}

export type LeaderboardEntry = {
  userId: number
  fullName: string
  teamPoints: number
  level: number
  teamLevel: string | null
  currentXp: number
  nextLevelXp: number
  atMaxTier: boolean
  rank: number
}

export type ActionTypeRow = {
  id: number
  teamId: number
  code: string
  name: string
  description: string | null
  defaultPoints: number
  category: string | null
  isActive: boolean
}

export async function getMyProfile(): Promise<UserProfileMe> {
  const { data } = await api.get<UserProfileMe>('/users/me')
  return data
}

export async function getMyDashboard(): Promise<TeamDashboardRow[]> {
  const { data } = await api.get<TeamDashboardRow[]>('/users/me/dashboard')
  return Array.isArray(data) ? data : []
}

export async function getMyBadges(): Promise<UserAchievement[]> {
  try {
    const { data } = await api.get<UserAchievement[]>('/users/me/badges')
    if (Array.isArray(data) && data.length > 0) return data
    return achievementsFromDashboardFallback(await getMyDashboard())
  } catch (e) {
    if (isAxiosError(e) && e.response?.status === 404) {
      return achievementsFromDashboardFallback(await getMyDashboard())
    }
    throw e
  }
}

async function achievementsFromDashboardFallback(
  rows: TeamDashboardRow[],
): Promise<UserAchievement[]> {
  const out: UserAchievement[] = []
  let seq = 0
  for (const row of rows) {
    for (const title of row.recentAchievements ?? []) {
      const t = title.trim()
      if (!t) continue
      out.push({
        id: `dash-${seq++}`,
        title: t,
        description: '',
        earned: true,
        earnedAt: null,
        teamId: row.teamId,
        teamName: row.teamName,
        requirement: null,
      })
    }
  }
  return out
}

export async function getMyActivity(teamId?: number): Promise<UserActivityItem[]> {
  const { data } = await api.get<UserActivityItem[]>('/users/me/activity', {
    params: teamId != null ? { teamId } : undefined,
  })
  return Array.isArray(data) ? data : []
}

export async function getMyJoinRequests(): Promise<MyPendingJoinRequest[]> {
  try {
    const { data } = await api.get<MyPendingJoinRequest[]>('/users/me/join-requests')
    return Array.isArray(data) ? data : []
  } catch (e) {
    if (isAxiosError(e) && (e.response?.status === 404 || e.response?.status === 405)) {
      return []
    }
    throw e
  }
}

export async function listTeamsCatalog(): Promise<TeamListItem[]> {
  const { data } = await api.get<TeamListItem[]>('/teams')
  return Array.isArray(data) ? data : []
}

export async function getTeamDetail(teamId: number): Promise<TeamDetail> {
  const { data } = await api.get<TeamDetail>(`/teams/${teamId}`)
  return data
}

export async function getTeamJoinRequests(teamId: number): Promise<TeamJoinRequestRow[] | null> {
  try {
    const { data } = await api.get<TeamJoinRequestRow[]>(`/teams/${teamId}/join-requests`)
    return Array.isArray(data) ? data : []
  } catch (e) {
    if (isAxiosError(e) && e.response?.status === 403) return null
    throw e
  }
}

export async function getTeamLeaderboard(teamId: number): Promise<LeaderboardEntry[]> {
  const { data } = await api.get<LeaderboardEntry[]>(`/teams/${teamId}/leaderboard`)
  return Array.isArray(data) ? data : []
}

export async function getTeamActionTypes(teamId: number): Promise<ActionTypeRow[]> {
  const { data } = await api.get<ActionTypeRow[]>(`/teams/${teamId}/action-types`)
  return Array.isArray(data) ? data : []
}

export async function getTeamGamificationActionTypes(teamId: number): Promise<ActionTypeRow[]> {
  const { data } = await api.get<ActionTypeRow[]>(`/teams/${teamId}/gamification/action-types`)
  return Array.isArray(data) ? data : []
}

export async function getMemberBadgeAwards(
  teamId: number,
  userId: number,
): Promise<MemberBadgeAward[] | null> {
  try {
    const { data } = await api.get<MemberBadgeAward[]>(
      `/teams/${teamId}/members/${userId}/badge-awards`,
    )
    return Array.isArray(data) ? data : []
  } catch (e) {
    if (isAxiosError(e) && e.response?.status === 403) return null
    throw e
  }
}

export async function fetchAvatarObjectUrl(): Promise<string | null> {
  try {
    const res = await api.get<ArrayBuffer>('/users/avatar', { responseType: 'arraybuffer' })
    const ct = (res.headers['content-type'] as string | undefined) ?? 'image/jpeg'
    const blob = new Blob([res.data], { type: ct })
    return URL.createObjectURL(blob)
  } catch {
    return null
  }
}
