import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { getMyBadges, type UserAchievement } from '../../api/userApi'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

export function UserAchievementsPage() {
  const { t } = useTranslation()
  const { formatDateTime } = useLocaleFormat()
  const [list, setList] = useState<UserAchievement[] | null>(null)
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const data = await getMyBadges()
        if (!cancelled) setList(data)
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

  if (list === null) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  if (list.length === 0) {
    return (
      <div className="user-page">
        <h1>{t('user.achievementsTitle')}</h1>
        <p className="muted">{t('user.achievementsEmpty')}</p>
      </div>
    )
  }

  return (
    <div className="user-page">
      <h1>{t('user.achievementsTitle')}</h1>
      <p className="muted small">{t('user.achievementsIntro')}</p>
      <ul className="user-achievement-list">
        {list.map((a) => (
          <li key={a.id} className="card pad">
            <div className="user-achievement-head">
              <strong>{a.title}</strong>
              <span className={`user-badge ${a.earned ? 'earned' : 'locked'}`}>
                {a.earned ? t('user.achievementEarned') : t('user.achievementLocked')}
              </span>
            </div>
            {a.description ? <p className="small">{a.description}</p> : null}
            <p className="small muted">
              {a.teamName}
              {a.earnedAt ? ` · ${formatDateTime(a.earnedAt)}` : ''}
            </p>
            {a.requirement ? (
              <p className="small muted">
                {t('user.colRequirement')}: {a.requirement}
              </p>
            ) : null}
          </li>
        ))}
      </ul>
    </div>
  )
}
