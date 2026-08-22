import React, { Suspense, lazy } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import { ToastProvider } from './context/ToastContext'

import LandingPage from './pages/Landing'
import SignUp from './pages/auth/SignUp'
import SignIn from './pages/auth/SignIn'
import ForgotPassword from './pages/auth/ForgotPassword'
import UpdatePassword from './pages/auth/UpdatePassword'

const AdminDashboard = lazy(() => import('./pages/admin/AdminDashboard'));
const AdminUsers = lazy(() => import('./pages/admin/AdminUsers'));
const AdminVerifications = lazy(() => import('./pages/admin/AdminVerifications'));
const AdminJobs = lazy(() => import('./pages/admin/AdminJobs'));
const AdminFinancials = lazy(() => import('./pages/admin/AdminFinancials'));
const AdminSettings = lazy(() => import('./pages/admin/AdminSettings'));

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth()
  
  if (loading) {
    return <div className="min-h-screen flex items-center justify-center bg-canvas">Loading session...</div>
  }

  if (!user) {
    return <Navigate to="/sign-in" replace />
  }

  if (user && !user.is_approved) {
    // Ideally trigger a toast here, but simple redirect for now
    return <Navigate to="/" replace />
  }

  return children
}

function PublicRoute({ children }) {
  const { user, loading } = useAuth()
  
  if (loading) {
    return <div className="min-h-screen flex items-center justify-center bg-canvas">Loading session...</div>
  }

  if (user) {
    if (user.is_approved) {
      return <Navigate to="/admin/dashboard" replace />
    } else {
      return <Navigate to="/" replace />
    }
  }

  return children
}

function AdminLoader() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-canvas">
      <div className="text-center">
        <svg className="animate-spin h-8 w-8 text-brand mx-auto mb-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        <p className="text-slate-500 font-medium text-sm">Loading module...</p>
      </div>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <Router>
          <div className="font-sans min-h-screen flex flex-col bg-slate-50">
            <Routes>
              <Route path="/" element={<LandingPage />} />
              <Route path="/sign-in" element={<PublicRoute><SignIn /></PublicRoute>} />
              <Route path="/sign-in.html" element={<Navigate to="/sign-in" replace />} />
              <Route path="/sign-up" element={<PublicRoute><SignUp /></PublicRoute>} />
              <Route path="/sign-up.html" element={<Navigate to="/sign-up" replace />} />
              <Route path="/forgot-password" element={<PublicRoute><ForgotPassword /></PublicRoute>} />
              <Route path="/update-password" element={<UpdatePassword />} />

              {/* Admin Routes */}
              <Route path="/admin" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminDashboard /></Suspense></ProtectedRoute>} />
              <Route path="/admin/dashboard" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminDashboard /></Suspense></ProtectedRoute>} />
              <Route path="/admin/users" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminUsers /></Suspense></ProtectedRoute>} />
              <Route path="/admin/verifications" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminVerifications /></Suspense></ProtectedRoute>} />
              <Route path="/admin/jobs" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminJobs /></Suspense></ProtectedRoute>} />
              <Route path="/admin/financials" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminFinancials /></Suspense></ProtectedRoute>} />
              <Route path="/admin/settings" element={<ProtectedRoute><Suspense fallback={<AdminLoader />}><AdminSettings /></Suspense></ProtectedRoute>} />
            </Routes>
          </div>
        </Router>
      </ToastProvider>
    </AuthProvider>
  )
}

export default App
