import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'

type Props = {
  search: string
  onSearchChange: (value: string) => void
  searchLabel?: string
  filters?: ReactNode
  rangeFrom: number
  rangeTo: number
  filteredTotal: number
  datasetTotal?: number
  pagination?: ReactNode
  className?: string
}

export function TableToolbar({
  search,
  onSearchChange,
  searchLabel,
  filters,
  rangeFrom,
  rangeTo,
  filteredTotal,
  datasetTotal,
  pagination,
  className,
}: Props) {
  const { t } = useTranslation()

  let meta: string
  if (filteredTotal === 0) {
    meta = t('admin.tableResultsEmpty')
  } else {
    meta = t('admin.tableResultsRange', { from: rangeFrom, to: rangeTo, total: filteredTotal })
    if (datasetTotal != null && datasetTotal !== filteredTotal) {
      meta += ` ${t('admin.tableResultsFromDataset', { count: datasetTotal })}`
    }
  }

  return (
    <div className={['table-toolbar', className].filter(Boolean).join(' ')}>
      <label className="table-toolbar__search">
        <span className="table-toolbar__search-label">{searchLabel ?? t('admin.tableSearch')}</span>
        <input
          type="search"
          className="input"
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          placeholder={t('admin.tableSearchPlaceholder')}
          autoComplete="off"
        />
      </label>
      {filters ? <div className="table-toolbar__filters">{filters}</div> : null}
      <p className="table-toolbar__meta muted small">{meta}</p>
      {pagination ? <div className="table-toolbar__pagination">{pagination}</div> : null}
    </div>
  )
}
