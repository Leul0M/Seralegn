import { supabase } from '../lib/supabase';

/**
 * Fetch jobs for the admin panel with pagination and filtering
 */
export const fetchAdminJobs = async ({ page, pageSize, statusFilter, searchTerm }) => {
  let query = supabase
    .from('jobs')
    .select(`
      *,
      clients ( full_name ),
      workers ( full_name )
    `, { count: 'exact' });

  // Apply status filter
  if (statusFilter !== 'All Statuses') {
    const statusMap = {
      'Open for Bids': 'open',
      'In Progress': 'in_progress',
      'Completed': 'completed',
      'Cancelled': 'cancelled',
      'Claimed': 'claimed',
      'Pending Confirmation': 'pending_confirmation'
    };
    const backendStatus = statusMap[statusFilter];
    if (backendStatus) {
      query = query.eq('status', backendStatus);
    }
  }

  // Apply search filter (title or category)
  if (searchTerm) {
    query = query.or(`title.ilike.%${searchTerm}%,category.ilike.%${searchTerm}%`);
  }

  return await query
    .order('created_at', { ascending: false })
    .range((page - 1) * pageSize, page * pageSize - 1);
};

/**
 * Securely delete a job bypassing RLS
 */
export const deleteAdminJob = async (jobId) => {
  return await supabase.rpc('admin_delete_job', { p_job_id: jobId });
};

/**
 * Securely create a job bypassing RLS
 */
export const createAdminJob = async (jobData) => {
  return await supabase.rpc('admin_create_job', {
    p_client_id: jobData.client_id,
    p_title: jobData.title,
    p_category: jobData.category,
    p_description: jobData.description,
    p_offered_price: parseFloat(jobData.offered_price)
  });
};
