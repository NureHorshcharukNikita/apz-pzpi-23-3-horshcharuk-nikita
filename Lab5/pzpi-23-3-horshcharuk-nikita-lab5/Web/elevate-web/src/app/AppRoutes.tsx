import type { ReactElement } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import { useAuth } from '../auth'
import { AdminShell } from '../components/admin/AdminShell'
import { UserShell } from '../components/user/UserShell'
import { LoginPage } from '../pages/LoginPage'
import { AdminUsersPage } from '../pages/admin/AdminUsersPage'
import { AdminDevicesPage } from '../pages/admin/AdminDevicesPage'
import { AdminTeamsPage } from '../pages/admin/AdminTeamsPage'
import { AdminGamificationPage } from '../pages/admin/AdminGamificationPage'
import { AdminBackupPage } from '../pages/admin/AdminBackupPage'
import { UserHomePage } from '../pages/user/UserHomePage'
import { UserTeamsPage } from '../pages/user/UserTeamsPage'
import { UserTeamDetailPage } from '../pages/user/UserTeamDetailPage'
import { UserTeamSetupPage } from '../pages/user/UserTeamSetupPage'
import { UserTeamActionsPage } from '../pages/user/UserTeamActionsPage'
import { UserProfilePage } from '../pages/user/UserProfilePage'
import { UserAchievementsPage } from '../pages/user/UserAchievementsPage'
import { UserActivityPage } from '../pages/user/UserActivityPage'
import { UserLeaderboardPage } from '../pages/user/UserLeaderboardPage'

function AdminGate({ children }: { children: ReactElement }) {
  const { token, canAccessWebAdmin, logout } = useAuth()
  if (!token) return <Navigate to="/admin/login" replace />
  if (!canAccessWebAdmin) {
    logout()
    return <Navigate to="/admin/login?reason=nowebadmin" replace />
  }
  return children
}

function UserGate({ children }: { children: ReactElement }) {
  const { token } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  return children
}

/** `/` and unknown paths: guests → `/login`; signed-in admin → `/users`; others → `/app/home`. */
function RootOrUnknownRedirect() {
  const { token, canAccessWebAdmin } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  if (canAccessWebAdmin) return <Navigate to="/users" replace />
  return <Navigate to="/app/home" replace />
}

export function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<RootOrUnknownRedirect />} />
      <Route path="admin/login" element={<LoginPage variant="admin" />} />
      <Route path="login" element={<LoginPage variant="user" />} />
      <Route
        path="/app"
        element={
          <UserGate>
            <UserShell />
          </UserGate>
        }
      >
        <Route index element={<Navigate to="home" replace />} />
        <Route path="home" element={<UserHomePage />} />
        <Route path="teams" element={<UserTeamsPage />} />
        <Route path="teams/:teamId" element={<UserTeamDetailPage />} />
        <Route path="teams/:teamId/setup" element={<UserTeamSetupPage />} />
        <Route path="teams/:teamId/actions" element={<UserTeamActionsPage />} />
        <Route path="profile" element={<UserProfilePage />} />
        <Route path="achievements" element={<UserAchievementsPage />} />
        <Route path="activity" element={<UserActivityPage />} />
        <Route path="leaderboard" element={<UserLeaderboardPage />} />
      </Route>
      <Route
        element={
          <AdminGate>
            <AdminShell />
          </AdminGate>
        }
      >
        <Route path="users" element={<AdminUsersPage />} />
        <Route path="teams" element={<AdminTeamsPage />} />
        <Route path="devices" element={<AdminDevicesPage />} />
        <Route path="gamification" element={<AdminGamificationPage />} />
        <Route path="backup" element={<AdminBackupPage />} />
      </Route>
      <Route path="*" element={<RootOrUnknownRedirect />} />
    </Routes>
  )
}
