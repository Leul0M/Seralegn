import { supabase } from '../lib/supabase'

export function getStoredUser() {
  try {
    const stored = localStorage.getItem('seralegn_admin_user')
    return stored ? JSON.parse(stored) : null
  } catch (e) {
    return null
  }
}

function notifyAuthChange(user) {
  window.dispatchEvent(new CustomEvent('seralegn_auth_changed', { detail: user }))
}

export async function login(email, password) {
  // Try direct Supabase RPC login first (bypasses auth rate limit & email verification)
  const { data: rpcData, error: rpcError } = await supabase.rpc('login_admin', {
    p_email: email,
    p_password: password
  })

  if (!rpcError && rpcData && rpcData.success) {
    const userObj = {
      ...rpcData.user,
      id: rpcData.user.id,
      email: rpcData.user.email,
      name: rpcData.user.name || rpcData.user.full_name,
      role: 'admin',
      is_approved: rpcData.isApproved
    }
    localStorage.setItem('seralegn_admin_user', JSON.stringify(userObj))
    notifyAuthChange(userObj)
    return {
      success: true,
      user: userObj,
      isAdmin: true,
      isApproved: rpcData.isApproved
    }
  }

  // Fallback to standard Supabase auth
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    return { success: false, message: rpcData?.message || error.message }
  }

  const { data: adminData } = await supabase
    .from('admins')
    .select('is_approved, full_name')
    .eq('id', data.user.id)
    .single()

  const userObj = {
    ...data.user,
    name: adminData?.full_name || data.user.user_metadata?.name || email.split('@')[0],
    role: 'admin',
    is_approved: adminData ? Boolean(adminData.is_approved) : false
  }

  localStorage.setItem('seralegn_admin_user', JSON.stringify(userObj))
  notifyAuthChange(userObj)

  return {
    success: true,
    user: userObj,
    isAdmin: true,
    isApproved: userObj.is_approved
  }
}

export async function signup(name, email, password) {
  // Store email and password directly inside Supabase admins table via RPC to bypass email rate limits
  const { data: rpcData, error: rpcError } = await supabase.rpc('signup_admin', {
    p_full_name: name,
    p_email: email,
    p_password: password
  })

  if (rpcError) {
    console.error('RPC signup error:', rpcError)
    return { success: false, message: rpcError.message }
  }

  if (rpcData && !rpcData.success) {
    return { success: false, message: rpcData.message }
  }

  const userObj = {
    ...rpcData.user,
    name,
    role: 'admin',
    is_approved: rpcData.user.is_approved
  }

  localStorage.setItem('seralegn_admin_user', JSON.stringify(userObj))
  notifyAuthChange(userObj)

  // Optionally trigger Supabase auth in background without blocking
  try {
    await supabase.auth.signUp({
      email,
      password,
      options: { data: { name, role: 'admin' } }
    })
  } catch (e) {
    console.warn('Background Supabase auth signup skipped:', e.message)
  }

  return { success: true, user: userObj }
}

export async function logout() {
  localStorage.removeItem('seralegn_admin_user')
  notifyAuthChange(null)
  try {
    await supabase.auth.signOut()
  } catch (e) {
    // Ignore signout errors
  }
}

export async function sendPasswordResetEmail(email) {
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${window.location.origin}/update-password`,
  })
  if (error) {
    return { success: false, message: error.message }
  }
  return { success: true }
}

export async function updatePassword(newPassword) {
  const { error } = await supabase.auth.updateUser({
    password: newPassword
  })
  if (error) {
    return { success: false, message: error.message }
  }
  return { success: true }
}

export async function getSession() {
  return await supabase.auth.getSession()
}

export function onAuthStateChange(callback) {
  return supabase.auth.onAuthStateChange(callback)
}

export async function checkAdminApproval(userId) {
  if (!userId) return false;
  const { data } = await supabase
    .from('admins')
    .select('is_approved')
    .eq('id', userId)
    .single();
  return data ? Boolean(data.is_approved) : false;
}

