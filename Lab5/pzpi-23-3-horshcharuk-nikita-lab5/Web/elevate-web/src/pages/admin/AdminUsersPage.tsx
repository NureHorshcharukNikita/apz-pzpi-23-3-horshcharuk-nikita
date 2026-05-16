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
import type { AdminUserRow } from './types'

const MIN_NEW_PASSWORD_LEN = 4

const PASSWORD_MASK_DISPLAY = '••••••••'

function strField(r: Record<string, unknown>, camel: string, pascal: string): string {
  const v = r[camel] ?? r[pascal]
  return v == null ? '' : String(v)
}

function normalizeAdminUsersPayload(raw: unknown): AdminUserRow[] {
  if (!Array.isArray(raw)) return []
  return raw.map((item) => {
    const r = item as Record<string, unknown>
    const pp = r.passwordPlain ?? r.PasswordPlain
    const passwordPlain =
      pp == null || pp === '' ? null : typeof pp === 'string' ? pp : String(pp)
    const lastRaw = r.lastLoginAt ?? r.LastLoginAt
    return {
      userID: Number(r.userID ?? r.UserID),
      login: strField(r, 'login', 'Login'),
      email: strField(r, 'email', 'Email'),
      firstName: strField(r, 'firstName', 'FirstName'),
      lastName: strField(r, 'lastName', 'LastName'),
      role: strField(r, 'role', 'Role') || 'User',
      isActive: !(r.isActive === false || r.IsActive === false),
      createdAt: strField(r, 'createdAt', 'CreatedAt'),
      lastLoginAt:
        lastRaw == null || lastRaw === ''
          ? null
          : typeof lastRaw === 'string'
            ? lastRaw
            : String(lastRaw),
      passwordPlain,
    }
  })
}

export function AdminUsersPage() {
  const { t } = useTranslation()
  const { formatDateTime, compareStrings } = useLocaleFormat()
  const [rows, setRows] = useState<AdminUserRow[] | null>(null)
  const [feedback, setFeedback] = useState<{ ok: boolean; text: string } | null>(null)
  const [newLogin, setNewLogin] = useState('')
  const [newEmail, setNewEmail] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [newFirstName, setNewFirstName] = useState('')
  const [newLastName, setNewLastName] = useState('')
  const [newRole, setNewRole] = useState('User')
  const [createPasswordVisible, setCreatePasswordVisible] = useState(false)
  const [search, setSearch] = useState('')
  const [roleFilter, setRoleFilter] = useState<string>('all')
  const [activeFilter, setActiveFilter] = useState<'all' | 'yes' | 'no'>('all')
  const [rowNewPassword, setRowNewPassword] = useState<Record<number, string>>({})
  const [rowPasswordVisible, setRowPasswordVisible] = useState<Record<number, boolean>>({})
  const [rowPasswordFocused, setRowPasswordFocused] = useState<Record<number, boolean>>({})
  const { sortKey, sortDir, toggleSort, resetSort } = useTableSortState('login')

  const refresh = useCallback(async (): Promise<AdminUserRow[] | null> => {
    try {
      const { data } = await api.get<unknown>('admin/users')
      const rowsNorm = normalizeAdminUsersPayload(data)
      setRows(rowsNorm)
      return rowsNorm
    } catch {
      setRows([])
      setFeedback({ ok: false, text: t('admin.loadFail') })
      return null
    }
  }, [t])

  useEffect(() => {
    void refresh()
  }, [refresh])

  function patchRow(userID: number, patch: Partial<AdminUserRow>) {
    setRows((prev) =>
      prev ? prev.map((r) => (r.userID === userID ? { ...r, ...patch } : r)) : prev,
    )
  }

  async function saveProfile(u: AdminUserRow) {
    setFeedback(null)
    const login = u.login.trim()
    const email = u.email.trim()
    const firstName = u.firstName.trim()
    const lastName = u.lastName.trim()
    if (!login || !email || !firstName || !lastName) {
      setFeedback({ ok: false, text: t('admin.apiErrorUserProfileInvalidFields') })
      await refresh()
      return
    }
    const newPwd = (rowNewPassword[u.userID] ?? '').trim()
    if (newPwd && newPwd.length < MIN_NEW_PASSWORD_LEN) {
      setFeedback({
        ok: false,
        text: t('admin.apiErrorPasswordTooShort', { min: MIN_NEW_PASSWORD_LEN }),
      })
      await refresh()
      return
    }
    try {
      await api.put(`admin/users/${u.userID}`, {
        login,
        email,
        firstName,
        lastName,
        ...(newPwd ? { password: newPwd } : {}),
      })
      setRowNewPassword((p) => {
        const next = { ...p }
        delete next[u.userID]
        return next
      })
      setRowPasswordVisible((p) => {
        const next = { ...p }
        delete next[u.userID]
        return next
      })
      setRowPasswordFocused((p) => {
        const next = { ...p }
        delete next[u.userID]
        return next
      })
      setFeedback({ ok: true, text: t('admin.saveOk') })
      await refresh()
    } catch (err) {
      setFeedback({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  async function setRole(id: number, role: string) {
    try {
      await api.post(`admin/users/${id}/role`, { role })
      await refresh()
      setFeedback({ ok: true, text: t('admin.userRoleUpdated') })
    } catch (err) {
      setFeedback({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  async function block(id: number) {
    try {
      await api.post(`admin/users/${id}/block`)
      await refresh()
      setFeedback({ ok: true, text: t('admin.userBlockedOk') })
    } catch (err) {
      setFeedback({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  async function unblock(id: number) {
    try {
      await api.post(`admin/users/${id}/unblock`)
      await refresh()
      setFeedback({ ok: true, text: t('admin.userUnblockedOk') })
    } catch (err) {
      setFeedback({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  async function deleteUser(id: number) {
    if (!window.confirm(t('admin.confirmDeleteUser'))) return
    setFeedback(null)
    try {
      await api.delete(`admin/users/${id}`)
      setFeedback({ ok: true, text: t('admin.userDeleted') })
      await refresh()
    } catch (err) {
      setFeedback({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  async function onCreateUser(e: FormEvent) {
    e.preventDefault()
    setFeedback(null)
    const login = newLogin.trim()
    const email = newEmail.trim()
    const firstName = newFirstName.trim()
    const lastName = newLastName.trim()
    if (!login || !email || !newPassword || !firstName || !lastName) {
      setFeedback({ ok: false, text: t('admin.apiErrorUserCreateInvalidFields') })
      return
    }
    if (newPassword.length < MIN_NEW_PASSWORD_LEN) {
      setFeedback({
        ok: false,
        text: t('admin.apiErrorPasswordTooShort', { min: MIN_NEW_PASSWORD_LEN }),
      })
      return
    }
    try {
      await api.post('admin/users', {
        login,
        email,
        password: newPassword,
        firstName,
        lastName,
        role: newRole,
      })
      setNewLogin('')
      setNewEmail('')
      setNewPassword('')
      setNewFirstName('')
      setNewLastName('')
      setNewRole('User')
      setCreatePasswordVisible(false)
      setFeedback({ ok: true, text: t('admin.userCreated') })
      await refresh()
    } catch (err) {
      setFeedback({ ok: false, text: resolveAdminApiError(err, t) })
      await refresh()
    }
  }

  const filtered = useMemo(() => {
    if (!rows) return []
    const q = search.trim().toLowerCase()
    return rows.filter((u) => {
      if (roleFilter !== 'all' && u.role !== roleFilter) return false
      if (activeFilter === 'yes' && !u.isActive) return false
      if (activeFilter === 'no' && u.isActive) return false
      if (!q) return true
      const hay = [
        String(u.userID),
        u.login,
        u.email,
        u.firstName,
        u.lastName,
        u.role,
      ]
        .join(' ')
        .toLowerCase()
      return hay.includes(q)
    })
  }, [rows, search, roleFilter, activeFilter])

  const displayed = useMemo(() => {
    const arr = [...filtered]
    const mul = sortDir === 'asc' ? 1 : -1
    const lastTs = (iso: string | null | undefined) => {
      if (iso == null || iso === '') return 0
      const t = new Date(iso).getTime()
      return Number.isNaN(t) ? 0 : t
    }
    arr.sort((a, b) => {
      switch (sortKey) {
        case 'userID':
          return mul * (a.userID - b.userID)
        case 'login':
          return mul * compareStrings(a.login, b.login)
        case 'email':
          return mul * compareStrings(a.email, b.email)
        case 'firstName':
          return mul * compareStrings(a.firstName, b.firstName)
        case 'lastName':
          return mul * compareStrings(a.lastName, b.lastName)
        case 'role':
          return mul * compareStrings(a.role, b.role)
        case 'isActive':
          return mul * (Number(a.isActive) - Number(b.isActive))
        case 'createdAt':
          return mul * (lastTs(a.createdAt) - lastTs(b.createdAt))
        case 'lastLoginAt':
          return mul * (lastTs(a.lastLoginAt) - lastTs(b.lastLoginAt))
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
  } = useClientPagination(displayed.length, JSON.stringify([search, roleFilter, activeFilter]))

  const pageRows = slice(displayed)

  if (!rows) return <p className="muted">{t('common.loading')}</p>

  const total = rows.length

  function handleToolbarRefresh() {
    setSearch('')
    setRoleFilter('all')
    setActiveFilter('all')
    resetSort()
    resetPaging()
    setFeedback(null)
    setNewLogin('')
    setNewEmail('')
    setNewPassword('')
    setNewFirstName('')
    setNewLastName('')
    setNewRole('User')
    setCreatePasswordVisible(false)
    void refresh()
  }

  return (
    <>
      <FeedbackToast state={feedback} onDismiss={() => setFeedback(null)} />
      <div>
      <h1>{t('admin.usersTitle')}</h1>
      <button type="button" className="btn ghost" onClick={handleToolbarRefresh}>
        {t('common.refresh')}
      </button>
      <h2>{t('admin.createUserHeading')}</h2>
      <form
        className="card form form--compact-fields row gap wrap"
        onSubmit={(e) => void onCreateUser(e)}
        noValidate
      >
        <label>
          {t('admin.colLogin')}
          <input
            className="input"
            value={newLogin}
            onChange={(e) => setNewLogin(e.target.value)}
            autoComplete="username"
            dir="auto"
          />
        </label>
        <label>
          {t('admin.colEmail')}
          <input
            className="input"
            type="email"
            value={newEmail}
            onChange={(e) => setNewEmail(e.target.value)}
            autoComplete="email"
            dir="auto"
          />
        </label>
        <label className="form-field--password">
          {t('common.password')}
          <div className="table-password-inline">
            <input
              className="input"
              type={createPasswordVisible ? 'text' : 'password'}
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              autoComplete="new-password"
              spellCheck={false}
              aria-label={t('common.password')}
            />
            <button
              type="button"
              className="btn small ghost"
              aria-pressed={createPasswordVisible}
              onClick={() => setCreatePasswordVisible((v) => !v)}
            >
              {createPasswordVisible ? t('admin.passwordHide') : t('admin.passwordShow')}
            </button>
          </div>
        </label>
        <label>
          {t('admin.colFirstName')}
          <input
            className="input"
            value={newFirstName}
            onChange={(e) => setNewFirstName(e.target.value)}
            dir="auto"
          />
        </label>
        <label>
          {t('admin.colLastName')}
          <input
            className="input"
            value={newLastName}
            onChange={(e) => setNewLastName(e.target.value)}
            dir="auto"
          />
        </label>
        <label>
          {t('admin.colRole')}
          <select className="select" value={newRole} onChange={(e) => setNewRole(e.target.value)}>
            <option value="User">{t('admin.roleUser')}</option>
            <option value="Manager">{t('admin.roleManager')}</option>
            <option value="Admin">{t('admin.roleAdmin')}</option>
            <option value="SystemAdministrator">{t('admin.roleSystemAdministrator')}</option>
          </select>
        </label>
        <button type="submit" className="btn">
          {t('admin.createUserSubmit')}
        </button>
      </form>
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
              {t('admin.filterRole')}
              <select
                className="select"
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
              >
                <option value="all">{t('admin.filterRoleAll')}</option>
                <option value="User">{t('admin.roleUser')}</option>
                <option value="Manager">{t('admin.roleManager')}</option>
                <option value="Admin">{t('admin.roleAdmin')}</option>
                <option value="SystemAdministrator">{t('admin.roleSystemAdministrator')}</option>
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
        <table className="table table--users">
          <colgroup>
            <col className="table-col-id" />
            <col className="table-col-login" />
            <col className="table-col-email" />
            <col className="table-col-first" />
            <col className="table-col-last" />
            <col className="table-col-password" />
            <col className="table-col-role" />
            <col className="table-col-active" />
            <col className="table-col-created" />
            <col className="table-col-lastin" />
            <col className="table-col-actions" />
          </colgroup>
          <thead>
            <tr>
              <SortableTh
                label={t('admin.colRecordId')}
                columnKey="userID"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colLogin')}
                columnKey="login"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colEmail')}
                columnKey="email"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colFirstName')}
                columnKey="firstName"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colLastName')}
                columnKey="lastName"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <th scope="col" title={t('admin.passwordColumnHelp')}>
                {t('admin.colPassword')}
              </th>
              <SortableTh
                label={t('admin.colRole')}
                columnKey="role"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colActive')}
                columnKey="isActive"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colCreatedAt')}
                columnKey="createdAt"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <SortableTh
                label={t('admin.colLastSignIn')}
                columnKey="lastLoginAt"
                activeKey={sortKey}
                dir={sortDir}
                onSort={(k) => toggleSort(k)}
              />
              <th scope="col">{t('admin.colActions')}</th>
            </tr>
          </thead>
          <tbody>
            {pageRows.map((u) => (
              <tr key={u.userID}>
                <td>
                  <TableCellField label={t('admin.colRecordId')}>
                    <span>{u.userID}</span>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colLogin')}>
                    <input
                      className="input inline mono small"
                      value={u.login}
                      onChange={(e) => patchRow(u.userID, { login: e.target.value })}
                      dir="auto"
                      spellCheck={false}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colEmail')}>
                    <input
                      className="input inline"
                      value={u.email}
                      onChange={(e) => patchRow(u.userID, { email: e.target.value })}
                      dir="auto"
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colFirstName')}>
                    <input
                      className="input inline"
                      value={u.firstName}
                      onChange={(e) => patchRow(u.userID, { firstName: e.target.value })}
                      dir="auto"
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colLastName')}>
                    <input
                      className="input inline"
                      value={u.lastName}
                      onChange={(e) => patchRow(u.userID, { lastName: e.target.value })}
                      dir="auto"
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colPassword')}>
                    {(() => {
                      const stored = (u.passwordPlain ?? '').trim()
                      const draft = rowNewPassword[u.userID] ?? ''
                      const focused = Boolean(rowPasswordFocused[u.userID])
                      const hasStored = stored.length > 0
                      const isChangingPassword = focused || draft.length > 0
                      const showPlaceholderMask = !isChangingPassword && !hasStored
                      const inputValue = showPlaceholderMask
                        ? PASSWORD_MASK_DISPLAY
                        : isChangingPassword
                          ? draft
                          : stored
                      const revealed = Boolean(rowPasswordVisible[u.userID])
                      const inputType = showPlaceholderMask ? 'text' : revealed ? 'text' : 'password'
                      const readOnly = showPlaceholderMask || (!isChangingPassword && hasStored)
                      const canReveal =
                        (hasStored && !isChangingPassword) || (isChangingPassword && draft.length > 0)
                      const fieldTitle = showPlaceholderMask
                        ? t('admin.passwordNotStoredPlain')
                        : isChangingPassword
                          ? t('admin.passwordNewFieldHint')
                          : t('admin.passwordShownStored')
                      return (
                        <div className="table-password-inline">
                          <input
                            className="input inline"
                            type={inputType}
                            value={inputValue}
                            onChange={(e) => {
                              if (showPlaceholderMask) return
                              if (!isChangingPassword) return
                              setRowNewPassword((p) => ({
                                ...p,
                                [u.userID]: e.target.value,
                              }))
                            }}
                            onFocus={() => {
                              setRowPasswordFocused((p) => ({ ...p, [u.userID]: true }))
                            }}
                            onBlur={() => {
                              setRowPasswordFocused((p) => ({ ...p, [u.userID]: false }))
                            }}
                            autoComplete="new-password"
                            spellCheck={false}
                            readOnly={readOnly}
                            title={fieldTitle}
                            aria-label={t('admin.colPassword')}
                          />
                          <button
                            type="button"
                            className="btn small ghost"
                            disabled={!canReveal}
                            title={
                              canReveal
                                ? undefined
                                : t('admin.passwordRevealDisabledHint')
                            }
                            aria-pressed={Boolean(rowPasswordVisible[u.userID])}
                            onClick={() =>
                              setRowPasswordVisible((p) => ({
                                ...p,
                                [u.userID]: !p[u.userID],
                              }))
                            }
                          >
                            {rowPasswordVisible[u.userID]
                              ? t('admin.passwordHide')
                              : t('admin.passwordShow')}
                          </button>
                        </div>
                      )
                    })()}
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colRole')}>
                    <select
                      className="select inline"
                      value={u.role}
                      onChange={(e) => void setRole(u.userID, e.target.value)}
                    >
                      <option value="User">{t('admin.roleUser')}</option>
                      <option value="Manager">{t('admin.roleManager')}</option>
                      <option value="Admin">{t('admin.roleAdmin')}</option>
                      <option value="SystemAdministrator">{t('admin.roleSystemAdministrator')}</option>
                    </select>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colActive')}>
                    <span>{u.isActive ? t('common.yes') : t('common.no')}</span>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colCreatedAt')}>
                    <span className="small muted">{formatDateTime(u.createdAt)}</span>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colLastSignIn')}>
                    <span className="small muted">
                      {u.lastLoginAt != null && u.lastLoginAt !== ''
                        ? formatDateTime(u.lastLoginAt)
                        : t('admin.noLastSignIn')}
                    </span>
                  </TableCellField>
                </td>
                <td>
                  <div className="table-cell-field">
                    <span className="table-cell-field__label">{t('admin.colActions')}</span>
                    <div className="table-actions">
                      <button type="button" className="btn small" onClick={() => void saveProfile(u)}>
                        {t('admin.saveProfile')}
                      </button>
                      {u.isActive ? (
                        <button type="button" className="btn small danger" onClick={() => void block(u.userID)}>
                          {t('admin.block')}
                        </button>
                      ) : (
                        <button type="button" className="btn small" onClick={() => void unblock(u.userID)}>
                          {t('admin.unblock')}
                        </button>
                      )}
                      <button type="button" className="btn small danger" onClick={() => void deleteUser(u.userID)}>
                        {t('admin.deleteUser')}
                      </button>
                    </div>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
    </>
  )
}
