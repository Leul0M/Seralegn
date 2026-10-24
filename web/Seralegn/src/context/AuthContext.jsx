import { createContext, useContext, useEffect, useState } from 'react'
import { getSession, onAuthStateChange, checkAdminApproval, getStoredUser } from '../services/authService'

const AuthContext = createContext({})

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null)
  const [session, setSession] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let isMounted = true

    const syncAuthenticatedUser = async (candidateUser) => {
      if (!candidateUser?.id) return

      const isApproved = await checkAdminApproval(candidateUser.id)
      const nextUser = { ...candidateUser, is_approved: isApproved }

      if (!isMounted) return

      setUser(nextUser)
      localStorage.setItem('seralegn_admin_user', JSON.stringify(nextUser))
    }

    const initializeAuth = async () => {
      const storedUser = getStoredUser()
      if (storedUser && isMounted) {
        setUser(storedUser)
        await syncAuthenticatedUser(storedUser)
      }

      try {
        const { data: { session: currentSession } } = await getSession()
        if (!isMounted) return

        setSession(currentSession)

        if (currentSession?.user) {
          const isApproved = await checkAdminApproval(currentSession.user.id)
          const name = currentSession.user.user_metadata?.name || currentSession.user.email?.split('@')[0] || 'Admin'
          const updatedUser = { ...currentSession.user, name, role: 'admin', is_approved: isApproved }

          setUser(updatedUser)
          localStorage.setItem('seralegn_admin_user', JSON.stringify(updatedUser))
        } else if (!storedUser) {
          setUser(null)
        }
      } finally {
        if (isMounted) {
          setLoading(false)
        }
      }
    }

    initializeAuth()

    const handleAuthChange = (event) => {
      if (isMounted) {
        setUser(event.detail)
      }
    }

    window.addEventListener('seralegn_auth_changed', handleAuthChange)

    const { data: { subscription } } = onAuthStateChange(async (_event, currentSession) => {
      if (!isMounted) return

      setSession(currentSession)

      if (currentSession?.user) {
        const isApproved = await checkAdminApproval(currentSession.user.id)
        const name = currentSession.user.user_metadata?.name || currentSession.user.email?.split('@')[0] || 'Admin'
        setUser({ ...currentSession.user, name, role: 'admin', is_approved: isApproved })
      } else {
        const local = getStoredUser()
        if (!local) setUser(null)
      }

      setLoading(false)
    })

    return () => {
      isMounted = false
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
