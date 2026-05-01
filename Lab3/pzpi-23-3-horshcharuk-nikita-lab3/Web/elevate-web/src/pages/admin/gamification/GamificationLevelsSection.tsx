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
  prevCumulativeBeforeOrder,
  segmentForLevel,
  sortLevelsByOrder,
  type TeamLevelPointsModeApi,
} from '../../../lib/teamLevelPoints'
import type { GamificationLevelRow, NewLevelForm } from './types'

type LevelSortKey = 'teamLevelID' | 'name' | 'requiredPoints' | 'orderIndex'

type Props = {
  levels: GamificationLevelRow[]
  levelPointsMode: TeamLevelPointsModeApi
  levelPointsModeDisabled?: boolean
  onLevelPointsModeChange: (mode: TeamLevelPointsModeApi) => void | Promise<void>
  newLevel: NewLevelForm
  setNewLevel: Dispatch<SetStateAction<NewLevelForm>>
  onPatchLevel: (id: number, patch: Partial<GamificationLevelRow>) => void
  onSaveLevel: (row: GamificationLevelRow) => void
  onDeleteLevel: (id: number) => void
  onAddLevel: (e: FormEvent) => void | Promise<void>
}

export function GamificationLevelsSection({
  levels,
  levelPointsMode,
  levelPointsModeDisabled = false,
  onLevelPointsModeChange,
  newLevel,
  setNewLevel,
  onPatchLevel,
  onSaveLevel,
  onDeleteLevel,
  onAddLevel,
}: Props) {
  const { t } = useTranslation()
  const { compareStrings } = useLocaleFormat()
  const [search, setSearch] = useState('')
  const { sortKey, sortDir, toggleSort } = useTableSortState('orderIndex')

  const sortedForPoints = useMemo(() => sortLevelsByOrder(levels), [levels])

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase()
    if (!q) return levels
    return levels.filter((row) => {
      const hay = `${row.teamLevelID} ${row.name} ${row.requiredPoints} ${row.orderIndex}`.toLowerCase()
      return hay.includes(q)
    })
  }, [levels, search])

  const displayed = useMemo(() => {
    const arr = [...filtered]
    const mul = sortDir === 'asc' ? 1 : -1
    const key = sortKey as LevelSortKey
    arr.sort((a, b) => {
      switch (key) {
        case 'teamLevelID':
          return mul * (a.teamLevelID - b.teamLevelID)
        case 'name':
          return mul * compareStrings(a.name, b.name)
        case 'requiredPoints':
          return mul * (a.requiredPoints - b.requiredPoints)
        case 'orderIndex':
          return mul * (a.orderIndex - b.orderIndex)
        default:
          return 0
      }
    })
    return arr
  }, [filtered, sortKey, sortDir, compareStrings])

  const pager = useClientPagination(displayed.length, JSON.stringify([search, levels.length]))
  const pageRows = pager.slice(displayed)

  const pointsColumnLabel =
    levelPointsMode === 0 ? t('admin.levelPointsSegment') : t('admin.levelPointsTotal')

  return (
    <section className="card stack">
      <h2>{t('admin.levelsSection')}</h2>
      <p className="muted small">
        {levelPointsMode === 0 ? t('admin.levelPointsHelpRelative') : t('admin.levelPointsHelpAbsolute')}
      </p>
      <p className="muted small">{t('admin.levelPointsServerCurveNote')}</p>
      <label className="row gap wrap">
        <span className="muted small">
          <strong>{t('admin.levelPointsModeLabel')}</strong>
        </span>
        <select
          className="select"
          value={String(levelPointsMode)}
          disabled={levelPointsModeDisabled}
          onChange={(e) => {
            const next = Number(e.target.value) as TeamLevelPointsModeApi
            if (next === levelPointsMode) return
            void onLevelPointsModeChange(next)
          }}
        >
          <option value="0">{t('admin.levelPointsModeRelative')}</option>
          <option value="1">{t('admin.levelPointsModeAbsolute')}</option>
        </select>
      </label>
      <TableToolbar
        search={search}
        onSearchChange={setSearch}
        rangeFrom={pager.rangeFrom}
        rangeTo={pager.rangeTo}
        filteredTotal={displayed.length}
        datasetTotal={levels.length}
        pagination={
          <TablePaginationBar
            page={pager.page}
            pageCount={pager.pageCount}
            pageSize={pager.pageSize}
            onPageChange={pager.setPage}
            onPageSizeChange={pager.setPageSize}
          />
        }
      />
      <div className="table-wrap">
        <table className="table table--medium">
          <thead>
            <tr>
              <SortableTh
                label={t('admin.colRecordId')}
                columnKey="teamLevelID"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.levelName')}
                columnKey="name"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={pointsColumnLabel}
                columnKey="requiredPoints"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <SortableTh
                label={t('admin.orderIndex')}
                columnKey="orderIndex"
                activeKey={sortKey}
                dir={sortDir}
                onSort={toggleSort}
              />
              <th scope="col">{t('admin.colActions')}</th>
            </tr>
          </thead>
          <tbody>
            {pageRows.map((row) => (
              <tr key={row.teamLevelID}>
                <td>
                  <TableCellField label={t('admin.colRecordId')}>
                    <span>{row.teamLevelID}</span>
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.levelName')}>
                    <input
                      className="input"
                      value={row.name}
                      onChange={(e) => onPatchLevel(row.teamLevelID, { name: e.target.value })}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={pointsColumnLabel}>
                    <input
                      className="input"
                      type="number"
                      value={
                        levelPointsMode === 0
                          ? segmentForLevel(row, sortedForPoints)
                          : row.requiredPoints
                      }
                      onChange={(e) => {
                        const n = Number(e.target.value)
                        const seg = Number.isFinite(n) ? n : 0
                        if (levelPointsMode === 0) {
                          const prev = prevCumulativeBeforeOrder(
                            sortedForPoints,
                            row.orderIndex,
                            row.teamLevelID,
                          )
                          onPatchLevel(row.teamLevelID, { requiredPoints: Math.max(0, prev + seg) })
                        } else {
                          onPatchLevel(row.teamLevelID, { requiredPoints: Math.max(0, seg) })
                        }
                      }}
                    />
                  </TableCellField>
                </td>
                <td>
                  <TableCellField label={t('admin.orderIndex')}>
                    <input
                      className="input"
                      type="number"
                      value={row.orderIndex}
                      onChange={(e) =>
                        onPatchLevel(row.teamLevelID, { orderIndex: Number(e.target.value) })
                      }
                    />
                  </TableCellField>
                </td>
                <td>
                  <div className="table-cell-field">
                    <span className="table-cell-field__label">{t('admin.colActions')}</span>
                    <div className="table-actions">
                      <button type="button" className="btn small" onClick={() => void onSaveLevel(row)}>
                        {t('common.save')}
                      </button>
                      <button
                        type="button"
                        className="btn small danger"
                        onClick={() => void onDeleteLevel(row.teamLevelID)}
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
      <form className="form stack" onSubmit={onAddLevel} noValidate>
        <label>
          {t('admin.levelName')}
          <input
            className="input"
            placeholder={t('admin.levelName')}
            value={newLevel.name}
            onChange={(e) => setNewLevel((s) => ({ ...s, name: e.target.value }))}
          />
        </label>
        <div className="row gap wrap">
          <label>
            {pointsColumnLabel}
            <input
              className="input"
              type="number"
              placeholder={pointsColumnLabel}
              value={newLevel.requiredPoints}
              onChange={(e) => setNewLevel((s) => ({ ...s, requiredPoints: e.target.value }))}
            />
            <span className="muted small" style={{ display: 'block', marginTop: '0.25rem' }}>
              {levelPointsMode === 0
                ? t('admin.levelPointsNewHelpRelative')
                : t('admin.levelPointsNewHelpAbsolute')}
            </span>
          </label>
          <label>
            {t('admin.orderIndex')}
            <input
              className="input"
              type="number"
              placeholder={t('admin.orderIndex')}
              value={newLevel.orderIndex}
              onChange={(e) => setNewLevel((s) => ({ ...s, orderIndex: e.target.value }))}
            />
          </label>
          <div className="row gap" style={{ alignSelf: 'flex-end' }}>
            <button type="submit" className="btn primary">
              {t('admin.addLevel')}
            </button>
          </div>
        </div>
      </form>
    </section>
  )
}
