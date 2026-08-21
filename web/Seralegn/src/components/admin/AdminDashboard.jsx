import React, { useState, useEffect } from 'react';
import AdminLayout from './AdminLayout';
import { supabase } from '../../lib/supabase';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend,
} from 'chart.js';
import { Line } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Filler,
  Legend
);

export default function AdminDashboard() {
  const [stats, setStats] = useState({
    activeSubscribers: 0,
    openJobs: 0,
    pendingVerifications: 0,
    totalRevenue: 0
  });

  const [chartDataState, setChartDataState] = useState({
    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    data: [0, 0, 0, 0, 0, 0, 0]
  });

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
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

      setStats({
        activeSubscribers: activeSubs || 0,
        openJobs: openJobs || 0,
        pendingVerifications: pendingVerifications || 0,
        totalRevenue: revenue
      });

      // 5. Chart Data (Jobs posted in the last 7 days)
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
      sevenDaysAgo.setHours(0, 0, 0, 0);

      const { data: recentJobs, error: recentJobsError } = await supabase
        .from('jobs')
        .select('created_at')
        .gte('created_at', sevenDaysAgo.toISOString());

      if (!recentJobsError && recentJobs) {
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const last7DaysLabels = [];
        const last7DaysCounts = [0, 0, 0, 0, 0, 0, 0];
        
        // Generate labels for the last 7 days
        for (let i = 6; i >= 0; i--) {
          const d = new Date();
          d.setDate(d.getDate() - i);
          last7DaysLabels.push(days[d.getDay()]);
        }

        // Count jobs per day
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        recentJobs.forEach(job => {
          const jobDate = new Date(job.created_at);
          jobDate.setHours(0, 0, 0, 0);
          
          const diffTime = today.getTime() - jobDate.getTime();
          const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));
          
          if (diffDays >= 0 && diffDays <= 6) {
             const index = 6 - diffDays;
             last7DaysCounts[index]++;
          }
        });

        setChartDataState({
          labels: last7DaysLabels,
          data: last7DaysCounts
        });
      }
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    }
  };

  const chartData = {
    labels: chartDataState.labels,
    datasets: [{
      label: 'Jobs Posted',
      data: chartDataState.data,
      borderColor: '#0E5257',
      backgroundColor: 'rgba(14, 82, 87, 0.2)', // Approximate gradient for simplicity
      borderWidth: 3,
      pointBackgroundColor: '#fff',
      pointBorderColor: '#0E5257',
      pointBorderWidth: 2,
      pointRadius: 4,
      pointHoverRadius: 6,
      fill: true,
      tension: 0.4
    }]
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false }
    },
    scales: {
      y: {
        beginAtZero: true,
        grid: { color: '#F1F5F9', drawBorder: false },
        ticks: { color: '#94A3B8', font: { family: "'Plus Jakarta Sans', sans-serif" } }
      },
      x: {
        grid: { display: false, drawBorder: false },
        ticks: { color: '#94A3B8', font: { family: "'Plus Jakarta Sans', sans-serif" } }
      }
    }
  };

  return (
    <AdminLayout activeTab="dashboard">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">Overview</h1>
          <p className="text-slate-500 mt-1">Here's what's happening on Seralgn today.</p>
        </div>
        <div className="flex items-center gap-2 text-sm font-medium">
          <span className="text-slate-500">Timeframe:</span>
          <select className="bg-white border border-slate-200 rounded-lg px-3 py-1.5 outline-none focus:border-brand cursor-pointer shadow-sm">
            <option>All Time</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-2xl p-6 shadow-soft border border-slate-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-xl bg-brand/10 text-brand flex items-center justify-center">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
            </div>
          </div>
          <p className="text-slate-500 text-sm font-medium mb-1">Active Subscribers</p>
          <h3 className="font-display font-extrabold text-3xl text-slate-900">{stats.activeSubscribers.toLocaleString()}</h3>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-soft border border-slate-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-500 flex items-center justify-center">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
            </div>
          </div>
          <p className="text-slate-500 text-sm font-medium mb-1">Open Jobs</p>
          <h3 className="font-display font-extrabold text-3xl text-slate-900">{stats.openJobs.toLocaleString()}</h3>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-soft border border-slate-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-xl bg-yellow-50 text-yellow-500 flex items-center justify-center">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
            </div>
          </div>
          <p className="text-slate-500 text-sm font-medium mb-1">Pending Verifications</p>
          <h3 className="font-display font-extrabold text-3xl text-slate-900">{stats.pendingVerifications.toLocaleString()}</h3>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-soft border border-slate-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-10 h-10 rounded-xl bg-green-50 text-green-500 flex items-center justify-center">
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
            </div>
          </div>
          <p className="text-slate-500 text-sm font-medium mb-1">Total Revenue</p>
          <h3 className="font-display font-extrabold text-3xl text-slate-900">{stats.totalRevenue.toLocaleString()} <span className="text-lg text-slate-400 font-medium">Br</span></h3>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-soft border border-slate-100 p-6 lg:p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="font-bold text-slate-900 text-lg">Job Posting Trends</h2>
            <p className="text-sm text-slate-500">Number of jobs posted over the last 7 days.</p>
          </div>
        </div>
        <div className="h-72 w-full">
          <Line data={chartData} options={chartOptions} />
        </div>
      </div>
    </AdminLayout>
  );
}
