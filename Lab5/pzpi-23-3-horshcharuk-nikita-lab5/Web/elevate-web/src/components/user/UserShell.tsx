import { NavLink, Outlet } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { LanguageSwitcher } from './LanguageSwitcher'
import { useAuth } from '../../auth'

export function UserShell() {
  const { t } = useTranslation()
  const { logout, user, canAccessWebAdmin } = useAuth()

  return (
    <div className="shell user-shell">
      <header className="topbar user-topbar">
        <div className="brand">
          <strong>{t('app.name')}</strong>
        </div>
        <nav className="nav">
          <NavLink to="/app/home" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.userHome')}
          </NavLink>
          <NavLink to="/app/teams" className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}>
            {t('nav.userTeams')}
          </NavLink>
          <NavLink
            to="/app/profile"
            className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}
          >
            {t('nav.userProfile')}
          </NavLink>
          <NavLink
            to="/app/achievements"
            className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}
          >
            {t('nav.userAchievements')}
          </NavLink>
          <NavLink
            to="/app/activity"
            className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}
          >
            {t('nav.userActivity')}
          </NavLink>
          <NavLink
            to="/app/leaderboard"
            className={({ isActive }) => (isActive ? 'nav-link active' : 'nav-link')}
          >
            {t('nav.userLeaderboard')}
          </NavLink>
          {canAccessWebAdmin ? (
            <NavLink to="/users" className="nav-link nav-link-admin">
              {t('nav.adminPanel')}
            </NavLink>
          ) : null}
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
      <main className="main user-main">
        <Outlet />
      </main>
    </div>
  )
}
