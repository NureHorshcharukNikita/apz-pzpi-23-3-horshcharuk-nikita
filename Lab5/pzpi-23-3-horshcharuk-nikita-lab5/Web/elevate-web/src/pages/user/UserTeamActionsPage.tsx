import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { getTeamActionTypes, getTeamDetail, type ActionTypeRow, type TeamDetail } from '../../api/userApi'

export function UserTeamActionsPage() {
  const { teamId: teamIdParam } = useParams()
  const teamId = Number(teamIdParam)
  const { t } = useTranslation()
  const [team, setTeam] = useState<TeamDetail | null>(null)
  const [types, setTypes] = useState<ActionTypeRow[] | null>(null)
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    if (!Number.isFinite(teamId) || teamId < 1) {
      return
    }
    let cancelled = false
    ;(async () => {
      try {
        const [detail, list] = await Promise.all([getTeamDetail(teamId), getTeamActionTypes(teamId)])
        if (!cancelled) {
          setTeam(detail)
          setTypes(list)
        }
      } catch (e) {
        if (!cancelled) setErr(e instanceof Error ? e.message : String(e))
      }
    })()
    return () => {
      cancelled = true
    }
  }, [teamId])

  if (!Number.isFinite(teamId) || teamId < 1) {
    return (
      <div className="card pad">
        <p>{t('user.teamInvalid')}</p>
        <Link to="/app/teams">{t('common.back')}</Link>
      </div>
    )
  }

  if (err) {
    return (
      <div className="card pad">
        <p className="danger">{t('user.loadError')}</p>
        <p className="small muted">{t('user.loadErrorHint')}</p>
        <Link to={`/app/teams/${teamId}`}>{t('user.backToTeam')}</Link>
      </div>
    )
  }

  if (!team || types === null) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  return (
    <div className="user-page">
      <p className="small muted">
        <Link to={`/app/teams/${teamId}`}>{t('user.backToTeam')}</Link>
      </p>
      <h1>
        {t('user.actionsTitle')}: {team.name}
      </h1>
      <p className="muted small">{t('user.actionsReadOnlyHint')}</p>

      {types.length === 0 ? (
        <p className="muted">{t('user.actionsEmpty')}</p>
      ) : (
        <div className="table-wrap card pad">
          <table className="table user-table">
            <thead>
              <tr>
                <th>{t('user.colCode')}</th>
                <th>{t('user.colName')}</th>
                <th>{t('user.colDescription')}</th>
                <th>{t('user.colCategory')}</th>
                <th>{t('user.colDefaultPoints')}</th>
                <th>{t('user.colActive')}</th>
              </tr>
            </thead>
            <tbody>
              {types.map((a) => (
                <tr key={a.id}>
                  <td className="mono">{a.code}</td>
                  <td>{a.name}</td>
                  <td>{a.description ?? '—'}</td>
                  <td>{a.category ?? '—'}</td>
                  <td>{a.defaultPoints}</td>
                  <td>{a.isActive ? t('common.yes') : t('common.no')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
