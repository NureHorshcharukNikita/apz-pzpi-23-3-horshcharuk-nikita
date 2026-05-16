import { isAxiosError } from 'axios'
import type { TFunction } from 'i18next'

function normalizeMessageParams(raw: unknown): Record<string, string> {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return {}
  const out: Record<string, string> = {}
  for (const [k, v] of Object.entries(raw as Record<string, unknown>)) {
    if (v != null && (typeof v === 'string' || typeof v === 'number' || typeof v === 'boolean')) {
      out[k] = String(v)
    }
  }
  return out
}

export function readTranslatedApiMessage(err: unknown, t: TFunction): string | null {
  if (!isAxiosError(err)) return null
  const d = err.response?.data
  if (!d || typeof d !== 'object') return null
  const rec = d as Record<string, unknown>
  if (typeof rec.messageKey === 'string' && rec.messageKey.length > 0) {
    return t(rec.messageKey, normalizeMessageParams(rec.messageParams))
  }
  if (typeof rec.message === 'string' && rec.message.length > 0) {
    const status = err.response?.status
    if (status === 404 && rec.message.trim() === 'Resource not found') {
      return t('admin.apiErrorNotFound')
    }
    return rec.message
  }
  return null
}

export function resolveAdminApiError(
  err: unknown,
  t: TFunction,
  fallbackKey: string = 'admin.saveFail',
): string {
  const fromKey = readTranslatedApiMessage(err, t)
  if (fromKey) return fromKey

  if (!isAxiosError(err)) return t(fallbackKey)

  const res = err.response
  const d = res?.data

  if (typeof d === 'string' && d.trim()) return d.trim()

  if (d && typeof d === 'object' && !Array.isArray(d)) {
    const rec = d as Record<string, unknown>
    if (typeof rec.detail === 'string' && rec.detail.trim()) return rec.detail.trim()
    if (typeof rec.title === 'string' && rec.title.trim()) return rec.title.trim()
    const errs = rec.errors
    if (errs && typeof errs === 'object' && !Array.isArray(errs)) {
      const parts: string[] = []
      for (const v of Object.values(errs as Record<string, unknown>)) {
        if (Array.isArray(v)) {
          for (const x of v) {
            if (typeof x === 'string' && x.trim()) parts.push(x.trim())
          }
        }
      }
      if (parts.length) return parts.join(' ')
    }
  }

  if (res == null && err.request) return t('admin.apiErrorNetwork')

  const status = res?.status
  if (status === 404) return t('admin.apiErrorNotFound')
  if (status === 400) return t('admin.apiErrorBadRequest')
  if (status === 409) return t('admin.apiErrorConflict')
  if (typeof status === 'number' && status >= 500) return t('admin.apiErrorServer')

  return t(fallbackKey)
}

export function formatBackupImportSuccess(
  data: {
    messageKey?: string | null
    messageParams?: Record<string, string> | null
    message?: string | null
  },
  t: TFunction,
): string {
  if (typeof data.messageKey === 'string' && data.messageKey.length > 0) {
    return t(data.messageKey, normalizeMessageParams(data.messageParams))
  }
  const m = data.message?.trim()
  if (m) return m
  return t('admin.backupImportOk')
}
