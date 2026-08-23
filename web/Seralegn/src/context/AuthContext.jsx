import React, { createContext, useContext, useEffect, useState } from 'react'
import { getSession, onAuthStateChange, checkAdminApproval, getStoredUser } from '../services/authService'

const AuthContext = createContext({})

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [session, setSession] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Initial check from localStorage & Supabase session
    const storedUser = getStoredUser()
    if (storedUser) {
      setUser(storedUser)
      checkAdminApproval(storedUser.id).then((isApproved) => {
        if (storedUser.is_approved !== isApproved) {
          const updatedUser = { ...storedUser, is_approved: isApproved }
          setUser(updatedUser)
          localStorage.setItem('seralegn_admin_user', JSON.stringify(updatedUser))
        }
      })
    }

    getSession().then(async ({ data: { session: currentSession } }) => {
      setSession(currentSession)
      if (currentSession?.user) {
        const isApproved = await checkAdminApproval(currentSession.user.id);
        const name = currentSession.user.user_metadata?.name || currentSession.user.email?.split('@')[0] || 'Admin';
        const updatedUser = { ...currentSession.user, name, role: 'admin', is_approved: isApproved };
        setUser(updatedUser);
        localStorage.setItem('seralegn_admin_user', JSON.stringify(updatedUser));
      } else if (!storedUser) {
        setUser(null);
      }
      setLoading(false)
    }).catch(() => {
      setLoading(false)
    })

    // Listen for custom local auth events
    const handleAuthChange = (e) => {
      setUser(e.detail)
    }
    window.addEventListener('seralegn_auth_changed', handleAuthChange)

    // Listen for Supabase auth changes
    const { data: { subscription } } = onAuthStateChange(async (_event, currentSession) => {
      setSession(currentSession)
      if (currentSession?.user) {
        const isApproved = await checkAdminApproval(currentSession.user.id);
        const name = currentSession.user.user_metadata?.name || currentSession.user.email?.split('@')[0] || 'Admin';
        setUser({ ...currentSession.user, name, role: 'admin', is_approved: isApproved });
      } else {
        const local = getStoredUser()
        if (!local) setUser(null);
      }
      setLoading(false)
    })

    return () => {
      subscription.unsubscribe()
      window.removeEventListener('seralegn_auth_changed', handleAuthChange)
    }
  }, [])

  return (
    <AuthContext.Provider value={{ user, session, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)

