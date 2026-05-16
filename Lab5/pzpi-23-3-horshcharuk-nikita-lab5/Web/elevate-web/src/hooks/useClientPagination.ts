import { useCallback, useEffect, useMemo, useState } from 'react'

export const CLIENT_PAGE_SIZE_OPTIONS = [5, 10, 25, 50, 100] as const

export function useClientPagination(filteredLength: number, resetKey: string) {
  const [page, setPage] = useState(1)
  const [pageSize, setPageSize] = useState(10)

  useEffect(() => {
    setPage(1)
  }, [resetKey])

  const pageCount = useMemo(() => {
    if (filteredLength <= 0) return 1
    return Math.max(1, Math.ceil(filteredLength / pageSize))
  }, [filteredLength, pageSize])

  useEffect(() => {
    setPage((p) => Math.min(Math.max(1, p), pageCount))
  }, [pageCount])

  const startIdx = (page - 1) * pageSize

  const slice = useCallback(
    <T,>(items: readonly T[]) => items.slice(startIdx, startIdx + pageSize),
    [startIdx, pageSize],
  )

  const rangeFrom = filteredLength === 0 ? 0 : startIdx + 1
  const rangeTo = Math.min(startIdx + pageSize, filteredLength)

  const resetPaging = useCallback(() => {
    setPage(1)
    setPageSize(10)
  }, [])

  return {
    page,
    setPage,
    pageSize,
    setPageSize,
    pageCount,
    slice,
    rangeFrom,
    rangeTo,
    resetPaging,
  }
}
