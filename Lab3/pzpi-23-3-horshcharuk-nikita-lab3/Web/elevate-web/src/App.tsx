import { BrowserRouter } from 'react-router-dom'
import { AuthProvider } from './auth'
import { AppRoutes } from './app/AppRoutes'

/** Empty when Vite `base: '/'` — omit prop so React Router treats the app as mounted at the site root. */
const routerBasename = import.meta.env.BASE_URL.replace(/\/$/, '') || undefined

export default function App() {
  return (
    <BrowserRouter basename={routerBasename}>
      <AuthProvider>
        <AppRoutes />
      </AuthProvider>
    </BrowserRouter>
  )
}
