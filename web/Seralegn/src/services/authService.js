import { supabase } from '../lib/supabase'

export async function login(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    return { success: false, message: error.message }
  }
  
  // Check if admin and if approved
  const { data: adminData } = await supabase
    .from('admins')
    .select('is_approved')
    .eq('id', data.user.id)
    .single()

  return { 
    success: true, 
    user: data.user, 
    isAdmin: !!adminData,
    isApproved: adminData ? adminData.is_approved : false
  }
}

export async function signup(name, email, password) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        name,
        role: 'admin' // Used to indicate they applied as admin
      }
    }
  })

  if (error) {
    return { success: false, message: error.message }
  }

  // Insert into admins table as pending
  if (data.user) {
    const { error: insertError } = await supabase.from('admins').insert({
      id: data.user.id,
      full_name: name,
      email: email,
      password_hash: 'managed_by_supabase',
      is_approved: false
    });

    if (insertError) {
      console.error('Failed to create admin record:', insertError);
      // We still return success but might want to handle this better in production
    }
  }

  return { success: true, user: data.user }
}

export async function logout() {
  await supabase.auth.signOut()
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
  return data ? data.is_approved : false;
}
