import { supabase } from '../lib/supabase'

export async function login(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    return { success: false, message: error.message }
  }
  
  return { success: true, user: data.user }
}

export async function signup(name, email, password) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        name,
        role: 'admin' // In a real app, assigning roles on signup should be secured
      }
    }
  })

  if (error) {
    return { success: false, message: error.message }
  }

  return { success: true, user: data.user }
}

export async function logout() {
  await supabase.auth.signOut()
}
