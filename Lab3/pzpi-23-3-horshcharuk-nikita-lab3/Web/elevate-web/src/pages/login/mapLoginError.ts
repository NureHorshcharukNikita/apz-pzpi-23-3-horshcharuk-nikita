import axios from 'axios'

export function mapLoginError(err: unknown, t: (key: string) => string): string {
  if (axios.isAxiosError(err)) {
    const status = err.response?.status
    if (status === 401) return t('auth.errorInvalidCredentials')
    if (status !== undefined && status >= 500) return t('auth.errorServer')
    if (err.code === 'ERR_NETWORK' || err.response === undefined) return t('auth.errorNetwork')
    return t('auth.errorUnexpected')
  }
  return t('auth.errorUnexpected')
}
