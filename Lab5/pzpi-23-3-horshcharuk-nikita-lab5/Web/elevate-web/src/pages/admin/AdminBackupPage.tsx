import { useRef, useState, type FormEvent } from 'react'
import { useTranslation } from 'react-i18next'
import { FeedbackToast } from '../../components/admin/FeedbackToast'
import { api } from '../../api/client'
import { formatBackupImportSuccess, resolveAdminApiError } from '../../api/readTranslatedApiMessage'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

type ImportBackupResult = {
  mode: string
  message?: string | null
  messageKey?: string | null
  messageParams?: Record<string, string> | null
  usersCreated?: number
  teamsCreated?: number
  usersUpdated?: number
  teamsUpdated?: number
  teamLevelsAdded?: number
  teamLevelsUpdated?: number
  teamMembersAdded?: number
  teamMembersUpdated?: number
  actionTypesAdded?: number
  actionTypesUpdated?: number
  badgesAdded?: number
  badgesUpdated?: number
  userTeamBadgesAdded?: number
  userTeamBadgesUpdated?: number
  devicesAdded?: number
  devicesUpdated?: number
}

export function AdminBackupPage() {
  const { t } = useTranslation()
  const { formatDateTime } = useLocaleFormat()
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [exporting, setExporting] = useState(false)
  const [importing, setImporting] = useState(false)
  const [importMode, setImportMode] = useState<
    'merge' | 'merge-upsert' | 'replace-catalog' | 'full'
  >('merge')
  const [file, setFile] = useState<File | null>(null)
  const [fb, setFb] = useState<{ ok: boolean; text: string } | null>(null)
  const [lastResult, setLastResult] = useState<ImportBackupResult | null>(null)
  const [lastExportAt, setLastExportAt] = useState<string | null>(null)

  async function onExport() {
    setFb(null)
    setLastResult(null)
    setExporting(true)
    try {
      const { data } = await api.get<Record<string, unknown>>('admin/backup/export')
      const exportedAt =
        typeof data.exportedAtUtc === 'string'
          ? data.exportedAtUtc
          : typeof data.ExportedAtUtc === 'string'
            ? data.ExportedAtUtc
            : null
      setLastExportAt(exportedAt)
      const json = JSON.stringify(data, null, 2)
      const blob = new Blob([json], { type: 'application/json;charset=utf-8' })
      const url = URL.createObjectURL(blob)
      const stamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
      const a = document.createElement('a')
      a.href = url
      a.download = `elevate-backup-${stamp}.json`
      a.rel = 'noopener'
      document.body.appendChild(a)
      a.click()
      a.remove()
      URL.revokeObjectURL(url)
      setFb({ ok: true, text: t('admin.backupExportOk') })
    } catch {
      setFb({ ok: false, text: t('admin.backupExportFail') })
    } finally {
      setExporting(false)
    }
  }

  async function onImport(e: FormEvent) {
    e.preventDefault()
    setFb(null)
    setLastResult(null)
    if (!file) {
      setFb({ ok: false, text: t('admin.backupNoFile') })
      return
    }
    setImporting(true)
    try {
      const text = await file.text()
      let snapshot: unknown
      try {
        snapshot = JSON.parse(text) as unknown
      } catch {
        setFb({ ok: false, text: t('admin.backupInvalidJson') })
        return
      }
      if (snapshot === null || typeof snapshot !== 'object') {
        setFb({ ok: false, text: t('admin.backupInvalidJson') })
        return
      }
      const { data } = await api.post<ImportBackupResult>('admin/backup/import', {
        mode: importMode,
        snapshot,
      })
      setLastResult(data)
      setFb({ ok: true, text: formatBackupImportSuccess(data, t) })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t, 'admin.backupImportFail') })
    } finally {
      setImporting(false)
    }
  }

  function mergeResultLines(r: ImportBackupResult): { key: string; text: string }[] {
    const out: { key: string; text: string }[] = []
    const add = (key: string, count: number | undefined) => {
      if (count != null && count > 0) {
        out.push({ key, text: t(key, { count }) })
      }
    }
    add('admin.backupResultTeamsUpdated', r.teamsUpdated)
    add('admin.backupResultUsersUpdated', r.usersUpdated)
    add('admin.backupResultLevelsAdded', r.teamLevelsAdded)
    add('admin.backupResultLevelsUpdated', r.teamLevelsUpdated)
    add('admin.backupResultMembersAdded', r.teamMembersAdded)
    add('admin.backupResultMembersUpdated', r.teamMembersUpdated)
    add('admin.backupResultActionsAdded', r.actionTypesAdded)
    add('admin.backupResultActionsUpdated', r.actionTypesUpdated)
    add('admin.backupResultBadgesAdded', r.badgesAdded)
    add('admin.backupResultBadgesUpdated', r.badgesUpdated)
    add('admin.backupResultUserBadgesAdded', r.userTeamBadgesAdded)
    add('admin.backupResultUserBadgesUpdated', r.userTeamBadgesUpdated)
    add('admin.backupResultDevicesAdded', r.devicesAdded)
    add('admin.backupResultDevicesUpdated', r.devicesUpdated)
    return out
  }

  const mergeSummaryLines =
    lastResult?.mode === 'merge' || lastResult?.mode === 'merge-upsert'
      ? mergeResultLines(lastResult)
      : undefined

  const mergeHasAnyEffect =
    (mergeSummaryLines?.length ?? 0) > 0 ||
    (lastResult?.mode === 'merge-upsert' &&
      ((lastResult.usersCreated ?? 0) > 0 || (lastResult.teamsCreated ?? 0) > 0))

  const importModeHelp =
    importMode === 'merge'
      ? t('admin.backupHelpMerge')
      : importMode === 'merge-upsert'
        ? t('admin.backupHelpMergeUpsert')
        : importMode === 'replace-catalog'
          ? t('admin.backupHelpReplaceCatalog')
          : t('admin.backupHelpFull')

  return (
    <>
      <FeedbackToast state={fb} onDismiss={() => setFb(null)} />
      <div>
      <h1>{t('admin.backupTitle')}</h1>
      <p className="muted">{t('admin.backupIntro')}</p>

      <section className="card stack" style={{ marginTop: '1.25rem' }}>
        <h2>{t('admin.backupExportTitle')}</h2>
        <p className="muted small">{t('admin.backupExportDesc')}</p>
        {lastExportAt && (
          <p className="muted small">
            {t('admin.backupLastExportLabel')}: {formatDateTime(lastExportAt)}
          </p>
        )}
        <button type="button" className="btn primary" disabled={exporting} onClick={() => void onExport()}>
          {exporting ? t('admin.backupExporting') : t('admin.backupDownload')}
        </button>
      </section>

      <section className="card stack" style={{ marginTop: '1.25rem' }}>
        <h2>{t('admin.backupImportTitle')}</h2>
        <p className="muted small">{t('admin.backupImportDesc')}</p>
        <form className="form stack" onSubmit={onImport}>
          <label>
            {t('admin.backupImportMode')}
            <select
              className="select"
              value={importMode}
              onChange={(e) =>
                setImportMode(
                  e.target.value as 'merge' | 'merge-upsert' | 'replace-catalog' | 'full',
                )
              }
            >
              <option value="merge">{t('admin.backupModeMerge')}</option>
              <option value="merge-upsert">{t('admin.backupModeMergeUpsert')}</option>
              <option value="replace-catalog">{t('admin.backupModeReplaceCatalog')}</option>
              <option value="full">{t('admin.backupModeFull')}</option>
            </select>
          </label>
          <p className="muted small" style={{ margin: 0 }}>
            <strong>{t('admin.backupModeHelpTitle')}</strong>: {importModeHelp}
          </p>
          {importMode === 'full' && <p className="muted small">{t('admin.backupModeFullHint')}</p>}
          {importMode === 'replace-catalog' && (
            <p className="error small">{t('admin.backupReplaceCatalogWarn')}</p>
          )}
          <div className="backup-file-field">
            <span className="backup-file-field__label">{t('admin.backupPickFile')}</span>
            <input
              ref={fileInputRef}
              type="file"
              accept="application/json,.json"
              className="backup-file-input-native"
              aria-label={t('admin.backupChooseFile')}
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
            />
            <div className="backup-file-row">
              <button type="button" className="btn" onClick={() => fileInputRef.current?.click()}>
                {t('admin.backupChooseFile')}
              </button>
              <span className="muted small backup-file-row__name">
                {file ? file.name : t('admin.backupNoFileChosen')}
              </span>
            </div>
          </div>
          <button type="submit" className="btn" disabled={importing || !file}>
            {importing ? t('common.loading') : t('admin.backupImportRun')}
          </button>
        </form>
        {lastResult && (
          <ul className="muted small" style={{ margin: 0, paddingLeft: '1.25rem' }}>
            <li>
              {t('admin.backupResultMode')}: {lastResult.mode}
            </li>
            {(lastResult.mode === 'merge' || lastResult.mode === 'merge-upsert') &&
              (!mergeHasAnyEffect ? (
                <li>{t('admin.backupMergeNoChanges')}</li>
              ) : (
                mergeSummaryLines?.map((x) => <li key={x.key}>{x.text}</li>)
              ))}
            {lastResult.mode === 'merge-upsert' &&
              ((lastResult.usersCreated ?? 0) > 0 || (lastResult.teamsCreated ?? 0) > 0) && (
                <>
                  {(lastResult.teamsCreated ?? 0) > 0 && (
                    <li>
                      {t('admin.backupResultTeams')}: {lastResult.teamsCreated}
                    </li>
                  )}
                  {(lastResult.usersCreated ?? 0) > 0 && (
                    <li>
                      {t('admin.backupResultUsers')}: {lastResult.usersCreated}
                    </li>
                  )}
                </>
              )}
            {(lastResult.mode === 'full' || lastResult.mode === 'replace-catalog') && (
              <>
                <li>
                  {t('admin.backupResultUsers')}: {lastResult.usersCreated ?? 0}
                </li>
                <li>
                  {t('admin.backupResultTeams')}: {lastResult.teamsCreated ?? 0}
                </li>
              </>
            )}
          </ul>
        )}
      </section>
    </div>
    </>
  )
}
