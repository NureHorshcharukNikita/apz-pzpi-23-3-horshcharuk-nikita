export function resolveApiBaseUrl(): string {
  const fromEnv = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim()
  if (fromEnv) return fromEnv.replace(/\/$/, '')
  const base = (import.meta.env.BASE_URL ?? '/').replace(/\/$/, '')
  return `${base}/api`
}
