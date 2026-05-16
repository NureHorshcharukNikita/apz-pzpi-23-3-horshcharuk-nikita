import { useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { fetchAvatarObjectUrl, getMyProfile, type UserProfileMe } from '../../api/userApi'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

export function UserProfilePage() {
  const { t } = useTranslation()
  const { formatDateTime } = useLocaleFormat()
  const [profile, setProfile] = useState<UserProfileMe | null>(null)
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null)
  const [err, setErr] = useState<string | null>(null)
  const avatarRef = useRef<string | null>(null)

  useEffect(() => {
    let alive = true
    ;(async () => {
      try {
        const p = await getMyProfile()
        if (!alive) return
        setProfile(p)
        const u = await fetchAvatarObjectUrl()
        if (!alive) {
          if (u) URL.revokeObjectURL(u)
          return
        }
        if (avatarRef.current) URL.revokeObjectURL(avatarRef.current)
        avatarRef.current = u
        setAvatarUrl(u)
      } catch (e) {
        if (!alive) return
        setErr(e instanceof Error ? e.message : String(e))
      }
    })()
    return () => {
      alive = false
      if (avatarRef.current) {
        URL.revokeObjectURL(avatarRef.current)
        avatarRef.current = null
      }
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

  if (!profile) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  return (
    <div className="user-page">
      <h1>{t('user.profileTitle')}</h1>
      <div className="user-profile-head card pad">
        {avatarUrl ? (
          <img src={avatarUrl} alt="" className="user-avatar" width={120} height={120} />
        ) : (
          <div className="user-avatar-placeholder muted small">{t('user.avatarNone')}</div>
        )}
        <dl className="user-dl">
          <dt>{t('user.colLogin')}</dt>
          <dd>{profile.login}</dd>
          <dt>{t('user.colEmail')}</dt>
          <dd>{profile.email}</dd>
          <dt>{t('user.colName')}</dt>
          <dd>
            {profile.firstName} {profile.lastName}
          </dd>
          <dt>{t('user.colRole')}</dt>
          <dd>{profile.role}</dd>
          <dt>{t('user.colActiveAccount')}</dt>
          <dd>{profile.isActive ? t('common.yes') : t('common.no')}</dd>
          <dt>{t('user.colCreated')}</dt>
          <dd>{formatDateTime(profile.createdAt)}</dd>
          <dt>{t('user.colLastLogin')}</dt>
          <dd>{profile.lastLoginAt ? formatDateTime(profile.lastLoginAt) : '—'}</dd>
        </dl>
      </div>

      <section className="card pad section-gap">
        <h2>{t('user.profileTeamsSection')}</h2>
        {profile.teams.length === 0 ? (
          <p className="muted">{t('user.teamsMyEmpty')}</p>
        ) : (
          <ul className="user-list">
            {profile.teams.map((tm) => (
              <li key={tm.teamId}>
                <strong>{tm.teamName}</strong> — {tm.teamRole}; {t('user.teamsPoints')}: {tm.teamPoints}
                {tm.level != null ? `; ${t('user.colLevel')}: ${tm.level}` : ''}
                {tm.teamLevel ? ` (${tm.teamLevel})` : ''}
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.profileRecentBadges')}</h2>
        {profile.recentBadges.length === 0 ? (
          <p className="muted">{t('user.profileRecentBadgesEmpty')}</p>
        ) : (
          <ul className="user-list">
            {profile.recentBadges.map((b, i) => (
              <li key={i}>
                <strong>{b.badgeName}</strong>
                <span className="muted">
                  {' '}
                  — {b.teamName} · {formatDateTime(b.awardedAt)}
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  )
}
