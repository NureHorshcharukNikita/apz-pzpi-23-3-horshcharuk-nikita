import { useTranslation } from 'react-i18next'

export function LanguageSwitcher() {
  const { i18n, t } = useTranslation()

  return (
    <label className="lang-switch">
      <span className="sr">{t('common.locale')}</span>
      <select
        value={i18n.language.startsWith('uk') ? 'uk' : 'en'}
        onChange={(e) => {
          const lng = e.target.value
          void i18n.changeLanguage(lng)
          localStorage.setItem('elevate_lang', lng)
        }}
        className="select"
      >
        <option value="uk">{t('common.langUk')}</option>
        <option value="en">{t('common.langEn')}</option>
      </select>
    </label>
  )
}
