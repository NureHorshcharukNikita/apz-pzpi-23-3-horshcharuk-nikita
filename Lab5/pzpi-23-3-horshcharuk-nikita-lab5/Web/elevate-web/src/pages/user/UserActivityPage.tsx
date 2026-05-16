import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { getMyActivity, getMyProfile, type UserActivityItem, type UserProfileMe } from '../../api/userApi'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

export function UserActivityPage() {
  const { t } = useTranslation()
  const { formatDateTime, compareStrings } = useLocaleFormat()
  const [profile, setProfile] = useState<UserProfileMe | null>(null)
  const [profileFailed, setProfileFailed] = useState(false)
  const [teamFilter, setTeamFilter] = useState<number | ''>('')
  const [items, setItems] = useState<UserActivityItem[] | null>(null)
  const [activityFailed, setActivityFailed] = useState(false)

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const p = await getMyProfile()
        if (!cancelled) setProfile(p)
      } catch {
        if (!cancelled) setProfileFailed(true)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    if (!profile) return
    let cancelled = false
    setItems(null)
    setActivityFailed(false)
    ;(async () => {
      try {
        const data = await getMyActivity(teamFilter === '' ? undefined : teamFilter)
        if (!cancelled) {
          setItems(
            [...data].sort(
              (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime() || b.id.localeCompare(a.id),
            ),
          )
        }
      } catch {
        if (!cancelled) {
          setActivityFailed(true)
          setItems([])
        }
      }
    })()
    return () => {
      cancelled = true
    }
  }, [profile, teamFilter])

  if (profileFailed) {
    return (
      <div className="card pad">
        <p className="danger">{t('user.loadError')}</p>
        <p className="small muted">{t('user.loadErrorHint')}</p>
      </div>
    )
  }

  if (!profile || items === null) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  return (
    <div className="user-page">
      <h1>{t('user.activityTitle')}</h1>
      <p className="muted small">{t('user.activityIntro')}</p>

      <label className="user-field section-gap">
        <span className="small">{t('user.activityFilterTeam')}</span>
        <select
          className="select"
          value={teamFilter === '' ? '' : String(teamFilter)}
          onChange={(e) => {
            const v = e.target.value
            setTeamFilter(v === '' ? '' : Number(v))
          }}
        >
          <option value="">{t('user.activityAllTeams')}</option>
          {profile.teams
            .slice()
            .sort((a, b) => compareStrings(a.teamName, b.teamName))
            .map((tm) => (
              <option key={tm.teamId} value={String(tm.teamId)}>
                {tm.teamName}
              </option>
            ))}
        </select>
      </label>

      {activityFailed ? (
        <div className="section-gap">
          <p className="danger small">{t('user.loadError')}</p>
          <p className="muted small">{t('user.loadErrorHint')}</p>
        </div>
      ) : items.length === 0 ? (
        <p className="muted">{t('user.activityEmpty')}</p>
      ) : (
        <div className="table-wrap card pad">
          <table className="table user-table">
            <thead>
              <tr>
                <th>{t('user.colDate')}</th>
                <th>{t('user.colTeam')}</th>
                <th>{t('user.colType')}</th>
                <th>{t('user.colDescription')}</th>
                <th>{t('user.colPoints')}</th>
              </tr>
            </thead>
            <tbody>
              {items.map((row) => (
                <tr key={row.id}>
                  <td>{formatDateTime(row.date)}</td>
                  <td>{row.teamName}</td>
                  <td>{row.type}</td>
                  <td>{row.description}</td>
                  <td>{row.points}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
