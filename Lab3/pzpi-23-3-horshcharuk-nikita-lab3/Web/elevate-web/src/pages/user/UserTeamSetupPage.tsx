import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { getTeamDetail, getTeamGamificationActionTypes, type ActionTypeRow, type TeamDetail } from '../../api/userApi'

export function UserTeamSetupPage() {
  const { teamId: teamIdParam } = useParams()
  const teamId = Number(teamIdParam)
  const { t } = useTranslation()
  const [team, setTeam] = useState<TeamDetail | null>(null)
  const [setupActions, setSetupActions] = useState<ActionTypeRow[] | null>(null)
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    if (!Number.isFinite(teamId) || teamId < 1) {
      return
    }
    let cancelled = false
    ;(async () => {
      try {
        const [detail, acts] = await Promise.all([
          getTeamDetail(teamId),
          getTeamGamificationActionTypes(teamId),
        ])
        if (!cancelled) {
          setTeam(detail)
          setSetupActions(acts)
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

  if (!team || setupActions === null) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  const levels = [...(team.levels ?? [])].sort((a, b) => a.orderIndex - b.orderIndex)

  return (
    <div className="user-page">
      <p className="small muted">
        <Link to={`/app/teams/${teamId}`}>{t('user.backToTeam')}</Link>
      </p>
      <h1>
        {t('user.setupTitle')}: {team.name}
      </h1>
      <p className="muted small">{t('user.setupReadOnlyHint')}</p>

      <section className="card pad section-gap">
        <h2>{t('user.setupLevels')}</h2>
        {levels.length === 0 ? (
          <p className="muted">{t('user.setupEmptyLevels')}</p>
        ) : (
          <div className="table-wrap">
            <table className="table user-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>{t('user.colName')}</th>
                  <th>{t('user.colRequiredPoints')}</th>
                  <th>{t('user.colOrder')}</th>
                </tr>
              </thead>
              <tbody>
                {levels.map((lv) => (
                  <tr key={lv.id}>
                    <td>{lv.id}</td>
                    <td>{lv.name}</td>
                    <td>{lv.requiredPoints}</td>
                    <td>{lv.orderIndex}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.setupBadges')}</h2>
        {(team.badges ?? []).length === 0 ? (
          <p className="muted">{t('user.setupEmptyBadges')}</p>
        ) : (
          <div className="table-wrap">
            <table className="table user-table">
              <thead>
                <tr>
                  <th>{t('user.colCode')}</th>
                  <th>{t('user.colName')}</th>
                  <th>{t('user.colDescription')}</th>
                  <th>{t('user.colIcon')}</th>
                  <th>{t('user.colCondition')}</th>
                  <th>{t('user.colConditionValue')}</th>
                </tr>
              </thead>
              <tbody>
                {(team.badges ?? []).map((b) => (
                  <tr key={b.id}>
                    <td className="mono">{b.code}</td>
                    <td>{b.name}</td>
                    <td>{b.description ?? '—'}</td>
                    <td>{b.iconCode ?? '—'}</td>
                    <td>{b.conditionType ?? '—'}</td>
                    <td>{b.conditionValue ?? '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.setupActionTypesCatalog')}</h2>
        <p className="small muted">{t('user.setupActionTypesCatalogHint')}</p>
        {setupActions.length === 0 ? (
          <p className="muted">{t('user.setupEmptyActions')}</p>
        ) : (
          <div className="table-wrap">
            <table className="table user-table">
              <thead>
                <tr>
                  <th>{t('user.colCode')}</th>
                  <th>{t('user.colName')}</th>
                  <th>{t('user.colCategory')}</th>
                  <th>{t('user.colDefaultPoints')}</th>
                  <th>{t('user.colActive')}</th>
                </tr>
              </thead>
              <tbody>
                {setupActions.map((a) => (
                  <tr key={a.id}>
                    <td className="mono">{a.code}</td>
                    <td>{a.name}</td>
                    <td>{a.category ?? '—'}</td>
                    <td>{a.defaultPoints}</td>
                    <td>{a.isActive ? t('common.yes') : t('common.no')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  )
}
