// Mock Database
const MOCK_USERS = [
  { email: 'admin@seralgn.com', password: 'admin', role: 'admin', name: 'System Admin' }
];

// Login Function
export function login(email, password) {
  const user = MOCK_USERS.find(u => u.email === email && u.password === password);

  if (user) {
    localStorage.setItem('seralgn_user', JSON.stringify(user));
    return { success: true, user };
  }
  return { success: false, message: 'Invalid credentials' };
}

// Sign Up Function
export function signup(name, email, password) {
  const existing = MOCK_USERS.find(u => u.email === email);
  if (existing) {
    return { success: false, message: 'Email address already registered' };
  }
  
  const newUser = { email, password, role: 'admin', name };
  // In a real app we'd save to DB. Here we just set as active session.
  localStorage.setItem('seralgn_user', JSON.stringify(newUser));
  return { success: true, user: newUser };
}

// Logout Function
export function logout() {
  localStorage.removeItem('seralgn_user');
  window.location.href = '/';
}

// Get Current User
export function getCurrentUser() {
  try {
    const user = localStorage.getItem('seralgn_user');
    return user ? JSON.parse(user) : null;
  } catch (e) {
    return null;
  }
}
