type Props = {
  label: string
  columnKey: string
  activeKey: string
  dir: 'asc' | 'desc'
  onSort: (key: string) => void
}

export function SortableTh({ label, columnKey, activeKey, dir, onSort }: Props) {
  const active = activeKey === columnKey
  return (
    <th scope="col">
      <button type="button" className="th-sort" onClick={() => onSort(columnKey)}>
        <span className="th-sort__text">{label}</span>
        {active ? <span className="th-sort__hint">{dir === 'asc' ? ' ▲' : ' ▼'}</span> : null}
      </button>
    </th>
  )
}
