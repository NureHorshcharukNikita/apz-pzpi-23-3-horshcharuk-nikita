import { useTranslation } from 'react-i18next'
import { CLIENT_PAGE_SIZE_OPTIONS } from '../../hooks/useClientPagination'

type Props = {
  page: number
  pageCount: number
  pageSize: number
  onPageChange: (page: number) => void
  onPageSizeChange: (size: number) => void
  disabled?: boolean
}

export function TablePaginationBar({
  page,
  pageCount,
  pageSize,
  onPageChange,
  onPageSizeChange,
  disabled,
}: Props) {
  const { t } = useTranslation()

  return (
    <div className="table-pagination" aria-label={t('admin.paginationAria')}>
      <div className="table-pagination__nav">
        <button
          type="button"
          className="btn small ghost"
          disabled={disabled || page <= 1}
          onClick={() => onPageChange(page - 1)}
        >
          {t('admin.paginationPrev')}
        </button>
        <span className="muted small table-pagination__page">
          {t('admin.paginationPage', { page, pages: pageCount })}
        </span>
        <button
          type="button"
          className="btn small ghost"
          disabled={disabled || page >= pageCount}
          onClick={() => onPageChange(page + 1)}
        >
          {t('admin.paginationNext')}
        </button>
      </div>
      <label className="table-pagination__size">
        <span className="muted small">{t('admin.paginationPageSize')}</span>
        <select
          className="select"
          value={String(pageSize)}
          disabled={disabled}
          onChange={(e) => onPageSizeChange(Number(e.target.value))}
        >
          {CLIENT_PAGE_SIZE_OPTIONS.map((n) => (
            <option key={n} value={String(n)}>
              {n}
            </option>
          ))}
        </select>
      </label>
    </div>
  )
}
