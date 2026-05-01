import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { getMyDashboard, type TeamDashboardRow } from '../../api/userApi'

export function UserHomePage() {
  const { t } = useTranslation()
  const [rows, setRows] = useState<TeamDashboardRow[] | null>(null)
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const data = await getMyDashboard()
        if (!cancelled) setRows(data)
      } catch (e) {
        if (!cancelled) setErr(e instanceof Error ? e.message : String(e))
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  if (err) {
    return (
      <div className="card pad">
        <p className="danger">{t('user.loadError')}</p>
        <p className="small muted">{t('user.loadErrorHint')}</p>
      </div>
    )
  }

  if (rows === null) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  if (rows.length === 0) {
    return (
      <div className="card pad">
        <h1>{t('user.homeTitle')}</h1>
        <p className="muted">{t('user.homeEmpty')}</p>
      </div>
    )
  }

  return (
    <div className="user-page">
      <h1>{t('user.homeTitle')}</h1>
      <p className="muted small">{t('user.homeIntro')}</p>
      <div className="user-dashboard-grid">
        {rows.map((r) => (
          <section key={r.teamId} className="card pad user-dash-card">
            <h2>
              <Link to={`/app/teams/${r.teamId}`}>{r.teamName}</Link>
            </h2>
            <dl className="user-dl">
              <dt>{t('user.dashLevel')}</dt>
              <dd>{r.level}</dd>
              <dt>{t('user.dashTier')}</dt>
              <dd>{r.tierName ?? '—'}</dd>
              <dt>{t('user.dashPoints')}</dt>
              <dd>{r.points}</dd>
              <dt>{t('user.dashRank')}</dt>
              <dd>{r.rank}</dd>
              <dt>{t('user.dashCurrentXp')}</dt>
              <dd>{r.currentXp}</dd>
              <dt>{t('user.dashNextXp')}</dt>
              <dd>{r.atMaxTier ? t('user.dashMaxTier') : r.nextLevelXp}</dd>
            </dl>
            {r.recentAchievements.length > 0 ? (
              <>
                <h3>{t('user.dashRecentAchievements')}</h3>
                <ul className="user-list">
                  {r.recentAchievements.map((a, i) => (
                    <li key={i}>{a}</li>
                  ))}
                </ul>
              </>
            ) : null}
            <p className="small muted top-gap">
              <Link to={`/app/teams/${r.teamId}/setup`}>{t('user.linkSetup')}</Link>
              {' · '}
              <Link to={`/app/teams/${r.teamId}/actions`}>{t('user.linkActions')}</Link>
              {' · '}
              <Link to={`/app/leaderboard?teamId=${r.teamId}`}>{t('user.linkLeaderboard')}</Link>
            </p>
          </section>
        ))}
      </div>
    </div>
  )
}
