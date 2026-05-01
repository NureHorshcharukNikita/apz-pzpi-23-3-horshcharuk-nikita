import { useLayoutEffect, useState, type FormEvent } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { getStoredToken } from '../api/client'
import { useAuth } from '../auth'
import { hasElevateWebAdminClaim } from '../auth/jwt'
import { FeedbackToast } from '../components/admin/FeedbackToast'
import { LanguageSwitcher } from '../components/user/LanguageSwitcher'
import { mapLoginError } from './login/mapLoginError'

export type LoginVariant = 'user' | 'admin'

export function LoginPage({ variant }: { variant: LoginVariant }) {
  const { t } = useTranslation()
  const { login, logout } = useAuth()
  const nav = useNavigate()
  const [searchParams, setSearchParams] = useSearchParams()
  const [loginOrEmail, setLoginOrEmail] = useState('')
  const [password, setPassword] = useState('')
  const [err, setErr] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  const isAdminEntry = variant === 'admin'

  useLayoutEffect(() => {
    if (searchParams.get('reason') !== 'nowebadmin') return
    setErr(t('auth.errorNotWebAdmin'))
    const next = new URLSearchParams(searchParams)
    next.delete('reason')
    setSearchParams(next, { replace: true })
  }, [searchParams, setSearchParams, t])

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setErr(null)
    setBusy(true)
    try {
      await login(loginOrEmail.trim(), password)
      const token = getStoredToken()
      const isWebAdmin = Boolean(token && hasElevateWebAdminClaim(token))

      if (variant === 'user') {
        nav('/app/home', { replace: true })
        return
      }

      if (isWebAdmin) {
        nav('/users', { replace: true })
        return
      }

      logout()
      setErr(t('auth.errorNotWebAdmin'))
    } catch (e) {
      setErr(mapLoginError(e, t))
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className={`login-page${isAdminEntry ? ' login-page--admin' : ''}`}>
      <FeedbackToast state={err ? { ok: false, text: err } : null} onDismiss={() => setErr(null)} />
      <div className="login-card card">
        <div className="login-head">
          <h1>{t('app.name')}</h1>
          <LanguageSwitcher />
        </div>
        <h2>{isAdminEntry ? t('auth.loginAdminTitle') : t('auth.loginUserTitle')}</h2>
        <p className="muted small">{isAdminEntry ? t('auth.loginAdminHint') : t('auth.loginUserHint')}</p>
        <form onSubmit={onSubmit} className="form" noValidate>
          <label>
            {t('auth.loginOrEmail')}
            <input
              className="input"
              value={loginOrEmail}
              onChange={(e) => setLoginOrEmail(e.target.value)}
              autoComplete="username"
              dir="auto"
            />
          </label>
          <label>
            {t('auth.password')}
            <input
              type="password"
              className="input"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="current-password"
            />
          </label>
          <button type="submit" className="btn primary" disabled={busy}>
            {t('auth.submit')}
          </button>
        </form>
        <p className="muted small login-alt">
          {isAdminEntry ? (
            <>
              {t('auth.loginAltUserPrefix')}{' '}
              <Link to="/login">{t('auth.loginAltUserLink')}</Link>
            </>
          ) : (
            <>
              {t('auth.loginAltAdminPrefix')}{' '}
              <Link to="/admin/login">{t('auth.loginAltAdminLink')}</Link>
            </>
          )}
        </p>
      </div>
    </div>
  )
}
