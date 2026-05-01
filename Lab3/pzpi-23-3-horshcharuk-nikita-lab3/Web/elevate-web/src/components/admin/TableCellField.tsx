import type { ReactNode } from 'react'

export function TableCellField({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="table-cell-field">
      <span className="table-cell-field__label">{label}</span>
      {children}
    </div>
  )
}
