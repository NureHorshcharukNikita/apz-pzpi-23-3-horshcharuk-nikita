import { useCallback, useEffect, useMemo, useState, type FormEvent } from 'react'
import { useTranslation } from 'react-i18next'
import { api } from '../../api/client'
import { resolveAdminApiError } from '../../api/readTranslatedApiMessage'
import { FeedbackToast } from '../../components/admin/FeedbackToast'
import { SortableTh } from '../../components/admin/SortableTh'
import { TableCellField } from '../../components/admin/TableCellField'
import { TablePaginationBar } from '../../components/admin/TablePaginationBar'
import { TableToolbar } from '../../components/admin/TableToolbar'
import { useClientPagination } from '../../hooks/useClientPagination'
import { useLocaleFormat } from '../../hooks/useLocaleFormat'
import { useTableSortState } from '../../hooks/useTableSort'
import { adminUserDisplayName } from '../../lib/adminUserLabel'
import type {
  AdminTeamDetail,
  AdminTeamSummary,
  AdminUserOption,
} from './types'

type MemberSortKey = 'userId' | 'fullName' | 'teamRole'

export function AdminTeamsPage() {
  const { t } = useTranslation()
  const { sortStrings, compareStrings } = useLocaleFormat()
  const [teams, setTeams] = useState<AdminTeamSummary[] | null>(null)
  const [allUsers, setAllUsers] = useState<AdminUserOption[]>([])
  const [selectedId, setSelectedId] = useState<number | null>(null)
  const [detail, setDetail] = useState<AdminTeamDetail | null>(null)
  const [editName, setEditName] = useState('')
  const [editDesc, setEditDesc] = useState('')
  const [editMaxUnlimited, setEditMaxUnlimited] = useState(true)
  const [editMaxCap, setEditMaxCap] = useState('10')
  const [createName, setCreateName] = useState('')
  const [createDesc, setCreateDesc] = useState('')
  const [createManagerId, setCreateManagerId] = useState('')
  const [createMaxUnlimited, setCreateMaxUnlimited] = useState(true)
  const [createMaxCap, setCreateMaxCap] = useState('10')
  const [addUserId, setAddUserId] = useState('')
  const [addRole, setAddRole] = useState('Member')
  const [fb, setFb] = useState<{ ok: boolean; text: string } | null>(null)
  const [teamListSearch, setTeamListSearch] = useState('')
  const [teamListSortKey, setTeamListSortKey] = useState<'name' | 'memberCount'>('name')
  const [teamListSortDir, setTeamListSortDir] = useState<'asc' | 'desc'>('asc')
  const [memberSearch, setMemberSearch] = useState('')
  const [memberRoleFilter, setMemberRoleFilter] = useState<'all' | 'Member' | 'Lead'>('all')
  const {
    sortKey: memberSortKey,
    sortDir: memberSortDir,
    toggleSort: toggleMemberSort,
    resetSort: resetMemberSort,
  } = useTableSortState('fullName')

  const refreshTeams = useCallback(async () => {
    try {
      const { data } = await api.get<AdminTeamSummary[]>('teams')
      setTeams(data)
    } catch {
      setTeams([])
      setFb({ ok: false, text: t('admin.loadFail') })
    }
  }, [t])

  async function loadDetail(teamId: number) {
    const { data } = await api.get<AdminTeamDetail>(`teams/${teamId}`)
    setDetail(data)
    setEditName(data.name)
    setEditDesc(data.description ?? '')
    const cap = data.maxMembers
    setEditMaxUnlimited(cap == null)
    setEditMaxCap(cap != null ? String(cap) : '10')
  }

  useEffect(() => {
    void refreshTeams()
  }, [refreshTeams])

  useEffect(() => {
    void api
      .get<AdminUserOption[]>('admin/users')
      .then(({ data }) => setAllUsers(data))
      .catch(() => setAllUsers([]))
  }, [t])

  useEffect(() => {
    if (selectedId != null) {
      void loadDetail(selectedId).catch(() => setDetail(null))
    } else {
      setDetail(null)
    }
  }, [selectedId])

  useEffect(() => {
    setMemberSearch('')
    setMemberRoleFilter('all')
  }, [selectedId])

  const sortedAllUsers = useMemo(() => {
    if (allUsers.length === 0) return []
    const order = sortStrings(allUsers.map((u) => adminUserDisplayName(u)))
    return [...allUsers].sort(
      (a, b) => order.indexOf(adminUserDisplayName(a)) - order.indexOf(adminUserDisplayName(b)),
    )
  }, [allUsers, sortStrings])

  const sortedAddCandidates = useMemo(() => {
    if (!detail) return []
    const memberIds = new Set(detail.members.map((m) => m.userId))
    const cand = allUsers.filter((u) => !memberIds.has(u.userID))
    if (cand.length === 0) return []
    const order = sortStrings(cand.map((u) => adminUserDisplayName(u)))
    return [...cand].sort(
      (a, b) => order.indexOf(adminUserDisplayName(a)) - order.indexOf(adminUserDisplayName(b)),
    )
  }, [allUsers, detail, sortStrings])

  const teamMemberCapReached =
    detail != null &&
    detail.maxMembers != null &&
    detail.maxMembers >= 1 &&
    detail.members.length >= detail.maxMembers

  const filteredTeams = useMemo(() => {
    if (!teams) return []
    const q = teamListSearch.trim().toLowerCase()
    return teams.filter((x) => {
      if (!q) return true
      const desc = x.description ?? ''
      return `${x.name} ${desc}`.toLowerCase().includes(q)
    })
  }, [teams, teamListSearch])

  const sortedTeamCards = useMemo(() => {
    const arr = [...filteredTeams]
    const mul = teamListSortDir === 'asc' ? 1 : -1
    if (teamListSortKey === 'name') {
      arr.sort((a, b) => mul * compareStrings(a.name, b.name))
    } else {
      arr.sort((a, b) => mul * (a.memberCount - b.memberCount))
    }
    return arr
  }, [filteredTeams, teamListSortKey, teamListSortDir, compareStrings])

  const filteredMembers = useMemo(() => {
    if (!detail) return []
    const q = memberSearch.trim().toLowerCase()
    return detail.members.filter((m) => {
      if (memberRoleFilter !== 'all' && m.teamRole !== memberRoleFilter) return false
      if (!q) return true
      const hay = `${m.userId} ${m.fullName} ${m.teamRole}`.toLowerCase()
      return hay.includes(q)
    })
  }, [detail, memberSearch, memberRoleFilter])

  const displayedMembers = useMemo(() => {
    const arr = [...filteredMembers]
    const mul = memberSortDir === 'asc' ? 1 : -1
    const key = memberSortKey as MemberSortKey
    arr.sort((a, b) => {
      switch (key) {
        case 'userId':
          return mul * (a.userId - b.userId)
        case 'fullName':
          return mul * compareStrings(a.fullName, b.fullName)
        case 'teamRole':
          return mul * compareStrings(a.teamRole, b.teamRole)
        default:
          return 0
      }
    })
    return arr
  }, [filteredMembers, memberSortKey, memberSortDir, compareStrings])

  const teamListPager = useClientPagination(
    sortedTeamCards.length,
    JSON.stringify([teamListSearch, teamListSortKey, teamListSortDir]),
  )

  const membersPager = useClientPagination(
    displayedMembers.length,
    JSON.stringify([memberSearch, memberRoleFilter, memberSortKey, memberSortDir, selectedId]),
  )
  const teamCardsPage = teamListPager.slice(sortedTeamCards)
  const memberPageRows = membersPager.slice(displayedMembers)

  function resetTeamListToolbar() {
    setTeamListSearch('')
    setTeamListSortKey('name')
    setTeamListSortDir('asc')
    teamListPager.resetPaging()
  }

  function resetMembersToolbar() {
    setMemberSearch('')
    setMemberRoleFilter('all')
    resetMemberSort()
    membersPager.resetPaging()
  }

  async function onCreate(e: FormEvent) {
    e.preventDefault()
    setFb(null)
    if (!createName.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      return
    }
    let maxMembers: number | null = null
    if (!createMaxUnlimited) {
      const n = Number(createMaxCap)
      if (!Number.isFinite(n) || n < 1) {
        setFb({ ok: false, text: t('admin.teamMaxMembersInvalid') })
        return
      }
      maxMembers = n
    }
    try {
      const mid = createManagerId ? Number(createManagerId) : undefined
      await api.post('admin/teams', {
        name: createName.trim(),
        description: createDesc.trim() || null,
        managerUserId: Number.isFinite(mid) ? mid : null,
        maxMembers,
      })
      setCreateName('')
      setCreateDesc('')
      setCreateManagerId('')
      setCreateMaxUnlimited(true)
      setCreateMaxCap('10')
      await refreshTeams()
      setFb({ ok: true, text: t('admin.teamCreated') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
    }
  }

  async function onSaveTeam(e: FormEvent) {
    e.preventDefault()
    if (selectedId == null) return
    setFb(null)
    if (!editName.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      await loadDetail(selectedId)
      return
    }
    let maxMembers: number | null = null
    if (!editMaxUnlimited) {
      const n = Number(editMaxCap)
      if (!Number.isFinite(n) || n < 1) {
        setFb({ ok: false, text: t('admin.teamMaxMembersInvalid') })
        await loadDetail(selectedId)
        return
      }
      maxMembers = n
    }
    try {
      await api.put(`admin/teams/${selectedId}`, {
        name: editName.trim(),
        description: editDesc.trim() || null,
        maxMembers,
      })
      await refreshTeams()
      await loadDetail(selectedId)
      setFb({ ok: true, text: t('admin.saveOk') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await loadDetail(selectedId)
    }
  }

  async function onDeleteTeam() {
    if (selectedId == null) return
    if (!window.confirm(t('admin.confirmDeleteTeam'))) return
    setFb(null)
    try {
      await api.delete(`admin/teams/${selectedId}`)
      setSelectedId(null)
      setDetail(null)
      await refreshTeams()
      setFb({ ok: true, text: t('admin.teamDeleted') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
    }
  }

  async function onAddMember(e: FormEvent) {
    e.preventDefault()
    if (selectedId == null) return
    if (!addUserId.trim()) {
      setFb({ ok: false, text: t('admin.validationPickUser') })
      return
    }
    const uid = Number(addUserId)
    if (!Number.isFinite(uid) || uid < 1) return
    setFb(null)
    try {
      await api.post(`admin/teams/${selectedId}/members`, { userId: uid, teamRole: addRole })
      setAddUserId('')
      await loadDetail(selectedId)
      await refreshTeams()
      setFb({ ok: true, text: t('admin.memberAdded') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await loadDetail(selectedId)
    }
  }

  async function onRemoveMember(userId: number) {
    if (selectedId == null) return
    if (!window.confirm(t('admin.confirmRemoveMember'))) return
    setFb(null)
    try {
      await api.delete(`admin/teams/${selectedId}/members/${userId}`)
      await loadDetail(selectedId)
      await refreshTeams()
      setFb({ ok: true, text: t('admin.memberRemoved') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await loadDetail(selectedId)
    }
  }

  async function onChangeMemberRole(userId: number, teamRole: string) {
    if (selectedId == null) return
    setFb(null)
    try {
      await api.post(`admin/teams/${selectedId}/members/${userId}/role`, { teamRole })
      await loadDetail(selectedId)
      await refreshTeams()
      setFb({ ok: true, text: t('admin.saveOk') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await loadDetail(selectedId)
    }
  }

  if (!teams) return <p className="muted">{t('common.loading')}</p>

  const teamTotal = teams.length

  return (
    <>
      <FeedbackToast state={fb} onDismiss={() => setFb(null)} />
      <div className="grid-2 admin-teams">
      <div>
        <h1>{t('admin.teamsDataTitle')}</h1>
        <TableToolbar
          className="teams-list-toolbar"
          search={teamListSearch}
          onSearchChange={setTeamListSearch}
          searchLabel={t('admin.teamsListSearch')}
          rangeFrom={teamListPager.rangeFrom}
          rangeTo={teamListPager.rangeTo}
          filteredTotal={sortedTeamCards.length}
          datasetTotal={teamTotal}
          pagination={
            <TablePaginationBar
              page={teamListPager.page}
              pageCount={teamListPager.pageCount}
              pageSize={teamListPager.pageSize}
              onPageChange={teamListPager.setPage}
              onPageSizeChange={teamListPager.setPageSize}
            />
          }
          filters={
            <>
              <label>
                {t('admin.sortBy')}
                <select
                  className="select"
                  value={teamListSortKey}
                  onChange={(e) => setTeamListSortKey(e.target.value as 'name' | 'memberCount')}
                >
                  <option value="name">{t('admin.sortTeamName')}</option>
                  <option value="memberCount">{t('admin.sortMemberCount')}</option>
                </select>
              </label>
              <label>
                {t('admin.sortDirection')}
                <select
                  className="select"
                  value={teamListSortDir}
                  onChange={(e) => setTeamListSortDir(e.target.value as 'asc' | 'desc')}
                >
                  <option value="asc">{t('admin.sortDirAsc')}</option>
                  <option value="desc">{t('admin.sortDirDesc')}</option>
                </select>
              </label>
              <button type="button" className="btn ghost" onClick={resetTeamListToolbar}>
                {t('admin.resetFiltersSearch')}
              </button>
            </>
          }
        />
        <ul className="list-cards">
          {teamCardsPage.map((x) => (
            <li key={x.id}>
              <button
                type="button"
                className={`card list-card team-pick ${selectedId === x.id ? 'active-card' : ''}`}
                onClick={() => setSelectedId(x.id)}
              >
                <strong>{x.name}</strong>
                <p className="muted small">{x.description}</p>
                <p className="small">
                  {t('admin.members')}: {x.memberCount}
                </p>
              </button>
            </li>
          ))}
        </ul>
        <form className="card form stack admin-teams-create-section" onSubmit={onCreate} noValidate>
          <h2>{t('admin.teamsTitle')}</h2>
          <label>
            {t('admin.teamName')}
            <input className="input" value={createName} onChange={(e) => setCreateName(e.target.value)} />
          </label>
          <label>
            {t('admin.description')}
            <textarea className="input" rows={3} value={createDesc} onChange={(e) => setCreateDesc(e.target.value)} dir="auto" />
          </label>
          <label>
            {t('admin.managerUserId')}
            <select
              className="select"
              value={createManagerId}
              onChange={(e) => setCreateManagerId(e.target.value)}
            >
              <option value="">{t('admin.managerUserNone')}</option>
              {sortedAllUsers.map((u) => (
                <option key={u.userID} value={String(u.userID)}>
                  {t('admin.userListOption', {
                    displayName: adminUserDisplayName(u),
                    login: u.login,
                    id: u.userID,
                  })}
                </option>
              ))}
            </select>
          </label>
          <fieldset className="stack" style={{ border: 'none', padding: 0, margin: 0, gap: '0.5rem' }}>
            <legend className="small muted" style={{ marginBottom: '0.25rem' }}>
              {t('admin.teamMaxMembersLabel')}
            </legend>
            <label className="row gap" style={{ alignItems: 'center', flexWrap: 'wrap' }}>
              <input
                type="radio"
                name="createCap"
                checked={createMaxUnlimited}
                onChange={() => setCreateMaxUnlimited(true)}
              />
              <span>{t('admin.teamMaxMembersUnlimited')}</span>
            </label>
            <label className="row gap" style={{ alignItems: 'center', flexWrap: 'wrap' }}>
              <input
                type="radio"
                name="createCap"
                checked={!createMaxUnlimited}
                onChange={() => setCreateMaxUnlimited(false)}
              />
              <span>{t('admin.teamMaxMembersLimited')}</span>
              <input
                className="input"
                type="number"
                min={1}
                disabled={createMaxUnlimited}
                value={createMaxCap}
                onChange={(e) => setCreateMaxCap(e.target.value)}
                style={{ width: '6rem' }}
              />
            </label>
          </fieldset>
          <button type="submit" className="btn primary">
            {t('admin.createTeam')}
          </button>
        </form>
      </div>
      <div>
        {selectedId == null || !detail ? (
          <p className="muted">{t('admin.pickTeam')}</p>
        ) : (
          <div className="stack">
            <h2>{detail.name}</h2>
            <form className="card form stack" onSubmit={onSaveTeam} noValidate>
              <label>
                {t('admin.teamName')}
                <input className="input" value={editName} onChange={(e) => setEditName(e.target.value)} />
              </label>
              <label>
                {t('admin.description')}
                <textarea className="input" rows={3} value={editDesc} onChange={(e) => setEditDesc(e.target.value)} dir="auto" />
              </label>
              <fieldset className="stack" style={{ border: 'none', padding: 0, margin: 0, gap: '0.5rem' }}>
                <legend className="small muted" style={{ marginBottom: '0.25rem' }}>
                  {t('admin.teamMaxMembersLabel')}
                </legend>
                <label className="row gap" style={{ alignItems: 'center', flexWrap: 'wrap' }}>
                  <input
                    type="radio"
                    name="editCap"
                    checked={editMaxUnlimited}
                    onChange={() => setEditMaxUnlimited(true)}
                  />
                  <span>{t('admin.teamMaxMembersUnlimited')}</span>
                </label>
                <label className="row gap" style={{ alignItems: 'center', flexWrap: 'wrap' }}>
                  <input
                    type="radio"
                    name="editCap"
                    checked={!editMaxUnlimited}
                    onChange={() => setEditMaxUnlimited(false)}
                  />
                  <span>{t('admin.teamMaxMembersLimited')}</span>
                  <input
                    className="input"
                    type="number"
                    min={1}
                    disabled={editMaxUnlimited}
                    value={editMaxCap}
                    onChange={(e) => setEditMaxCap(e.target.value)}
                    style={{ width: '6rem' }}
                  />
                </label>
                <p className="muted small">{t('admin.teamMaxMembersHint')}</p>
              </fieldset>
              <div className="row gap">
                <button type="submit" className="btn primary">
                  {t('admin.saveTeam')}
                </button>
                <button type="button" className="btn danger" onClick={() => void onDeleteTeam()}>
                  {t('admin.deleteTeam')}
                </button>
              </div>
            </form>
            <h3>{t('admin.members')}</h3>
            <TableToolbar
              search={memberSearch}
              onSearchChange={setMemberSearch}
              searchLabel={t('admin.membersSearch')}
              rangeFrom={membersPager.rangeFrom}
              rangeTo={membersPager.rangeTo}
              filteredTotal={displayedMembers.length}
              datasetTotal={detail.members.length}
              pagination={
                <TablePaginationBar
                  page={membersPager.page}
                  pageCount={membersPager.pageCount}
                  pageSize={membersPager.pageSize}
                  onPageChange={membersPager.setPage}
                  onPageSizeChange={membersPager.setPageSize}
                />
              }
              filters={
                <>
                  <label>
                    {t('admin.filterMemberRole')}
                    <select
                      className="select"
                      value={memberRoleFilter}
                      onChange={(e) => setMemberRoleFilter(e.target.value as 'all' | 'Member' | 'Lead')}
                    >
                      <option value="all">{t('admin.filterMemberRoleAll')}</option>
                      <option value="Member">{t('admin.teamRoleMember')}</option>
                      <option value="Lead">{t('admin.teamRoleLead')}</option>
                    </select>
                  </label>
                  <button type="button" className="btn ghost" onClick={resetMembersToolbar}>
                    {t('admin.resetFiltersSearch')}
                  </button>
                </>
              }
            />
            <div className="table-wrap">
              <table className="table table--team-members">
                <colgroup>
                  <col className="table-col-userid" />
                  <col className="table-col-name" />
                  <col className="table-col-teamrole" />
                  <col className="table-col-actions" />
                </colgroup>
                <thead>
                  <tr>
                    <SortableTh
                      label={t('admin.colUserId')}
                      columnKey="userId"
                      activeKey={memberSortKey}
                      dir={memberSortDir}
                      onSort={toggleMemberSort}
                    />
                    <SortableTh
                      label={t('admin.colMemberName')}
                      columnKey="fullName"
                      activeKey={memberSortKey}
                      dir={memberSortDir}
                      onSort={toggleMemberSort}
                    />
                    <SortableTh
                      label={t('admin.colTeamRole')}
                      columnKey="teamRole"
                      activeKey={memberSortKey}
                      dir={memberSortDir}
                      onSort={toggleMemberSort}
                    />
                    <th scope="col">{t('admin.colActions')}</th>
                  </tr>
                </thead>
                <tbody>
                  {memberPageRows.map((m) => (
                    <tr key={m.userId}>
                      <td>
                        <TableCellField label={t('admin.colUserId')}>
                          <span>{m.userId}</span>
                        </TableCellField>
                      </td>
                      <td>
                        <TableCellField label={t('admin.colMemberName')}>
                          <span>{m.fullName}</span>
                        </TableCellField>
                      </td>
                      <td>
                        <TableCellField label={t('admin.colTeamRole')}>
                          <select
                            className="select inline"
                            value={m.teamRole}
                            onChange={(e) => void onChangeMemberRole(m.userId, e.target.value)}
                          >
                            <option value="Member">{t('admin.teamRoleMember')}</option>
                            <option value="Lead">{t('admin.teamRoleLead')}</option>
                          </select>
                        </TableCellField>
                      </td>
                      <td>
                        <div className="table-cell-field">
                          <span className="table-cell-field__label">{t('admin.colActions')}</span>
                          <div className="table-actions">
                            <button
                              type="button"
                              className="btn small danger"
                              onClick={() => void onRemoveMember(m.userId)}
                            >
                              {t('admin.removeMember')}
                            </button>
                          </div>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {teamMemberCapReached && (
              <p className="muted small">
                {t('admin.teamMemberCapReached', {
                  current: detail.members.length,
                  max: detail.maxMembers,
                })}
              </p>
            )}
            <form className="card form row gap wrap" onSubmit={onAddMember} noValidate>
              <label>
                {t('admin.colUserId')}
                <select
                  className="select"
                  value={addUserId}
                  onChange={(e) => setAddUserId(e.target.value)}
                  disabled={sortedAddCandidates.length === 0 || teamMemberCapReached}
                >
                  <option value="">{t('admin.selectUserPlaceholder')}</option>
                  {sortedAddCandidates.map((u) => (
                    <option key={u.userID} value={String(u.userID)}>
                      {t('admin.userListOption', {
                        displayName: adminUserDisplayName(u),
                        login: u.login,
                        id: u.userID,
                      })}
                    </option>
                  ))}
                </select>
              </label>
              <label>
                {t('admin.colTeamRole')}
                <select
                  className="select"
                  value={addRole}
                  onChange={(e) => setAddRole(e.target.value)}
                  disabled={teamMemberCapReached}
                >
                  <option value="Member">{t('admin.teamRoleMember')}</option>
                  <option value="Lead">{t('admin.teamRoleLead')}</option>
                </select>
              </label>
              <button
                type="submit"
                className="btn"
                disabled={sortedAddCandidates.length === 0 || !addUserId || teamMemberCapReached}
              >
                {t('admin.addMember')}
              </button>
            </form>
            {allUsers.length > 0 && sortedAddCandidates.length === 0 && !teamMemberCapReached && (
              <p className="muted small">{t('admin.allUsersInTeam')}</p>
            )}
          </div>
        )}
      </div>
    </div>
    </>
  )
}
