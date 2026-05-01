import { useCallback, useMemo, useState, type ReactNode } from 'react'
import { api, setStoredToken } from '../api/client'
import { AuthContext } from './context'
import type { AuthUser } from './types'
import { getRoleFromToken, hasElevateWebAdminClaim } from './jwt'

const USER_KEY = 'elevate_user'

function loadUser(): AuthUser | null {
  try {
    const raw = localStorage.getItem(USER_KEY)
    if (!raw) return null
    return JSON.parse(raw) as AuthUser
  } catch {
    return null
  }
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('elevate_token'))
  const [user, setUser] = useState<AuthUser | null>(loadUser)

  const role = useMemo(() => {
    if (!token) return user?.role ?? null
    return getRoleFromToken(token) ?? user?.role ?? null
  }, [token, user])

  const canAccessWebAdmin = useMemo(
    () => (token ? hasElevateWebAdminClaim(token) : false),
    [token],
  )

  const setSession = useCallback((t: string, u: AuthUser) => {
    setStoredToken(t)
    setToken(t)
    setUser(u)
    localStorage.setItem(USER_KEY, JSON.stringify(u))
  }, [])

  const login = useCallback(
    async (loginOrEmail: string, password: string) => {
      const { data } = await api.post<{
        token: string
        user: {
          id: number
          login: string
          firstName: string
          lastName: string
          role: string
        }
      }>('auth/login', { loginOrEmail, password })
      setSession(data.token, {
        id: data.user.id,
        login: data.user.login,
        firstName: data.user.firstName,
        lastName: data.user.lastName,
        role: data.user.role,
      })
    },
    [setSession],
  )

  const logout = useCallback(() => {
    setStoredToken(null)
    setToken(null)
    setUser(null)
    localStorage.removeItem(USER_KEY)
  }, [])

  const value = useMemo(
    () => ({ token, user, role, canAccessWebAdmin, login, logout, setSession }),
    [token, user, role, canAccessWebAdmin, login, logout, setSession],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
