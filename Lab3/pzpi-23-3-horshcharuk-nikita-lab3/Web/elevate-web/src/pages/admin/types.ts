export type AdminUserRow = {
  userID: number
  login: string
  email: string
  firstName: string
  lastName: string
  role: string
  isActive: boolean
  createdAt: string
  lastLoginAt?: string | null
  passwordPlain?: string | null
}

export type AdminUserOption = {
  userID: number
  login: string
  firstName: string
  lastName: string
}

export type AdminTeamSummary = {
  id: number
  name: string
  description?: string | null
  memberCount: number
}

export type AdminTeamMember = {
  userId: number
  fullName: string
  teamRole: string
}

export type AdminTeamDetail = {
  id: number
  name: string
  description?: string | null
  maxMembers?: number | null
  members: AdminTeamMember[]
}

export type AdminDeviceRow = {
  deviceID: number
  name: string
  teamID: number
  location?: string | null
  deviceKey: string
  isActive: boolean
  lastSeenAt?: string | null
}

export type AdminTeamPick = { id: number; name: string }
