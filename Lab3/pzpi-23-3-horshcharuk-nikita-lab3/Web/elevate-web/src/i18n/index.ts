import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import en from './locales/en.json'
import uk from './locales/uk.json'

void i18n.use(initReactI18next).init({
  resources: {
    en: { translation: en },
    uk: { translation: uk },
  },
  lng: localStorage.getItem('elevate_lang') ?? 'uk',
  fallbackLng: 'en',
  interpolation: { escapeValue: false },
})

function syncDocumentHtmlLang(lng: string) {
  document.documentElement.lang = lng.startsWith('uk') ? 'uk' : 'en'
  document.documentElement.dir = 'ltr'
}

syncDocumentHtmlLang(i18n.language)
i18n.on('languageChanged', (lng) => {
  syncDocumentHtmlLang(lng)
})

export default i18n
