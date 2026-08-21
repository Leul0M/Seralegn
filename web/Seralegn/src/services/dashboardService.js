import { supabase } from '../lib/supabase';

/**
 * Fetch top-level statistics for the admin dashboard
 */
export const fetchDashboardStats = async () => {
  // 1. Active Subscribers (trial or paid)
  const { count: activeSubs, error: subsError } = await supabase
    .from('admin_worker_status')
    .select('*', { count: 'exact', head: true })
    .gt('days_left', 0);
  if (subsError) console.error(subsError);

  // 2. Open Jobs
  const { count: openJobs, error: jobsError } = await supabase
    .from('jobs')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'open');
  if (jobsError) console.error(jobsError);

  // 3. Pending Verifications
  const { count: pendingVerifications, error: verificationsError } = await supabase
    .from('workers')
    .select('*', { count: 'exact', head: true })
    .eq('fayda_verified', false);
  if (verificationsError) console.error(verificationsError);

  // 4. Total Revenue
  const { data: revData, error: revError } = await supabase
    .from('subscriptions')
    .select('amount')
    .eq('status', 'success');
  
  let revenue = 0;
  if (!revError && revData) {
    revenue = revData.reduce((sum, sub) => sum + Number(sub.amount), 0);
  } else {
    console.error(revError);
  }

  // 5. Chart Data (Jobs posted in the last 7 days)
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
  sevenDaysAgo.setHours(0, 0, 0, 0);

  const { data: recentJobs, error: recentJobsError } = await supabase
    .from('jobs')
    .select('created_at')
    .gte('created_at', sevenDaysAgo.toISOString());

  const chartLabels = [];
  const chartData = [];

  if (!recentJobsError && recentJobs) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    // Initialize last 7 days
    const dailyCounts = {};
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dayName = days[d.getDay()];
      chartLabels.push(dayName);
      dailyCounts[dayName] = 0;
    }
    
    // Populate with actual data
    recentJobs.forEach(job => {
      const jobDate = new Date(job.created_at);
      const dayName = days[jobDate.getDay()];
      if (dailyCounts[dayName] !== undefined) {
        dailyCounts[dayName]++;
      }
    });

    chartLabels.forEach(label => {
      chartData.push(dailyCounts[label]);
    });
  }

  return {
    stats: {
      activeSubscribers: activeSubs || 0,
      openJobs: openJobs || 0,
      pendingVerifications: pendingVerifications || 0,
      totalRevenue: revenue
    },
    chart: {
      labels: chartLabels.length > 0 ? chartLabels : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      data: chartData.length > 0 ? chartData : [0, 0, 0, 0, 0, 0, 0]
    },
    error: subsError || jobsError || verificationsError || revError || recentJobsError
  };
};

/**
 * Fetch paginated financial transactions
 */
export const fetchFinancialTransactions = async ({ page, pageSize, filter, searchTerm }) => {
  let query = supabase
    .from('subscriptions')
    .select(`
      *,
      workers ( full_name )
    `, { count: 'exact' });

  if (filter !== 'All') {
    query = query.eq('status', filter);
  }

  if (searchTerm) {
    query = query.or(`chapa_tx_ref.ilike.%${searchTerm}%`);
  }

  return await query
    .order('created_at', { ascending: false })
    .range((page - 1) * pageSize, page * pageSize - 1);
};

/**
 * Fetch overall financial stats (total revenue, success count, failure count)
 */
export const fetchFinancialStats = async () => {
  const { data, error } = await supabase
    .from('subscriptions')
    .select('amount, status');
    
  if (error) return { error };

  const successTransactions = data.filter(t => t.status === 'success');
  const revenue = successTransactions.reduce((sum, t) => sum + Number(t.amount), 0);
  
  return {
    revenue,
    successCount: successTransactions.length,
    failedCount: data.filter(t => t.status !== 'success').length,
    error: null
  };
};
