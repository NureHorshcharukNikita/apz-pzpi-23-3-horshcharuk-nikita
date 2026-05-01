import { useEffect, useMemo, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { getMyProfile, getTeamLeaderboard, type LeaderboardEntry, type UserProfileMe } from '../../api/userApi'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'

export function UserLeaderboardPage() {
  const { t } = useTranslation()
  const { compareStrings } = useLocaleFormat()
  const [searchParams, setSearchParams] = useSearchParams()
  const [profile, setProfile] = useState<UserProfileMe | null>(null)
  const [rows, setRows] = useState<LeaderboardEntry[] | null>(null)
  const [loadErr, setLoadErr] = useState<string | null>(null)
  const [boardErr, setBoardErr] = useState<string | null>(null)

  const teamOptions = useMemo(() => {
    if (!profile) return []
    return [...profile.teams].sort((a, b) => compareStrings(a.teamName, b.teamName))
  }, [profile, compareStrings])

  const teamIdParam = searchParams.get('teamId')
  const selectedTeamId = teamIdParam ? Number(teamIdParam) : NaN

  useEffect(() => {
    let cancelled = false
    ;(async () => {
      try {
        const p = await getMyProfile()
        if (!cancelled) setProfile(p)
      } catch (e) {
        if (!cancelled) setLoadErr(e instanceof Error ? e.message : String(e))
      }
    })()
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => {
    if (!profile?.teams.length) return
    if (teamIdParam) return
    const first = profile.teams[0].teamId
    setSearchParams({ teamId: String(first) }, { replace: true })
  }, [profile, teamIdParam, setSearchParams])

  useEffect(() => {
    if (!Number.isFinite(selectedTeamId) || selectedTeamId < 1) {
      setRows(null)
      return
    }
    let cancelled = false
    setBoardErr(null)
    setRows(null)
    ;(async () => {
      try {
        const data = await getTeamLeaderboard(selectedTeamId)
        if (!cancelled) setRows(data)
      } catch (e) {
        if (!cancelled) setBoardErr(e instanceof Error ? e.message : String(e))
      }
    })()
    return () => {
      cancelled = true
    }
  }, [selectedTeamId])

  if (loadErr) {
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

  if (teamOptions.length === 0) {
    return (
      <div className="user-page">
        <h1>{t('user.leaderboardTitle')}</h1>
        <p className="muted">{t('user.leaderboardNoTeams')}</p>
      </div>
    )
  }

  const validSelected =
    Number.isFinite(selectedTeamId) && teamOptions.some((x) => x.teamId === selectedTeamId)
  const selectValue = validSelected ? String(selectedTeamId) : String(teamOptions[0].teamId)

  return (
    <div className="user-page">
      <h1>{t('user.leaderboardTitle')}</h1>
      <p className="muted small">{t('user.leaderboardIntro')}</p>

      <label className="user-field section-gap">
        <span className="small">{t('user.leaderboardPickTeam')}</span>
        <select
          className="select"
          value={selectValue}
          onChange={(e) => setSearchParams({ teamId: e.target.value })}
        >
          {teamOptions.map((tm) => (
            <option key={tm.teamId} value={String(tm.teamId)}>
              {tm.teamName}
            </option>
          ))}
        </select>
      </label>

      {boardErr ? (
        <div className="section-gap">
          <p className="danger small">{t('user.loadError')}</p>
          <p className="muted small">{t('user.loadErrorHint')}</p>
        </div>
      ) : rows === null ? (
        <p className="muted">{t('common.loading')}</p>
      ) : rows.length === 0 ? (
        <p className="muted">{t('user.leaderboardEmpty')}</p>
      ) : (
        <div className="table-wrap card pad">
          <table className="table user-table">
            <thead>
              <tr>
                <th>{t('user.colRank')}</th>
                <th>{t('user.colMember')}</th>
                <th>{t('user.teamsPoints')}</th>
                <th>{t('user.colLevel')}</th>
                <th>{t('user.colTier')}</th>
                <th>{t('user.colExperience')}</th>
                <th>{t('user.colNextXp')}</th>
                <th>{t('user.colMaxTier')}</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={`${r.userId}-${r.rank}`}>
                  <td>{r.rank}</td>
                  <td>{r.fullName}</td>
                  <td>{r.teamPoints}</td>
                  <td>{r.level}</td>
                  <td>{r.teamLevel ?? '—'}</td>
                  <td>{r.currentXp}</td>
                  <td>{r.atMaxTier ? '—' : r.nextLevelXp}</td>
                  <td>{r.atMaxTier ? t('common.yes') : t('common.no')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
