import { useTranslation } from 'react-i18next'
import { useMemo } from 'react'

export function useLocaleFormat() {
  const { i18n } = useTranslation()
  const locale = i18n.language === 'uk' ? 'uk-UA' : 'en-US'

  return useMemo(() => {
    const dtf = new Intl.DateTimeFormat(locale, {
      dateStyle: 'medium',
      timeStyle: 'short',
    })
    const collator = new Intl.Collator(locale, { sensitivity: 'base' })

    return {
      locale,
      compareStrings: (a: string, b: string) => collator.compare(a, b),
      formatDateTime: (iso: string | Date | null | undefined) => {
        if (iso == null) return '—'
        const d = typeof iso === 'string' ? new Date(iso) : iso
        if (Number.isNaN(d.getTime())) return '—'
        return dtf.format(d)
      },
      sortStrings: (arr: string[]) => [...arr].sort((a, b) => collator.compare(a, b)),
    }
  }, [locale])
}
