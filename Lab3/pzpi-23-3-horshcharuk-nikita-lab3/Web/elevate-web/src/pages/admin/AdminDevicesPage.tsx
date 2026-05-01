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
import type { AdminDeviceRow, AdminTeamPick } from './types'

type DeviceSortKey = 'deviceID' | 'name' | 'teamID' | 'deviceKey' | 'isActive' | 'lastSeenAt'

export function AdminDevicesPage() {
  const { t } = useTranslation()
  const { formatDateTime, compareStrings, sortStrings } = useLocaleFormat()
  const [rows, setRows] = useState<AdminDeviceRow[] | null>(null)
  const [teamPickList, setTeamPickList] = useState<AdminTeamPick[]>([])
  const [createName, setCreateName] = useState('')
  const [createTeamId, setCreateTeamId] = useState('')
  const [createLocation, setCreateLocation] = useState('')
  const [editingDeviceId, setEditingDeviceId] = useState<number | null>(null)
  const [editName, setEditName] = useState('')
  const [editTeamId, setEditTeamId] = useState('')
  const [editLocation, setEditLocation] = useState('')
  const [fb, setFb] = useState<{ ok: boolean; text: string } | null>(null)
  const [search, setSearch] = useState('')
  const [teamFilter, setTeamFilter] = useState<string>('all')
  const [activeFilter, setActiveFilter] = useState<'all' | 'yes' | 'no'>('all')
  const { sortKey, sortDir, toggleSort, resetSort } = useTableSortState('name')

  const refresh = useCallback(async (): Promise<AdminDeviceRow[] | null> => {
    try {
      const { data } = await api.get<AdminDeviceRow[]>('admin/devices')
      setRows(data)
      return data
    } catch {
      setRows([])
      setFb({ ok: false, text: t('admin.loadFail') })
      return null
    }
  }, [t])

  function restoreDeviceEditFields(list: AdminDeviceRow[] | null, deviceId: number | null) {
    if (deviceId == null || !list) return
    const d = list.find((r) => r.deviceID === deviceId)
    if (!d) return
    setEditName(d.name)
    setEditTeamId(String(d.teamID))
    setEditLocation(d.location ?? '')
  }

  useEffect(() => {
    void refresh()
  }, [refresh])

  useEffect(() => {
    void api
      .get<AdminTeamPick[]>('teams')
      .then(({ data }) => setTeamPickList(data))
      .catch(() => setTeamPickList([]))
  }, [t])

  const sortedTeams = useMemo(() => {
    if (teamPickList.length === 0) return []
    const order = sortStrings(teamPickList.map((x) => x.name))
    return [...teamPickList].sort((a, b) => order.indexOf(a.name) - order.indexOf(b.name))
  }, [teamPickList, sortStrings])

  async function onCreate(e: FormEvent) {
    e.preventDefault()
    setFb(null)
    if (!createName.trim()) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      return
    }
    if (!createTeamId.trim()) {
      setFb({ ok: false, text: t('admin.validationPickTeam') })
      return
    }
    const tid = Number(createTeamId)
    if (!Number.isFinite(tid) || tid < 1) {
      setFb({ ok: false, text: t('admin.invalidTeamId') })
      return
    }
    try {
      const { data } = await api.post<{ deviceID: number; deviceKey: string }>('admin/devices', {
        name: createName.trim(),
        teamId: tid,
        location: createLocation.trim() || null,
      })
      setCreateName('')
      setCreateTeamId('')
      setCreateLocation('')
      setFb({
        ok: true,
        text: t('admin.deviceCreatedDetail', { id: data.deviceID, key: data.deviceKey }),
      })
      await refresh()
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  async function setDeviceActive(deviceID: number, active: boolean) {
    try {
      await api.post(`admin/devices/${deviceID}/${active ? 'activate' : 'deactivate'}`)
      await refresh()
      setFb({ ok: true, text: t('admin.deviceStatusUpdated') })
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  function startEditDevice(d: AdminDeviceRow) {
    setEditingDeviceId(d.deviceID)
    setEditName(d.name)
    setEditTeamId(String(d.teamID))
    setEditLocation(d.location ?? '')
    setFb(null)
  }

  function cancelEditDevice() {
    setEditingDeviceId(null)
  }

  async function saveEditDevice() {
    if (editingDeviceId == null) return
    const deviceId = editingDeviceId
    const tid = Number(editTeamId)
    if (!Number.isFinite(tid)) {
      setFb({ ok: false, text: t('admin.invalidTeamId') })
      const list = await refresh()
      restoreDeviceEditFields(list, deviceId)
      return
    }
    const name = editName.trim()
    if (!name) {
      setFb({ ok: false, text: t('admin.apiErrorRequiredName') })
      const list = await refresh()
      restoreDeviceEditFields(list, deviceId)
      return
    }
    setFb(null)
    try {
      await api.put(`admin/devices/${deviceId}`, {
        name,
        teamId: tid,
        location: editLocation.trim() || null,
      })
      cancelEditDevice()
      setFb({ ok: true, text: t('admin.deviceUpdated') })
      await refresh()
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      const list = await refresh()
      restoreDeviceEditFields(list, deviceId)
    }
  }

  async function deleteDevice(deviceID: number) {
    if (!window.confirm(t('admin.confirmDeleteDevice'))) return
    setFb(null)
    try {
      await api.delete(`admin/devices/${deviceID}`)
      if (editingDeviceId === deviceID) cancelEditDevice()
      setFb({ ok: true, text: t('admin.deviceDeleted') })
      await refresh()
    } catch (err) {
      setFb({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  const filtered = useMemo(() => {
    if (!rows) return []
    const q = search.trim().toLowerCase()
    return rows.filter((d) => {
      if (teamFilter !== 'all' && d.teamID !== Number(teamFilter)) return false
      if (activeFilter === 'yes' && !d.isActive) return false
      if (activeFilter === 'no' && d.isActive) return false
      if (!q) return true
      const loc = d.location ?? ''
      const hay = [String(d.deviceID), d.name, String(d.teamID), d.deviceKey, loc].join(' ').toLowerCase()
      return hay.includes(q)
    })
  }, [rows, search, teamFilter, activeFilter])

  const displayed = useMemo(() => {
    const arr = [...filtered]
    const mul = sortDir === 'asc' ? 1 : -1
    const lastTs = (iso: string | null | undefined) => {
      if (iso == null || iso === '') return 0
      const x = new Date(iso).getTime()
      return Number.isNaN(x) ? 0 : x
    }
    arr.sort((a, b) => {
      const key = sortKey as DeviceSortKey
      switch (key) {
        case 'deviceID':
          return mul * (a.deviceID - b.deviceID)
        case 'name':
          return mul * compareStrings(a.name, b.name)
        case 'teamID':
          return mul * (a.teamID - b.teamID)
        case 'deviceKey':
          return mul * compareStrings(a.deviceKey, b.deviceKey)
        case 'isActive':
          return mul * (Number(a.isActive) - Number(b.isActive))
        case 'lastSeenAt':
          return mul * (lastTs(a.lastSeenAt) - lastTs(b.lastSeenAt))
        default:
          return 0
      }
    })
    return arr
  }, [filtered, sortKey, sortDir, compareStrings])

  const {
    page,
    setPage,
    pageSize,
    setPageSize,
    pageCount,
    slice,
    rangeFrom,
    rangeTo,
    resetPaging,
  } = useClientPagination(displayed.length, JSON.stringify([search, teamFilter, activeFilter]))

  const pageRows = slice(displayed)

  if (!rows) return <p className="muted">{t('common.loading')}</p>

  const total = rows.length

  function handleToolbarRefresh() {
    setSearch('')
    setTeamFilter('all')
    setActiveFilter('all')
    resetSort()
    resetPaging()
    setFb(null)
    void refresh()
  }

  return (
    <>
      <FeedbackToast state={fb} onDismiss={() => setFb(null)} />
      <div>
      <h1>{t('admin.devicesTitle')}</h1>
      <form className="card form stack" onSubmit={onCreate} noValidate>
        <h2>{t('admin.addDevice')}</h2>
        <label>
          {t('admin.deviceName')}
          <input className="input" value={createName} onChange={(e) => setCreateName(e.target.value)} />
        </label>
        <label>
          {t('admin.deviceTeamId')}
          <select
            className="select"
            value={createTeamId}
            onChange={(e) => setCreateTeamId(e.target.value)}
            disabled={sortedTeams.length === 0}
          >
            <option value="">{t('admin.selectTeamForForm')}</option>
            {sortedTeams.map((tm) => (
              <option key={tm.id} value={String(tm.id)}>
                {t('admin.teamListOption', { name: tm.name, id: tm.id })}
              </option>
            ))}
          </select>
        </label>
        <label>
          {t('admin.deviceLocation')}
          <input className="input" value={createLocation} onChange={(e) => setCreateLocation(e.target.value)} dir="auto" />
        </label>
        <button type="submit" className="btn primary">
          {t('admin.createDevice')}
        </button>
      </form>
      <button type="button" className="btn ghost" onClick={handleToolbarRefresh}>
        {t('common.refresh')}
      </button>
      <TableToolbar
        search={search}
        onSearchChange={setSearch}
        rangeFrom={rangeFrom}
        rangeTo={rangeTo}
        filteredTotal={displayed.length}
        datasetTotal={total}
        pagination={
          <TablePaginationBar
            page={page}
            pageCount={pageCount}
            pageSize={pageSize}
            onPageChange={setPage}
            onPageSizeChange={setPageSize}
          />
        }
        filters={
          <>
            <label>
              {t('admin.filterTeam')}
              <select className="select" value={teamFilter} onChange={(e) => setTeamFilter(e.target.value)}>
                <option value="all">{t('admin.filterTeamAll')}</option>
                {sortedTeams.map((tm) => (
                  <option key={tm.id} value={String(tm.id)}>
                    {tm.name}
                  </option>
                ))}
              </select>
            </label>
            <label>
              {t('admin.filterActive')}
              <select
                className="select"
                value={activeFilter}
                onChange={(e) => setActiveFilter(e.target.value as 'all' | 'yes' | 'no')}
              >
                <option value="all">{t('admin.filterActiveAll')}</option>
                <option value="yes">{t('admin.filterActiveYes')}</option>
                <option value="no">{t('admin.filterActiveNo')}</option>
              </select>
            </label>
          </>
        }
      />
      <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <SortableTh
                label={t('admin.colRecordId')}
                columnKey="deviceID"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colDeviceName')}
                columnKey="name"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colTeamId')}
                columnKey="teamID"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colDeviceKey')}
                columnKey="deviceKey"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colActive')}
                columnKey="isActive"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colLastSeen')}
                columnKey="lastSeenAt"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <th scope="col">{t('admin.colActions')}</th>
            </tr>
          </thead>
          <tbody>
            {pageRows.map((d) => {
              const isEditing = editingDeviceId === d.deviceID
              return (
                <tr key={d.deviceID}>
                  <td>
                    <TableCellField label={t('admin.colRecordId')}>
                      <span>{d.deviceID}</span>
                    </TableCellField>
                  </td>
                  <td>
                    <TableCellField label={t('admin.colDeviceName')}>
                      {isEditing ? (
                        <div className="stack">
                          <input
                            className="input"
                            value={editName}
                            onChange={(e) => setEditName(e.target.value)}
                            dir="auto"
                          />
                          <label className="small muted stack">
                            {t('admin.deviceLocation')}
                            <input
                              className="input"
                              value={editLocation}
                              onChange={(e) => setEditLocation(e.target.value)}
                              dir="auto"
                            />
                          </label>
                        </div>
                      ) : (
                        <span>{d.name}</span>
                      )}
                    </TableCellField>
                  </td>
                  <td>
                    <TableCellField label={t('admin.colTeamId')}>
                      {isEditing ? (
                        <select
                          className="select"
                          value={editTeamId}
                          onChange={(e) => setEditTeamId(e.target.value)}
                          disabled={sortedTeams.length === 0}
                        >
                          {sortedTeams.map((tm) => (
                            <option key={tm.id} value={String(tm.id)}>
                              {t('admin.teamListOption', { name: tm.name, id: tm.id })}
                            </option>
                          ))}
                        </select>
                      ) : (
                        <span>{d.teamID}</span>
                      )}
                    </TableCellField>
                  </td>
                  <td>
                    <TableCellField label={t('admin.colDeviceKey')}>
                      <span className="mono small">{d.deviceKey}</span>
                    </TableCellField>
                  </td>
                  <td>
                    <TableCellField label={t('admin.colActive')}>
                      <span>{d.isActive ? t('common.yes') : t('common.no')}</span>
                    </TableCellField>
                  </td>
                  <td>
                    <TableCellField label={t('admin.colLastSeen')}>
                      <span>{formatDateTime(d.lastSeenAt)}</span>
                    </TableCellField>
                  </td>
                  <td>
                    <div className="table-cell-field">
                      <span className="table-cell-field__label">{t('admin.colActions')}</span>
                      <div className="table-actions">
                        {isEditing ? (
                          <>
                            <button type="button" className="btn small primary" onClick={() => void saveEditDevice()}>
                              {t('admin.saveDevice')}
                            </button>
                            <button type="button" className="btn small ghost" onClick={cancelEditDevice}>
                              {t('common.cancel')}
                            </button>
                          </>
                        ) : (
                          <>
                            {d.isActive ? (
                              <button
                                type="button"
                                className="btn small"
                                onClick={() => void setDeviceActive(d.deviceID, false)}
                              >
                                {t('admin.deviceOff')}
                              </button>
                            ) : (
                              <button
                                type="button"
                                className="btn small"
                                onClick={() => void setDeviceActive(d.deviceID, true)}
                              >
                                {t('admin.deviceOn')}
                              </button>
                            )}
                            <button type="button" className="btn small" onClick={() => startEditDevice(d)}>
                              {t('admin.editDevice')}
                            </button>
                            <button
                              type="button"
                              className="btn small danger"
                              onClick={() => void deleteDevice(d.deviceID)}
                            >
                              {t('admin.deleteDevice')}
                            </button>
                          </>
                        )}
                      </div>
                    </div>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
    </>
  )
}
