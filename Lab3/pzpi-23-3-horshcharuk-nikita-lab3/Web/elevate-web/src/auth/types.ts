export type AuthUser = {
  id: number
  login: string
  firstName: string
  lastName: string
  role: string
}

export type AuthContextValue = {
  token: string | null
  user: AuthUser | null
  role: string | null
  canAccessWebAdmin: boolean
  login: (loginOrEmail: string, password: string) => Promise<void>
  logout: () => void
  setSession: (token: string, user: AuthUser) => void
}
