const ROLE_CLAIM =
  'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'

export const ELEVATE_WEB_ADMIN_CLAIM = 'elevate_web_admin'

export function decodeJwtPayload(token: string): Record<string, unknown> | null {
  try {
    const part = token.split('.')[1]
    if (!part) return null
    const b64 = part.replace(/-/g, '+').replace(/_/g, '/')
    const padded = b64 + '='.repeat((4 - (b64.length % 4)) % 4)
    const json = decodeURIComponent(
      atob(padded)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join(''),
    )
    return JSON.parse(json) as Record<string, unknown>
  } catch {
    return null
  }
}

export function getRoleFromToken(token: string): string | null {
  const p = decodeJwtPayload(token)
  if (!p) return null
  const r = p[ROLE_CLAIM] ?? p.role ?? p.Role
  return typeof r === 'string' ? r : null
}

export function hasElevateWebAdminClaim(token: string): boolean {
  const p = decodeJwtPayload(token)
  return p?.[ELEVATE_WEB_ADMIN_CLAIM] === 'true'
}
