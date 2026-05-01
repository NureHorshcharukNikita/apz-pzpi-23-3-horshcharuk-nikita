import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import {
  getMemberBadgeAwards,
  getTeamDetail,
  getTeamJoinRequests,
  type MemberBadgeAward,
  type TeamDetail,
  type TeamJoinRequestRow,
} from '../../api/userApi'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

type AwardsState = Record<number, MemberBadgeAward[] | 'forbidden' | 'loading'>

export function UserTeamDetailPage() {
  const { teamId: teamIdParam } = useParams()
  const teamId = Number(teamIdParam)
  const { t } = useTranslation()
  const { formatDateTime } = useLocaleFormat()
  const [team, setTeam] = useState<TeamDetail | null>(null)
  /** null = no permission (403); [] = none pending */
  const [join, setJoin] = useState<TeamJoinRequestRow[] | null | undefined>(undefined)
  const [awards, setAwards] = useState<AwardsState>({})
  const [err, setErr] = useState<string | null>(null)

  useEffect(() => {
    if (!Number.isFinite(teamId) || teamId < 1) {
      return
    }
    let cancelled = false
    ;(async () => {
      try {
        const [detail, jr] = await Promise.all([
          getTeamDetail(teamId),
          getTeamJoinRequests(teamId),
        ])
        if (cancelled) return
        setTeam(detail)
        setJoin(jr)
        const members = detail.members ?? []
        const next: AwardsState = {}
        for (const m of members) next[m.userId] = 'loading'
        setAwards(next)
        await Promise.all(
          members.map(async (m) => {
            try {
              const list = await getMemberBadgeAwards(teamId, m.userId)
              if (cancelled) return
              setAwards((prev) => ({
                ...prev,
                [m.userId]: list === null ? 'forbidden' : list,
              }))
            } catch {
              if (!cancelled) {
                setAwards((prev) => ({ ...prev, [m.userId]: [] }))
              }
            }
          }),
        )
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
        <p>
          <Link to="/app/teams">{t('common.back')}</Link>
        </p>
      </div>
    )
  }

  if (!team) {
    return <p className="muted pad">{t('common.loading')}</p>
  }

  const members = team.members ?? []

  return (
    <div className="user-page">
      <p className="small muted">
        <Link to="/app/teams">{t('user.backToTeams')}</Link>
      </p>
      <h1>{team.name}</h1>
      {team.description ? <p className="muted">{team.description}</p> : null}

      <div className="user-inline-links">
        <Link className="btn ghost small" to={`/app/teams/${teamId}/setup`}>
          {t('user.linkSetup')}
        </Link>
        <Link className="btn ghost small" to={`/app/teams/${teamId}/actions`}>
          {t('user.linkActions')}
        </Link>
        <Link className="btn ghost small" to={`/app/leaderboard?teamId=${teamId}`}>
          {t('user.linkLeaderboard')}
        </Link>
      </div>

      <section className="card pad section-gap">
        <h2>{t('user.teamMeta')}</h2>
        <dl className="user-dl">
          <dt>{t('user.colCreated')}</dt>
          <dd>{formatDateTime(team.createdAt)}</dd>
          <dt>{t('user.colMembers')}</dt>
          <dd>{team.memberCount}</dd>
          <dt>{t('user.colMaxMembers')}</dt>
          <dd>{team.maxMembers ?? t('user.unlimitedMembers')}</dd>
          <dt>{t('user.levelPointsMode')}</dt>
          <dd>
            {team.levelPointsMode === 0 ? t('user.levelPointsMode0') : t('user.levelPointsMode1')}
          </dd>
        </dl>
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.teamMembers')}</h2>
        <div className="table-wrap">
          <table className="table user-table">
            <thead>
              <tr>
                <th>{t('user.colMember')}</th>
                <th>{t('user.colRole')}</th>
                <th>{t('user.teamsPoints')}</th>
                <th>{t('user.colLevel')}</th>
                <th>{t('user.colTier')}</th>
                <th>{t('user.colExperience')}</th>
                <th>{t('user.colNextXp')}</th>
                <th>{t('user.colMaxTier')}</th>
              </tr>
            </thead>
            <tbody>
              {members.map((m) => (
                <tr key={m.userId}>
                  <td>{m.fullName}</td>
                  <td>{m.teamRole}</td>
                  <td>{m.teamPoints}</td>
                  <td>{m.level}</td>
                  <td>{m.teamLevel ?? '—'}</td>
                  <td>{m.currentXp}</td>
                  <td>{m.atMaxTier ? '—' : m.nextLevelXp}</td>
                  <td>{m.atMaxTier ? t('common.yes') : t('common.no')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="card pad section-gap">
        <h2>{t('user.teamMemberBadges')}</h2>
        <p className="small muted">{t('user.teamMemberBadgesHint')}</p>
        {members.map((m) => {
          const state = awards[m.userId]
          return (
            <div key={m.userId} className="user-member-awards">
              <h3>{m.fullName}</h3>
              {state === 'loading' || state === undefined ? (
                <p className="muted small">{t('common.loading')}</p>
              ) : state === 'forbidden' ? (
                <p className="muted small">{t('user.badgesForbidden')}</p>
              ) : state.length === 0 ? (
                <p className="muted small">{t('user.badgesNone')}</p>
              ) : (
                <ul className="user-list">
                  {state.map((a) => (
                    <li key={a.userTeamBadgeId}>
                      <strong>{a.badgeName}</strong>
                      <span className="muted small"> — {formatDateTime(a.awardedAt)}</span>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          )
        })}
      </section>

      {join === undefined ? null : join === null ? (
        <section className="card pad section-gap">
          <h2>{t('user.teamJoinRequests')}</h2>
          <p className="muted small">{t('user.joinRequestsForbidden')}</p>
        </section>
      ) : join.length === 0 ? (
        <section className="card pad section-gap">
          <h2>{t('user.teamJoinRequests')}</h2>
          <p className="muted small">{t('user.joinRequestsEmpty')}</p>
        </section>
      ) : (
        <section className="card pad section-gap">
          <h2>{t('user.teamJoinRequests')}</h2>
          <div className="table-wrap">
            <table className="table user-table">
              <thead>
                <tr>
                  <th>{t('user.colUser')}</th>
                  <th>{t('user.colStatus')}</th>
                  <th>{t('user.colRequestedAt')}</th>
                </tr>
              </thead>
              <tbody>
                {join.map((r) => (
                  <tr key={r.id}>
                    <td>{r.userFullName}</td>
                    <td>{r.status}</td>
                    <td>{formatDateTime(r.requestedAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}
    </div>
  )
}
