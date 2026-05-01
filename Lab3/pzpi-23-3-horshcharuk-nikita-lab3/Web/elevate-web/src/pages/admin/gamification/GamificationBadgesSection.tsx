import { type Dispatch, type FormEvent, type SetStateAction, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { SortableTh } from '../../../components/admin/SortableTh'
import { TableCellField } from '../../../components/admin/TableCellField'
import { TablePaginationBar } from '../../../components/admin/TablePaginationBar'
import { TableToolbar } from '../../../components/admin/TableToolbar'
import { useClientPagination } from '../../../hooks/useClientPagination'
import { useLocaleFormat } from '../../../hooks/useLocaleFormat'
import { useTableSortState } from '../../../hooks/useTableSort'
import {
  BADGE_CONDITION_LEVEL,
  BADGE_CONDITION_POINTS,
  isBadgeLevelCondition,
} from './badgeConditionTypes'
import type { GamificationBadgeRow, GamificationLevelRow, NewBadgeForm } from './types'

type BadgeSortKey =
  | 'teamBadgeID'
  | 'code'
  | 'name'
  | 'description'
  | 'iconCode'
  | 'conditionType'
  | 'conditionValue'

type Props = {
  badges: GamificationBadgeRow[]
  levels: GamificationLevelRow[]
  newBadge: NewBadgeForm
  setNewBadge: Dispatch<SetStateAction<NewBadgeForm>>
  onPatchBadge: (id: number, patch: Partial<GamificationBadgeRow>) => void
  onSaveBadge: (row: GamificationBadgeRow) => void
  onDeleteBadge: (id: number) => void
  onAddBadge: (e: FormEvent) => void | Promise<void>
}

export function GamificationBadgesSection({
  badges,
  levels,
  newBadge,
  setNewBadge,
  onPatchBadge,
  onSaveBadge,
  onDeleteBadge,
  onAddBadge,
}: Props) {
  const { t } = useTranslation()
  const { compareStrings } = useLocaleFormat()
  const [search, setSearch] = useState('')
  const [conditionFilter, setConditionFilter] = useState<'all' | 'points' | 'level'>('all')
  const { sortKey, sortDir, toggleSort } = useTableSortState('name')

  const sortedLevels = useMemo(
    () => [...levels].sort((a, b) => a.orderIndex - b.orderIndex),
    [levels],
  )

  function setRowConditionMode(row: GamificationBadgeRow, mode: 'points' | 'level') {
    if (mode === 'points') {
      onPatchBadge(row.teamBadgeID, {
        conditionType: BADGE_CONDITION_POINTS,
        conditionValue: isBadgeLevelCondition(row.conditionType) ? 0 : (row.conditionValue ?? 0),
      })
    } else {
      const first = sortedLevels[0]?.orderIndex ?? 0
      onPatchBadge(row.teamBadgeID, {
        conditionType: BADGE_CONDITION_LEVEL,
        conditionValue: first,
      })
    }
  }

  function setNewConditionMode(mode: 'points' | 'level') {
    if (mode === 'points') {
      setNewBadge((s) => ({
        ...s,
        conditionType: BADGE_CONDITION_POINTS,
        conditionValue: isBadgeLevelCondition(s.conditionType) ? '0' : s.conditionValue,
      }))
    } else {
      const first = sortedLevels[0]?.orderIndex ?? 0
      setNewBadge((s) => ({
        ...s,
        conditionType: BADGE_CONDITION_LEVEL,
        conditionValue: String(first),
      }))
    }
  }

  const filtered = useMemo(() => {
    return badges.filter((row) => {
      if (conditionFilter === 'points' && isBadgeLevelCondition(row.conditionType)) return false
      if (conditionFilter === 'level' && !isBadgeLevelCondition(row.conditionType)) return false
      const q = search.trim().toLowerCase()
      if (!q) return true
      const desc = row.description ?? ''
      const icon = row.iconCode ?? ''
      const ct = row.conditionType ?? ''
      const cv = row.conditionValue ?? ''
      const hay = `${row.teamBadgeID} ${row.code} ${row.name} ${desc} ${icon} ${ct} ${cv}`.toLowerCase()
      return hay.includes(q)
    })
  }, [badges, search, conditionFilter])

  const displayed = useMemo(() => {
    const arr = [...filtered]
    const mul = sortDir === 'asc' ? 1 : -1
    const key = sortKey as BadgeSortKey
    arr.sort((a, b) => {
      switch (key) {
        case 'teamBadgeID':
          return mul * (a.teamBadgeID - b.teamBadgeID)
        case 'code':
          return mul * compareStrings(a.code, b.code)
        case 'name':
          return mul * compareStrings(a.name, b.name)
        case 'description':
          return mul * compareStrings(a.description ?? '', b.description ?? '')
        case 'iconCode':
          return mul * compareStrings(a.iconCode ?? '', b.iconCode ?? '')
        case 'conditionType':
          return mul * compareStrings(a.conditionType ?? '', b.conditionType ?? '')
        case 'conditionValue':
          return mul * ((a.conditionValue ?? 0) - (b.conditionValue ?? 0))
        default:
          return 0
      }
    })
    return arr
  }, [filtered, sortKey, sortDir, compareStrings])

  const pager = useClientPagination(
    displayed.length,
    JSON.stringify([search, conditionFilter, badges.length]),
  )
  const pageRows = pager.slice(displayed)

  function renderConditionValueEditor(row: GamificationBadgeRow) {
    if (isBadgeLevelCondition(row.conditionType)) {
      if (sortedLevels.length === 0) {
        return (
          <input
            className="input"
            type="number"
            title={t('admin.badgeLevelOrderFallbackTitle')}
            value={row.conditionValue ?? 0}
            onChange={(e) =>
              onPatchBadge(row.teamBadgeID, { conditionValue: Number(e.target.value) })
            }
          />
        )
      }
      const cv = row.conditionValue ?? 0
      const orders = new Set(sortedLevels.map((l) => l.orderIndex))
      return (
        <select
          className="select"
          value={String(cv)}
          onChange={(e) =>
            onPatchBadge(row.teamBadgeID, { conditionValue: Number(e.target.value) })
          }
        >
          {!orders.has(cv) && (
            <option value={String(cv)}>
              {t('admin.badgeUnknownLevelOrder', { order: cv })}
            </option>
          )}
          {sortedLevels.map((lv) => (
            <option key={lv.teamLevelID} value={String(lv.orderIndex)}>
              {t('admin.badgeLevelOption', { name: lv.name, order: lv.orderIndex })}
            </option>
          ))}
        </select>
      )
    }

    return (
      <input
        className="input"
        type="number"
        min={0}
        placeholder={t('admin.phConditionValuePoints')}
        value={row.conditionValue ?? 0}
        onChange={(e) =>
          onPatchBadge(row.teamBadgeID, { conditionValue: Number(e.target.value) })
        }
      />
    )
  }

  function renderNewConditionValueEditor() {
    if (isBadgeLevelCondition(newBadge.conditionType)) {
      if (sortedLevels.length === 0) {
        return (
          <input
            className="input"
            type="number"
            title={t('admin.badgeLevelOrderFallbackTitle')}
            value={newBadge.conditionValue}
            onChange={(e) => setNewBadge((s) => ({ ...s, conditionValue: e.target.value }))}
          />
        )
      }
      const cv = Number(newBadge.conditionValue) || 0
      const orders = new Set(sortedLevels.map((l) => l.orderIndex))
      return (
        <select
          className="select"
          value={String(cv)}
          onChange={(e) => setNewBadge((s) => ({ ...s, conditionValue: e.target.value }))}
        >
          {!orders.has(cv) && (
            <option value={String(cv)}>
              {t('admin.badgeUnknownLevelOrder', { order: cv })}
            </option>
          )}
          {sortedLevels.map((lv) => (
            <option key={lv.teamLevelID} value={String(lv.orderIndex)}>
              {t('admin.badgeLevelOption', { name: lv.name, order: lv.orderIndex })}
            </option>
          ))}
        </select>
      )
    }

    return (
      <input
        className="input"
        type="number"
        min={0}
        placeholder={t('admin.phConditionValuePoints')}
        value={newBadge.conditionValue}
        onChange={(e) => setNewBadge((s) => ({ ...s, conditionValue: e.target.value }))}
      />
    )
  }

  return (
    <section className="card stack">
      <h2>{t('admin.badgesSection')}</h2>
      <TableToolbar
        search={search}
        onSearchChange={setSearch}
        rangeFrom={pager.rangeFrom}
        rangeTo={pager.rangeTo}
        filteredTotal={displayed.length}
        datasetTotal={badges.length}
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
            {t('admin.filterConditionType')}
            <select
              className="select"
              value={conditionFilter}
              onChange={(e) => setConditionFilter(e.target.value as 'all' | 'points' | 'level')}
            >
              <option value="all">{t('admin.filterConditionAll')}</option>
              <option value="points">{t('admin.badgeConditionByPoints')}</option>
              <option value="level">{t('admin.badgeConditionByLevel')}</option>
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
                columnKey="teamBadgeID"
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
                label={t('admin.colIconCode')}
                columnKey="iconCode"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colConditionType')}
                columnKey="conditionType"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.colConditionValue')}
                columnKey="conditionValue"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <th scope="col">{t('admin.colActions')}</th>
            </tr>
          </thead>
          <tbody>
            {pageRows.map((row) => (
              <tr key={row.teamBadgeID}>
                <td>
                  <TableCellField label={t('admin.colRecordId')}>
                    <span>{row.teamBadgeID}</span>
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
                      onChange={(e) => onPatchBadge(row.teamBadgeID, { name: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colDescription')}>
                    <input
                      className="input"
                      value={row.description ?? ''}
                      onChange={(e) => onPatchBadge(row.teamBadgeID, { description: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colIconCode')}>
                    <input
                      className="input"
                      value={row.iconCode ?? ''}
                      onChange={(e) => onPatchBadge(row.teamBadgeID, { iconCode: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colConditionType')}>
                    <select
                      className="select"
                      value={isBadgeLevelCondition(row.conditionType) ? 'level' : 'points'}
                      onChange={(e) =>
                        setRowConditionMode(row, e.target.value === 'level' ? 'level' : 'points')
                      }
                    >
                      <option value="points">{t('admin.badgeConditionByPoints')}</option>
                      <option value="level">{t('admin.badgeConditionByLevel')}</option>
                    </select>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.colConditionValue')}>
                    {renderConditionValueEditor(row)}
                  </TableCellField>
                </td>
                <td>
                  <div className="table-cell-field">
                    <span className="table-cell-field__label">{t('admin.colActions')}</span>
                    <div className="table-actions">
                      <button type="button" className="btn small" onClick={() => void onSaveBadge(row)}>
                        {t('common.save')}
                      </button>
                      <button
                        type="button"
                        className="btn small danger"
                        onClick={() => void onDeleteBadge(row.teamBadgeID)}
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
      <form className="form stack" onSubmit={onAddBadge} noValidate>
        <div className="row gap wrap">
          <label>
            {t('admin.colCode')}
            <input
              className="input"
              placeholder={t('admin.phCode')}
              value={newBadge.code}
              onChange={(e) => setNewBadge((s) => ({ ...s, code: e.target.value }))}
            />
          </label>
          <label>
            {t('admin.colDisplayName')}
            <input
              className="input"
              placeholder={t('admin.phDisplayName')}
              value={newBadge.name}
              onChange={(e) => setNewBadge((s) => ({ ...s, name: e.target.value }))}
            />
          </label>
        </div>
        <label>
          {t('admin.colDescription')}
          <textarea
            className="input"
            rows={2}
            placeholder={t('admin.phDescription')}
            value={newBadge.description}
            onChange={(e) => setNewBadge((s) => ({ ...s, description: e.target.value }))}
          />
        </label>
        <div className="row gap wrap">
          <label>
            {t('admin.colIconCode')}
            <input
              className="input"
              placeholder={t('admin.phIconCode')}
              value={newBadge.iconCode}
              onChange={(e) => setNewBadge((s) => ({ ...s, iconCode: e.target.value }))}
            />
          </label>
          <label>
            {t('admin.colConditionType')}
            <select
              className="select"
              value={isBadgeLevelCondition(newBadge.conditionType) ? 'level' : 'points'}
              onChange={(e) => setNewConditionMode(e.target.value === 'level' ? 'level' : 'points')}
            >
              <option value="points">{t('admin.badgeConditionByPoints')}</option>
              <option value="level">{t('admin.badgeConditionByLevel')}</option>
            </select>
          </label>
          <label>
            {t('admin.colConditionValue')}
            {renderNewConditionValueEditor()}
          </label>
        </div>
        <button type="submit" className="btn primary">
          {t('admin.addBadge')}
        </button>
      </form>
    </section>
  )
}
