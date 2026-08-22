import React, { createContext, useContext, useEffect, useState } from 'react'
import { getSession, onAuthStateChange, checkAdminApproval } from '../services/authService'

const AuthContext = createContext({})

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [session, setSession] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Check active session
    getSession().then(async ({ data: { session } }) => {
      setSession(session)
      if (session?.user) {
        const isApproved = await checkAdminApproval(session.user.id);
        setUser({ ...session.user, is_approved: isApproved });
      } else {
        setUser(null);
      }
      setLoading(false)
    })

    // Listen for changes
    const { data: { subscription } } = onAuthStateChange(async (_event, session) => {
      setSession(session)
      if (session?.user) {
        const isApproved = await checkAdminApproval(session.user.id);
        setUser({ ...session.user, is_approved: isApproved });
      } else {
        setUser(null);
      }
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  return (
    <AuthContext.Provider value={{ user, session, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
