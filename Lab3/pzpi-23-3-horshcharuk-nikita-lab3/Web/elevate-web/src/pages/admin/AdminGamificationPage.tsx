import { useCallback, useEffect, useState, type FormEvent } from 'react'
import { useTranslation } from 'react-i18next'
import { FeedbackToast } from '../../components/admin/FeedbackToast'
import { api } from '../../api/client'
import { resolveAdminApiError } from '../../api/readTranslatedApiMessage'
import {
  cumulativeFromLevelFormInput,
  levelPointsModeFromDb,
  prevCumulativeBeforeOrder,
  sortLevelsByOrder,
  type TeamLevelPointsModeApi,
} from '../../lib/teamLevelPoints'
import type { AdminTeamPick } from './types'
import { GamificationActionsSection } from './gamification/GamificationActionsSection'
import { GamificationBadgesSection } from './gamification/GamificationBadgesSection'
import { GamificationLevelsSection } from './gamification/GamificationLevelsSection'
import { BADGE_CONDITION_POINTS } from './gamification/badgeConditionTypes'
import type {
  GamificationActionRow,
  GamificationBadgeRow,
  GamificationLevelRow,
  NewActionForm,
  NewBadgeForm,
  NewLevelForm,
} from './gamification/types'

export function AdminGamificationPage() {
  const { t } = useTranslation()
  const [teams, setTeams] = useState<AdminTeamPick[] | null>(null)
  const [teamId, setTeamId] = useState<number | ''>('')
  const [levels, setLevels] = useState<GamificationLevelRow[] | null>(null)
  const [badges, setBadges] = useState<GamificationBadgeRow[] | null>(null)
  const [actions, setActions] = useState<GamificationActionRow[] | null>(null)
  const [teamLevelPointsMode, setTeamLevelPointsMode] = useState<TeamLevelPointsModeApi>(1)
  const [levelPointsModeSaving, setLevelPointsModeSaving] = useState(false)
  const [fb, setFb] = useState<{ ok: boolean; text: string } | null>(null)

  const [newLevel, setNewLevel] = useState<NewLevelForm>({
    name: '',
    requiredPoints: '0',
    orderIndex: '0',
  })
  const [newBadge, setNewBadge] = useState<NewBadgeForm>({
    code: '',
    name: '',
    description: '',
    iconCode: '',
    conditionType: BADGE_CONDITION_POINTS,
    conditionValue: '0',
  })
  const [newAction, setNewAction] = useState<NewActionForm>({
    code: '',
    name: '',
    description: '',
    defaultPoints: '0',
    category: '',
    isActive: true,
  })

  useEffect(() => {
    void api
      .get<{ id: number; name: string }[]>('teams')
      .then(({ data }) => setTeams(data.map((x) => ({ id: x.id, name: x.name }))))
      .catch(() => {
        setTeams([])
        setFb({ ok: false, text: t('admin.loadFail') })
      })
  }, [t])

  const loadGamification = useCallback(async (id: number) => {
    const [l, b, a] = await Promise.all([
      api.get<{ levels: GamificationLevelRow[]; levelPointsMode: number }>(`admin/levels/teams/${id}`),
      api.get<GamificationBadgeRow[]>(`admin/badges/teams/${id}`),
      api.get<GamificationActionRow[]>(`admin/action-types/teams/${id}`),
    ])
    setLevels(l.data.levels)
    setTeamLevelPointsMode(levelPointsModeFromDb(l.data.levelPointsMode))
    setBadges(b.data)
    setActions(a.data)
  }, [])

  const revertGamificationFromServer = useCallback(async () => {
    if (teamId === '') return
    try {
      await loadGamification(teamId)
    } catch {
    }
  }, [teamId, loadGamification])

  useEffect(() => {
    if (teamId === '') {
      setLevels(null)
      setBadges(null)
      setActions(null)
      return
    }
    setFb(null)
    void loadGamification(teamId).catch(() => {
      setFb({ ok: false, text: t('admin.loadFail') })
      setLevels(null)
      setBadges(null)
      setActions(null)
    })
  }, [teamId, t, loadGamification])

  async function saveLevelPointsMode(mode: TeamLevelPointsModeApi) {
    if (teamId === '') return
    setFb(null)
    setLevelPointsModeSaving(true)
    try {
      await api.put(`admin/levels/teams/${teamId}/level-points-mode`, { levelPointsMode: mode })
      setTeamLevelPointsMode(mode)
      setFb({ ok: true, text: t('admin.levelPointsModeSaved') })
      await loadGamification(teamId)
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    } finally {
      setLevelPointsModeSaving(false)
    }
  }

  async function saveLevel(row: GamificationLevelRow) {
    if (!levels) return
    setFb(null)
    if (!row.name.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      await revertGamificationFromServer()
      return
    }
    const sorted = sortLevelsByOrder(levels)
    if (teamLevelPointsMode === 1) {
      const prev = prevCumulativeBeforeOrder(sorted, row.orderIndex, row.teamLevelID)
      if (row.requiredPoints < prev) {
        setFb({ ok: false, text: t('admin.levelPointsTotalTooSmall', { min: prev }) })
        await revertGamificationFromServer()
        return
      }
    }
    try {
      await api.put(`admin/levels/${row.teamLevelID}`, {
        name: row.name,
        requiredPoints: row.requiredPoints,
        orderIndex: row.orderIndex,
      })
      setFb({ ok: true, text: t('admin.saveOk') })
      if (teamId !== '') await loadGamification(teamId)
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function deleteLevel(id: number) {
    if (!window.confirm(t('admin.confirmDeleteLevel'))) return
    setFb(null)
    try {
      await api.delete(`admin/levels/${id}`)
      if (teamId !== '') await loadGamification(teamId)
      setFb({ ok: true, text: t('admin.deleted') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function addLevel(e: FormEvent) {
    e.preventDefault()
    if (teamId === '' || !levels) return
    setFb(null)
    if (!newLevel.name.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      return
    }
    const ord = Number(newLevel.orderIndex)
    const raw = Number(newLevel.requiredPoints) || 0
    if (!Number.isFinite(ord) || ord < 1) {
      setFb({ ok: false, text: t('admin.levelOrderInvalid') })
      return
    }
    const sorted = sortLevelsByOrder(levels)
    if (teamLevelPointsMode === 1) {
      const prev = prevCumulativeBeforeOrder(sorted, ord)
      if (raw < prev) {
        setFb({ ok: false, text: t('admin.levelPointsTotalTooSmall', { min: prev }) })
        return
      }
    }
    const rp = cumulativeFromLevelFormInput({
      mode: teamLevelPointsMode,
      orderIndex: ord,
      pointsField: raw,
      sortedAsc: sorted,
    })
    try {
      await api.post(`admin/levels/teams/${teamId}`, {
        name: newLevel.name.trim(),
        requiredPoints: rp,
        orderIndex: ord,
      })
      setNewLevel({ name: '', requiredPoints: '0', orderIndex: '0' })
      await loadGamification(teamId)
      setFb({ ok: true, text: t('admin.created') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function saveBadge(row: GamificationBadgeRow) {
    setFb(null)
    if (!row.name.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      await revertGamificationFromServer()
      return
    }
    try {
      await api.put(`admin/badges/${row.teamBadgeID}`, {
        name: row.name,
        description: row.description ?? '',
        iconCode: row.iconCode ?? '',
        conditionType: row.conditionType ?? BADGE_CONDITION_POINTS,
        conditionValue: row.conditionValue ?? 0,
      })
      setFb({ ok: true, text: t('admin.saveOk') })
      if (teamId !== '') await loadGamification(teamId)
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function deleteBadge(id: number) {
    if (!window.confirm(t('admin.confirmDeleteBadge'))) return
    setFb(null)
    try {
      await api.delete(`admin/badges/${id}`)
      if (teamId !== '') await loadGamification(teamId)
      setFb({ ok: true, text: t('admin.deleted') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function addBadge(e: FormEvent) {
    e.preventDefault()
    if (teamId === '') return
    setFb(null)
    if (!newBadge.code.trim() || !newBadge.name.trim()) {
      setFb({
        ok: false,
        text: !newBadge.code.trim()
          ? t('admin.apiErrorRequiredCode')
          : t('admin.apiErrorRequiredName'),
      })
      return
    }
    try {
      await api.post(`admin/badges/teams/${teamId}`, {
        code: newBadge.code.trim(),
        name: newBadge.name.trim(),
        description: newBadge.description.trim(),
        iconCode: newBadge.iconCode.trim(),
        conditionType: newBadge.conditionType.trim() || BADGE_CONDITION_POINTS,
        conditionValue: Number(newBadge.conditionValue) || 0,
      })
      setNewBadge({
        code: '',
        name: '',
        description: '',
        iconCode: '',
        conditionType: BADGE_CONDITION_POINTS,
        conditionValue: '0',
      })
      await loadGamification(teamId)
      setFb({ ok: true, text: t('admin.created') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  function patchBadge(id: number, patch: Partial<GamificationBadgeRow>) {
    setBadges((prev) => (prev ? prev.map((b) => (b.teamBadgeID === id ? { ...b, ...patch } : b)) : prev))
  }

  function patchLevel(id: number, patch: Partial<GamificationLevelRow>) {
    setLevels((prev) => (prev ? prev.map((x) => (x.teamLevelID === id ? { ...x, ...patch } : x)) : prev))
  }

  function patchAction(id: number, patch: Partial<GamificationActionRow>) {
    setActions((prev) => (prev ? prev.map((x) => (x.actionTypeID === id ? { ...x, ...patch } : x)) : prev))
  }

  async function saveAction(row: GamificationActionRow) {
    setFb(null)
    if (!row.name.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      await revertGamificationFromServer()
      return
    }
    try {
      await api.put(`admin/action-types/${row.actionTypeID}`, {
        name: row.name,
        description: row.description ?? '',
        defaultPoints: row.defaultPoints,
        category: row.category ?? '',
        isActive: row.isActive,
      })
      setFb({ ok: true, text: t('admin.saveOk') })
      if (teamId !== '') await loadGamification(teamId)
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function deleteAction(id: number) {
    if (!window.confirm(t('admin.confirmDeleteAction'))) return
    setFb(null)
    try {
      await api.delete(`admin/action-types/${id}`)
      if (teamId !== '') await loadGamification(teamId)
      setFb({ ok: true, text: t('admin.deleted') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  async function addAction(e: FormEvent) {
    e.preventDefault()
    if (teamId === '') return
    setFb(null)
    if (!newAction.code.trim() || !newAction.name.trim()) {
      setFb({
        ok: false,
        text: !newAction.code.trim()
          ? t('admin.apiErrorRequiredCode')
          : t('admin.apiErrorRequiredName'),
      })
      return
    }
    try {
      await api.post(`admin/action-types/teams/${teamId}`, {
        code: newAction.code.trim(),
        name: newAction.name.trim(),
        description: newAction.description.trim(),
        defaultPoints: Number(newAction.defaultPoints) || 0,
        category: newAction.category.trim(),
        isActive: newAction.isActive,
      })
      setNewAction({
        code: '',
        name: '',
        description: '',
        defaultPoints: '0',
        category: '',
        isActive: true,
      })
      await loadGamification(teamId)
      setFb({ ok: true, text: t('admin.created') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await revertGamificationFromServer()
    }
  }

  if (!teams) return <p className="muted">{t('common.loading')}</p>

  return (
    <>
      <FeedbackToast state={fb} onDismiss={() => setFb(null)} />
      <div className="stack wide">
      <h1>{t('admin.gamificationTitle')}</h1>
      <div className="form" style={{ maxWidth: '28rem' }}>
        <label>
          {t('admin.selectTeam')}
          <select
            className="select"
            value={teamId === '' ? '' : String(teamId)}
            onChange={(e) => setTeamId(e.target.value === '' ? '' : Number(e.target.value))}
          >
            <option value="">{t('admin.pickTeam')}</option>
            {teams.map((x) => (
              <option key={x.id} value={x.id}>
                {t('admin.teamListOption', { name: x.name, id: x.id })}
              </option>
            ))}
          </select>
        </label>
      </div>

      {teamId === '' || !levels || !badges || !actions ? (
        <p className="muted">{t('admin.pickTeam')}</p>
      ) : (
        <>
          <GamificationLevelsSection
            levels={levels}
            levelPointsMode={teamLevelPointsMode}
            levelPointsModeDisabled={levelPointsModeSaving}
            onLevelPointsModeChange={saveLevelPointsMode}
            newLevel={newLevel}
            setNewLevel={setNewLevel}
            onPatchLevel={patchLevel}
            onSaveLevel={saveLevel}
            onDeleteLevel={deleteLevel}
            onAddLevel={addLevel}
          />
          <GamificationBadgesSection
            badges={badges}
            levels={levels}
            newBadge={newBadge}
            setNewBadge={setNewBadge}
            onPatchBadge={patchBadge}
            onSaveBadge={saveBadge}
            onDeleteBadge={deleteBadge}
            onAddBadge={addBadge}
          />
          <GamificationActionsSection
            actions={actions}
            newAction={newAction}
            setNewAction={setNewAction}
            onPatchAction={patchAction}
            onSaveAction={saveAction}
            onDeleteAction={deleteAction}
            onAddAction={addAction}
          />
        </>
      )}
      </div>
    </>
  )
}
