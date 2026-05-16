import { type Dispatch, type FormEvent, type SetStateAction, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { SortableTh } from '../../../components/admin/SortableTh'
import { TableCellField } from '../../../components/admin/TableCellField'
import { TablePaginationBar } from '../../../components/admin/TablePaginationBar'
import { TableToolbar } from '../../../components/admin/TableToolbar'
import { useClientPagination } from '../../../hooks/useClientPagination'
import { useLocaleFormat } from '../../../hooks/useLocaleFormat'
import { useTableSortState } from '../../../hooks/useTableSort'
import type { GamificationActionRow, NewActionForm } from './types'

type ActionSortKey =
  | 'actionTypeID'
  | 'code'
  | 'name'
  | 'description'
  | 'defaultPoints'
  | 'category'
  | 'isActive'

type Props = {
  actions: GamificationActionRow[]
  newAction: NewActionForm
  setNewAction: Dispatch<SetStateAction<NewActionForm>>
  onPatchAction: (id: number, patch: Partial<GamificationActionRow>) => void
  onSaveAction: (row: GamificationActionRow) => void
  onDeleteAction: (id: number) => void | Promise<void>
  onAddAction: (e: FormEvent) => void | Promise<void>
}

export function GamificationActionsSection({
  actions,
  newAction,
  setNewAction,
  onPatchAction,
  onSaveAction,
  onDeleteAction,
  onAddAction,
}: Props) {
  const { t } = useTranslation()
  const { compareStrings } = useLocaleFormat()
  const [search, setSearch] = useState('')
  const [activeFilter, setActiveFilter] = useState<'all' | 'yes' | 'no'>('all')
  const { sortKey, sortDir, toggleSort } = useTableSortState('name')

  const filtered = useMemo(() => {
    return actions.filter((row) => {
      if (activeFilter === 'yes' && !row.isActive) return false
      if (activeFilter === 'no' && row.isActive) return false
      const q = search.trim().toLowerCase()
      if (!q) return true
      const desc = row.description ?? ''
      const cat = row.category ?? ''
      const hay = `${row.actionTypeID} ${row.code} ${row.name} ${desc} ${cat}`.toLowerCase()
      return hay.includes(q)
    })
  }, [actions, search, activeFilter])

  const displayed = useMemo(() => {
    const arr = [...filtered]
    const mul = sortDir === 'asc' ? 1 : -1
    const key = sortKey as ActionSortKey
    arr.sort((a, b) => {
      switch (key) {
        case 'actionTypeID':
          return mul * (a.actionTypeID - b.actionTypeID)
        case 'code':
          return mul * compareStrings(a.code, b.code)
        case 'name':
          return mul * compareStrings(a.name, b.name)
        case 'description':
          return mul * compareStrings(a.description ?? '', b.description ?? '')
        case 'defaultPoints':
          return mul * (a.defaultPoints - b.defaultPoints)
        case 'category':
          return mul * compareStrings(a.category ?? '', b.category ?? '')
        case 'isActive':
          return mul * (Number(a.isActive) - Number(b.isActive))
        default:
          return 0
      }
    })
    return arr
  }, [filtered, sortKey, sortDir, compareStrings])

  const pager = useClientPagination(
    displayed.length,
    JSON.stringify([search, activeFilter, actions.length]),
  )
  const pageRows = pager.slice(displayed)

  return (
    <section className="card stack">
      <h2>{t('admin.actionsSection')}</h2>
      <TableToolbar
        search={search}
        onSearchChange={setSearch}
        rangeFrom={pager.rangeFrom}
        rangeTo={pager.rangeTo}
        filteredTotal={displayed.length}
        datasetTotal={actions.length}
        pagination={
          <TablePaginationBar
            page={pager.page}
            pageCount={pager.pageCount}
            pageSize={pager.pageSize}
            onPageChange={pager.setPage}
            onPageSizeChange={pager.setPageSize}
          />
        }
        filters={
          <label>
            {t('admin.filterActionActive')}
            <select
              className="select"
              value={activeFilter}
              onChange={(e) => setActiveFilter(e.target.value as 'all' | 'yes' | 'no')}
            >
              <option value="all">{t('admin.filterActionActiveAll')}</option>
              <option value="yes">{t('admin.filterActionActiveYes')}</option>
              <option value="no">{t('admin.filterActionActiveNo')}</option>
            </select>
          </label>
        }
      />
      <div className="table-wrap">
        <table className="table table--wide">
          <thead>
            <tr>
              <SortableTh
                label={t('admin.colRecordId')}
                columnKey="actionTypeID"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colCode')}
                columnKey="code"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colDisplayName')}
                columnKey="name"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colDescription')}
                columnKey="description"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colDefaultPoints')}
                columnKey="defaultPoints"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colCategory')}
                columnKey="category"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colActionActive')}
                columnKey="isActive"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <th scope="col">{t('admin.colActions')}</th>
            </tr>
          </thead>
          <tbody>
            {pageRows.map((row) => (
              <tr key={row.actionTypeID}>
                <td>
                  <TableCellField label={t('admin.colRecordId')}>
                    <span>{row.actionTypeID}</span>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colCode')}>
                    <span className="mono small">{row.code}</span>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colDisplayName')}>
                    <input
                      className="input"
                      value={row.name}
                      onChange={(e) => onPatchAction(row.actionTypeID, { name: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colDescription')}>
                    <input
                      className="input"
                      value={row.description ?? ''}
                      onChange={(e) => onPatchAction(row.actionTypeID, { description: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colDefaultPoints')}>
                    <input
                      className="input"
                      type="number"
                      value={row.defaultPoints}
                      onChange={(e) =>
                        onPatchAction(row.actionTypeID, { defaultPoints: Number(e.target.value) })
                      }
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colCategory')}>
                    <input
                      className="input"
                      value={row.category ?? ''}
                      onChange={(e) => onPatchAction(row.actionTypeID, { category: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colActionActive')}>
                    <input
                      type="checkbox"
                      checked={row.isActive}
                      onChange={(e) => onPatchAction(row.actionTypeID, { isActive: e.target.checked })}
                      aria-label={t('admin.colActionActive')}
                    />
                  </TableCellField>
                </td>
                <td>
                  <div className="table-cell-field">
                    <span className="table-cell-field__label">{t('admin.colActions')}</span>
                    <div className="table-actions">
                      <button type="button" className="btn small" onClick={() => void onSaveAction(row)}>
                        {t('common.save')}
                      </button>
                      <button
                        type="button"
                        className="btn small danger"
                        onClick={() => void onDeleteAction(row.actionTypeID)}
                      >
                        {t('admin.delete')}
                      </button>
                    </div>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <form className="form stack" onSubmit={onAddAction} noValidate>
        <div className="row gap wrap">
          <label>
            {t('admin.colCode')}
            <input
              className="input"
              placeholder={t('admin.phCode')}
              value={newAction.code}
              onChange={(e) => setNewAction((s) => ({ ...s, code: e.target.value }))}
            />
          </label>
          <label>
            {t('admin.colDisplayName')}
            <input
              className="input"
              placeholder={t('admin.phDisplayName')}
              value={newAction.name}
              onChange={(e) => setNewAction((s) => ({ ...s, name: e.target.value }))}
            />
          </label>
          <label>
            {t('admin.colDefaultPoints')}
            <input
              className="input"
              type="number"
              placeholder={t('admin.phDefaultPoints')}
              value={newAction.defaultPoints}
              onChange={(e) => setNewAction((s) => ({ ...s, defaultPoints: e.target.value }))}
            />
          </label>
          <label>
            {t('admin.colCategory')}
            <input
              className="input"
              placeholder={t('admin.phCategory')}
              value={newAction.category}
              onChange={(e) => setNewAction((s) => ({ ...s, category: e.target.value }))}
            />
          </label>
          <label className="row gap" style={{ flexDirection: 'row', alignItems: 'center' }}>
            <input
              type="checkbox"
              checked={newAction.isActive}
              onChange={(e) => setNewAction((s) => ({ ...s, isActive: e.target.checked }))}
            />
            {t('admin.colActionActive')}
          </label>
        </div>
        <label>
          {t('admin.colDescription')}
          <textarea
            className="input"
            rows={2}
            placeholder={t('admin.phDescription')}
            value={newAction.description}
            onChange={(e) => setNewAction((s) => ({ ...s, description: e.target.value }))}
          />
        </label>
        <button type="submit" className="btn primary">
          {t('admin.addAction')}
        </button>
      </form>
    </section>
  )
}
