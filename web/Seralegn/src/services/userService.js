import { supabase } from '../lib/supabase';

/**
 * Fetch all clients for dropdown menus, ordered alphabetically
 */
export const fetchClientsBasic = async () => {
  return await supabase
    .from('clients')
    .select('id, full_name')
    .order('full_name');
};

/**
 * Fetch clients with pagination and search for the Admin Users table
 */
export const fetchAdminClients = async ({ page, pageSize, searchTerm }) => {
  let query = supabase
    .from('clients')
    .select('*', { count: 'exact' });

  if (searchTerm) {
    query = query.or(`full_name.ilike.%${searchTerm}%,phone_number.ilike.%${searchTerm}%`);
  }

  return await query
    .order('full_name')
    .range((page - 1) * pageSize, page * pageSize - 1);
};

/**
 * Fetch workers with pagination and search for the Admin Users table
 * Uses the admin_worker_status view
 */
export const fetchAdminWorkers = async ({ page, pageSize, searchTerm }) => {
  let query = supabase
    .from('admin_worker_status')
    .select('*', { count: 'exact' });

  if (searchTerm) {
    query = query.or(`full_name.ilike.%${searchTerm}%,phone_number.ilike.%${searchTerm}%`);
  }

  return await query
    .order('full_name')
    .range((page - 1) * pageSize, page * pageSize - 1);
};

/**
 * Toggle the suspension status of a worker
 */
export const toggleWorkerSuspension = async (workerId, currentStatus) => {
  return await supabase
    .from('workers')
    .update({ is_suspended: !currentStatus })
    .eq('id', workerId);
};

/**
 * Securely create a new user (client or worker) bypassing RLS
 */
export const createAdminUser = async (userData) => {
  return await supabase.rpc('admin_create_user', {
    email: userData.email,
    password: userData.password,
    full_name: userData.full_name,
    phone_number: userData.phone_number,
    user_role: userData.role
  });
};

/**
 * Securely delete a user (client or worker) bypassing RLS
 */
export const deleteAdminUser = async (userId) => {
  return await supabase.rpc('admin_delete_user', { p_user_id: userId });
};

/**
 * Helper to fetch a client's ID by their phone number 
 * (useful immediately after creating a new client)
 */
export const getClientIdByPhone = async (phoneNumber) => {
  return await supabase
    .from('clients')
    .select('id')
    .eq('phone_number', phoneNumber)
    .single();
};

/**
 * Fetch all admins
 */
export const fetchAdmins = async () => {
  return await supabase.rpc('admin_get_admins');
};

/**
 * Approve a pending admin
 */
export const approveAdmin = async (adminId) => {
  return await supabase.rpc('admin_approve_admin', { p_admin_id: adminId });
};
