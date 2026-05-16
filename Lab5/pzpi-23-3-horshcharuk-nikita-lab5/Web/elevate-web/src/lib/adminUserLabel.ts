import type { AdminUserOption } from '../pages/admin/types'

export function adminUserDisplayName(u: Pick<AdminUserOption, 'firstName' | 'lastName' | 'login'>): string {
  const n = `${u.firstName} ${u.lastName}`.trim()
  return n || u.login
}
