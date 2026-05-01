import { NavLink, Outlet } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { LanguageSwitcher } from '../user/LanguageSwitcher'
import { useAuth } from '../../auth'

export function AdminShell() {
  const { t } = useTranslation()
  const { logout, user } = useAuth()

  return (
    <div className="shell admin-shell">
      <header className="topbar admin-topbar">
        <div className="brand">
          <strong>{t('app.name')}</strong>
        </div>
        <nav className="nav">
          <NavLink to="/users" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.adminUsers')}
          </NavLink>
          <NavLink to="/teams" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.adminTeams')}
          </NavLink>
          <NavLink to="/devices" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.adminDevices')}
          </NavLink>
          <NavLink to="/gamification" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.adminGamification')}
          </NavLink>
          <NavLink to="/backup" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.adminBackup')}
          </NavLink>
          <NavLink to="/app/home" className="nav-link nav-link-user">
            {t('nav.userApp')}
          </NavLink>
        </nav>
        <div className="topbar-actions">
          <LanguageSwitcher />
          <span className="user-pill">
            {user?.firstName} {user?.lastName}
          </span>
          <button type="button" className="btn ghost" onClick={logout}>
            {t('nav.logout')}
          </button>
        </div>
      </header>
      <main className="main">
        <Outlet />
      </main>
    </div>
  )
}
