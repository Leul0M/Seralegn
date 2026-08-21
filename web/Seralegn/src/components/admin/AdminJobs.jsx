import React, { useState, useEffect } from 'react';
import AdminLayout from './AdminLayout';
import { supabase } from '../../lib/supabase';

export default function AdminJobs() {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('All Statuses');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchJobs();
  }, []);

  const fetchJobs = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('jobs')
        .select(`
          *,
          clients ( full_name ),
          workers ( full_name )
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setJobs(data || []);
    } catch (error) {
      console.error('Error fetching jobs:', error);
      alert('Failed to load jobs: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteJob = async (jobId) => {
    if (!window.confirm('Are you sure you want to delete this job post? This action cannot be undone.')) return;

    try {
      const { error } = await supabase
        .from('jobs')
        .delete()
        .eq('id', jobId);
      
      if (error) throw error;
      setJobs(jobs.filter(j => j.id !== jobId));
    } catch (error) {
      console.error('Error deleting job:', error);
      alert('Failed to delete job: ' + error.message);
    }
  };

  const filteredJobs = jobs.filter(job => {
    // Status Filter
    const matchesStatus = (() => {
      if (statusFilter === 'All Statuses') return true;
      if (statusFilter === 'Open for Bids' && job.status === 'open') return true;
      if (statusFilter === 'In Progress' && job.status === 'in_progress') return true;
      if (statusFilter === 'Completed' && job.status === 'completed') return true;
      if (statusFilter === 'Cancelled' && job.status === 'cancelled') return true;
      if (statusFilter === 'Claimed' && job.status === 'claimed') return true;
      if (statusFilter === 'Pending Confirmation' && job.status === 'pending_confirmation') return true;
      return false;
    })();

    // Search Text Filter
    const matchesSearch = 
      job.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      job.category.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (job.clients?.full_name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (job.workers?.full_name || '').toLowerCase().includes(searchTerm.toLowerCase());

    return matchesStatus && matchesSearch;
  });

  return (
    <AdminLayout activeTab="jobs">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">Job Board Moderation</h1>
          <p className="text-slate-500 mt-1">Review active job posts and ensure marketplace quality.</p>
        </div>
      </div>

      <div className="bg-white p-4 rounded-t-2xl border-x border-t border-slate-100 flex items-center gap-4 border-b">
        <select 
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-sm outline-none focus:border-brand cursor-pointer"
        >
          <option>All Statuses</option>
          <option>Open for Bids</option>
          <option>Claimed</option>
          <option>In Progress</option>
          <option>Pending Confirmation</option>
          <option>Completed</option>
          <option>Cancelled</option>
        </select>
        
        <div className="relative ml-auto">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
          </div>
          <input 
            type="text" 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="bg-slate-50 border border-slate-200 text-slate-800 text-sm rounded-lg focus:ring-brand focus:border-brand block w-64 pl-9 p-2 transition-colors" 
            placeholder="Search jobs, clients..." 
          />
        </div>
        
        <div className="text-sm text-slate-500">
          {filteredJobs.length} Job{filteredJobs.length !== 1 ? 's' : ''} found
        </div>
      </div>

      <div className="bg-white rounded-b-2xl shadow-soft border-x border-b border-slate-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                <th className="p-4 font-bold">Job Post / Category</th>
                <th className="p-4 font-bold">Client</th>
                <th className="p-4 font-bold">Worker Assigned</th>
                <th className="p-4 font-bold">Status</th>
                <th className="p-4 font-bold">Price</th>
                <th className="p-4 font-bold text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-sm divide-y divide-slate-100">
              {loading ? (
                <tr><td colSpan="6" className="p-8 text-center text-slate-500">Loading jobs...</td></tr>
              ) : filteredJobs.length === 0 ? (
                <tr><td colSpan="6" className="p-8 text-center text-slate-500">No jobs found.</td></tr>
              ) : (
                filteredJobs.map(job => (
                  <tr key={job.id} className="hover:bg-slate-50 transition-colors">
                    <td className="p-4">
                      <p className="font-bold text-slate-900">{job.title}</p>
                      <p className="text-xs text-slate-500">{job.category}</p>
                    </td>
                    <td className="p-4">{job.clients?.full_name || 'Unknown'}</td>
                    <td className="p-4 text-slate-500">{job.workers?.full_name || 'Not Assigned'}</td>
                    <td className="p-4">
                      {job.status === 'open' && <span className="bg-blue-50 text-blue-600 px-2.5 py-1 rounded-full text-xs font-bold">Open</span>}
                      {job.status === 'claimed' && <span className="bg-purple-50 text-purple-600 px-2.5 py-1 rounded-full text-xs font-bold">Claimed</span>}
                      {job.status === 'in_progress' && <span className="bg-yellow-50 text-yellow-600 px-2.5 py-1 rounded-full text-xs font-bold">In Progress</span>}
                      {job.status === 'pending_confirmation' && <span className="bg-orange-50 text-orange-600 px-2.5 py-1 rounded-full text-xs font-bold">Pending Review</span>}
                      {job.status === 'completed' && <span className="bg-green-50 text-green-600 px-2.5 py-1 rounded-full text-xs font-bold">Completed</span>}
                      {job.status === 'cancelled' && <span className="bg-red-50 text-red-600 px-2.5 py-1 rounded-full text-xs font-bold">Cancelled</span>}
                    </td>
                    <td className="p-4 font-medium"><span className="text-slate-900 font-bold">{job.offered_price} Br</span></td>
                    <td className="p-4 text-right">
                      <button 
                        onClick={() => handleDeleteJob(job.id)}
                        className="text-red-500 hover:bg-red-50 px-3 py-1 rounded-lg font-semibold transition-colors border border-red-100"
                      >
                        Delete Post
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
