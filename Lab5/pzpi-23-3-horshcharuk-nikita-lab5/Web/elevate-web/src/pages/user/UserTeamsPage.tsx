import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import {
  getMyJoinRequests,
  getMyProfile,
  listTeamsCatalog,
  type MyPendingJoinRequest,
  type TeamListItem,
  type UserProfileMe,
} from '../../api/userApi'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

export function UserTeamsPage() {
  const { t } = useTranslation()
  const { formatDateTime, compareStrings } = useLocaleFormat()
  const [profile, setProfile] = useState<UserProfileMe | null>(null)
  const [catalog, setCatalog] = useState<TeamListItem[] | null>(null)
  const [joinReq, setJoinReq] = useState<MyPendingJoinRequest[] | null>(null)
  const [discoverQ, setDiscoverQ] = useState('')
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const [p, c, j] = await Promise.all([
          getMyProfile(),
          listTeamsCatalog(),
          getMyJoinRequests(),
        ])
        if (!cancelled) {
          setProfile(p)
          setCatalog(c)
          setJoinReq(j)
        }
      } catch (e) {
        if (!cancelled) setErr(e instanceof Error ? e.message : String(e))
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  const filteredCatalog = useMemo(() => {
    if (!catalog) return []
    const q = discoverQ.trim().toLowerCase()
    if (!q) return [...catalog].sort((a, b) => compareStrings(a.name, b.name))
    return catalog
      .filter((x) => x.name.toLowerCase().includes(q))
      .sort((a, b) => compareStrings(a.name, b.name))
  }, [catalog, discoverQ, compareStrings])

  if (err) {
    return (
      <div className="card pad">
        <p className="danger">{t('user.loadError')}</p>
        <p className="small muted">{t('user.loadErrorHint')}</p>
      </div>
    )
  }

  if (profile === null || catalog === null || joinReq === null) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  return (
    <div className="user-page">
      <h1>{t('user.teamsTitle')}</h1>

      <section className="card pad section-gap">
        <h2>{t('user.teamsMySection')}</h2>
        {profile.teams.length === 0 ? (
          <p className="muted">{t('user.teamsMyEmpty')}</p>
        ) : (
          <ul className="user-link-list">
            {profile.teams.map((tm) => (
              <li key={tm.teamId}>
                <Link to={`/app/teams/${tm.teamId}`}>
                  <strong>{tm.teamName}</strong>
                </Link>
                <span className="muted small">
                  {' '}
                  — {tm.teamRole} · {t('user.teamsPoints')}: {tm.teamPoints}
                  {tm.teamLevel != null ? ` · ${tm.teamLevel}` : ''}
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.teamsJoinRequestsSection')}</h2>
        {joinReq.length === 0 ? (
          <p className="muted">{t('user.teamsJoinRequestsEmpty')}</p>
        ) : (
          <table className="table user-table">
            <thead>
              <tr>
                <th>{t('user.colTeam')}</th>
                <th>{t('user.colStatus')}</th>
                <th>{t('user.colRequestedAt')}</th>
              </tr>
            </thead>
            <tbody>
              {joinReq.map((r) => (
                <tr key={r.id}>
                  <td>
                    <Link to={`/app/teams/${r.teamId}`}>{r.teamName}</Link>
                  </td>
                  <td>{r.status}</td>
                  <td>{formatDateTime(r.requestedAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.teamsDiscoverSection')}</h2>
        <label className="user-field">
          <span className="small muted">{t('user.teamsDiscoverFilter')}</span>
          <input
            className="input"
            value={discoverQ}
            onChange={(e) => setDiscoverQ(e.target.value)}
            dir="auto"
          />
        </label>
        <div className="table-wrap">
          <table className="table user-table">
            <thead>
              <tr>
                <th>{t('user.colName')}</th>
                <th>{t('user.colMembers')}</th>
                <th>{t('user.colMaxMembers')}</th>
                <th>{t('user.colCreated')}</th>
              </tr>
            </thead>
            <tbody>
              {filteredCatalog.map((team) => (
                <tr key={team.id}>
                  <td>
                    <Link to={`/app/teams/${team.id}`}>{team.name}</Link>
                    {team.description ? (
                      <div className="small muted">{team.description}</div>
                    ) : null}
                  </td>
                  <td>{team.memberCount}</td>
                  <td>{team.maxMembers ?? '—'}</td>
                  <td className="small">{formatDateTime(team.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  )
}
