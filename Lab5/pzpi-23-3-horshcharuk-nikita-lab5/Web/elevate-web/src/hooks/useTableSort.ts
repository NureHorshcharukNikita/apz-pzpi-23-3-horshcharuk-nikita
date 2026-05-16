import { useCallback, useState } from 'react'

export function useTableSortState(initialKey: string) {
  const [sortKey, setSortKey] = useState(initialKey)
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('asc')

  const toggleSort = useCallback((key: string) => {
    if (sortKey === key) {
      setSortDir((d) => (d === 'asc' ? 'desc' : 'asc'))
    } else {
      setSortKey(key)
      setSortDir('asc')
    }
  }, [sortKey])

  const resetSort = useCallback(() => {
    setSortKey(initialKey)
    setSortDir('asc')
  }, [initialKey])

  return { sortKey, sortDir, toggleSort, resetSort }
}
