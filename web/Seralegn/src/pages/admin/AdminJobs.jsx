import React, { useState, useEffect } from 'react';
import AdminLayout from '../../layouts/AdminLayout';
import { fetchAdminJobs, deleteAdminJob, createAdminJob } from '../../services/jobService';
import { fetchClientsBasic, createAdminUser, getClientIdByPhone } from '../../services/userService';
import { useToast } from '../../context/ToastContext';
import TableLoader from '../../components/common/TableLoader';
import EmptyState from '../../components/common/EmptyState';
import Pagination from '../../components/common/Pagination';
import { useDebounce } from '../../hooks/useDebounce';

export default function AdminJobs() {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('All Statuses');
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const PAGE_SIZE = 10;
  const { showToast } = useToast();

  const [showAddJobModal, setShowAddJobModal] = useState(false);
  const [clients, setClients] = useState([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const [isNewClient, setIsNewClient] = useState(false);
  const [clientSearch, setClientSearch] = useState('');
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [selectedClientName, setSelectedClientName] = useState('');
  
  const [newJobForm, setNewJobForm] = useState({
    client_id: '',
    title: '',
    category: '',
    description: '',
    offered_price: '',
    new_client_name: '',
    new_client_phone: '',
    new_client_email: '',
    new_client_password: ''
  });

  useEffect(() => {
    // Reset page to 1 when filters change
    setPage(1);
  }, [debouncedSearchTerm, statusFilter]);

  useEffect(() => {
    fetchJobs();
  }, [page, debouncedSearchTerm, statusFilter]);

  useEffect(() => {
    // Fetch clients once for the modal dropdown
    fetchClients();
  }, []);

  const fetchClients = async () => {
    try {
      const { data, error } = await fetchClientsBasic();
      if (error) throw error;
      setClients(data || []);
    } catch (err) {
      console.error('Error fetching clients:', err);
    }
  };

  const fetchJobs = async () => {
    setLoading(true);
    try {
      const { data, error, count } = await fetchAdminJobs({
        page,
        pageSize: PAGE_SIZE,
        statusFilter,
        searchTerm: debouncedSearchTerm
      });

      if (error) throw error;
      setJobs(data || []);
      setTotalCount(count || 0);
    } catch (error) {
      console.error('Error fetching jobs:', error);
      showToast('Failed to load jobs: ' + error.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteJob = async (jobId) => {
    if (!window.confirm('Are you sure you want to delete this job post? This action cannot be undone.')) return;

    try {
      const { data, error } = await deleteAdminJob(jobId);
      
      if (error) throw error;
      
      if (!data) {
        throw new Error('Permission denied or job not found.');
      }

      setJobs(jobs.filter(j => j.id !== jobId));
      setTotalCount(prev => prev - 1);
      showToast('Job successfully deleted', 'success');
    } catch (error) {
      console.error('Error deleting job:', error);
      showToast('Failed to delete job: ' + error.message, 'error');
    }
  };

  const handleAddJob = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      let finalClientId = newJobForm.client_id;
      
      if (isNewClient) {
        // Create new client first
        const { error: userError } = await createAdminUser({
          email: newJobForm.new_client_email,
          password: newJobForm.new_client_password,
          full_name: newJobForm.new_client_name,
          phone_number: newJobForm.new_client_phone,
          role: 'client'
        });
        
        if (userError) {
          if (userError.code === '23505') {
            throw new Error('A user with this email or phone number already exists. Please select them from the existing clients list.');
          }
          throw userError;
        }
        
        // Fetch their new UUID
        const { data: newClientData, error: fetchErr } = await getClientIdByPhone(newJobForm.new_client_phone);
          
        if (fetchErr) throw fetchErr;
        finalClientId = newClientData.id;
      } else {
        if (!finalClientId) {
          throw new Error("Please select a client from the list or create a new one.");
        }
      }

      const { error } = await createAdminJob({
        client_id: finalClientId,
        title: newJobForm.title,
        category: newJobForm.category,
        description: newJobForm.description,
        offered_price: newJobForm.offered_price
      });

      if (error) throw error;

      showToast('Job successfully created!', 'success');
      setShowAddJobModal(false);
      
      // Reset form
      setNewJobForm({
        client_id: '', title: '', category: '', description: '', offered_price: '',
        new_client_name: '', new_client_phone: '', new_client_email: '', new_client_password: ''
      });
      setClientSearch('');
      setSelectedClientName('');
      setIsNewClient(false);
      
      fetchJobs();
      if (isNewClient) fetchClients(); // Refresh client list
    } catch (error) {
      console.error('Error creating job:', error);
      showToast('Failed to create job: ' + error.message, 'error');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Frontend filtering is removed; using server-side query filtering

  return (
    <AdminLayout activeTab="jobs">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">Job Board Moderation</h1>
          <p className="text-slate-500 mt-1">Review active job posts and ensure marketplace quality.</p>
        </div>
        <button 
          onClick={() => setShowAddJobModal(true)}
          className="bg-brand text-white font-bold px-4 py-2 rounded-lg hover:bg-brand-dark transition-colors shadow-sm flex items-center gap-2 text-sm"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"/></svg>
          Add Job
        </button>
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
          {totalCount} Job{totalCount !== 1 ? 's' : ''} found
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
            {loading ? (
              <TableLoader columns={6} />
            ) : jobs.length === 0 ? (
              <EmptyState message="No jobs found." colSpan={6} />
            ) : (
              <tbody className="text-sm divide-y divide-slate-100">
                {jobs.map(job => (
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
                ))}
              </tbody>
            )}
          </table>
        </div>
        <Pagination 
          page={page} 
          pageSize={PAGE_SIZE} 
          totalCount={totalCount} 
          onPageChange={setPage} 
        />
      </div>

      {/* Add Job Modal */}
      {showAddJobModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 backdrop-blur-sm bg-slate-900/40">
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md flex flex-col overflow-hidden border border-slate-200">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <h2 className="font-display font-bold text-xl text-slate-900 flex items-center gap-2">
                <svg className="w-6 h-6 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" /></svg>
                Create New Job
              </h2>
              <button onClick={() => setShowAddJobModal(false)} className="text-slate-400 hover:text-slate-600 transition-colors p-1 rounded-full hover:bg-slate-200">
                <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>
            
            <form onSubmit={handleAddJob} className="p-6 overflow-y-auto max-h-[70vh]">
              <div className="space-y-4">
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="block text-sm font-bold text-slate-700">Client</label>
                    <button type="button" onClick={() => setIsNewClient(!isNewClient)} className="text-xs text-brand font-semibold hover:underline">
                      {isNewClient ? 'Select Existing Client' : '+ Create New Client'}
                    </button>
                  </div>
                  
                  {!isNewClient ? (
                    <div className="relative">
                      <input 
                        type="text"
                        value={selectedClientName || clientSearch}
                        onFocus={() => setIsDropdownOpen(true)}
                        onBlur={() => setIsDropdownOpen(false)}
                        onChange={(e) => {
                          setClientSearch(e.target.value);
                          setIsDropdownOpen(true);
                          setSelectedClientName('');
                          setNewJobForm({...newJobForm, client_id: ''});
                        }}
                        className={`w-full bg-slate-50 border ${newJobForm.client_id ? 'border-green-400 focus:border-green-500' : 'border-slate-200 focus:border-brand'} rounded-lg p-2.5 text-sm outline-none focus:ring-1 transition-colors pr-10`}
                        placeholder="Search for a client..."
                        required={!isNewClient && !newJobForm.client_id}
                      />
                      
                      {/* Success Indicator */}
                      {newJobForm.client_id && (
                        <div className="absolute right-3 top-2.5 text-green-500 bg-white rounded-full">
                          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                        </div>
                      )}
                      
                      {/* Dropdown Menu */}
                      {isDropdownOpen && (
                        <div className="absolute z-10 w-full mt-1 bg-white border border-slate-200 rounded-lg shadow-xl max-h-48 overflow-y-auto">
                          {clients.filter(c => c.full_name.toLowerCase().includes(clientSearch.toLowerCase())).length > 0 ? (
                            clients.filter(c => c.full_name.toLowerCase().includes(clientSearch.toLowerCase())).map(c => (
                              <div 
                                key={c.id} 
                                className="px-4 py-2 hover:bg-slate-50 cursor-pointer text-sm text-slate-700 font-medium border-b border-slate-50 last:border-0"
                                onMouseDown={(e) => {
                                  e.preventDefault();
                                  setNewJobForm({...newJobForm, client_id: c.id});
                                  setSelectedClientName(c.full_name);
                                  setClientSearch('');
                                  setIsDropdownOpen(false);
                                }}
                              >
                                {c.full_name}
                              </div>
                            ))
                          ) : (
                            <div className="px-4 py-3 text-sm text-slate-500 bg-slate-50">
                              <p>No clients found matching <span className="font-bold">"{clientSearch}"</span>.</p>
                              <button 
                                type="button" 
                                onMouseDown={(e) => {
                                  e.preventDefault();
                                  setIsDropdownOpen(false);
                                  setIsNewClient(true);
                                  setNewJobForm({...newJobForm, new_client_name: clientSearch});
                                }}
                                className="mt-2 text-brand font-bold hover:underline flex items-center gap-1"
                              >
                                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"/></svg>
                                Create as New Client
                              </button>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-3 mb-2">
                      <p className="text-xs font-bold text-slate-500 uppercase tracking-wider">New Client Details</p>
                      <input type="text" required value={newJobForm.new_client_name} onChange={e => setNewJobForm({...newJobForm, new_client_name: e.target.value})} placeholder="Full Name" className="w-full bg-white border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand" />
                      <input type="text" required value={newJobForm.new_client_phone} onChange={e => setNewJobForm({...newJobForm, new_client_phone: e.target.value})} placeholder="Phone Number (+251...)" className="w-full bg-white border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand" />
                      <input type="email" required value={newJobForm.new_client_email} onChange={e => setNewJobForm({...newJobForm, new_client_email: e.target.value})} placeholder="Email Address" className="w-full bg-white border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand" />
                      <input type="text" required minLength={6} value={newJobForm.new_client_password} onChange={e => setNewJobForm({...newJobForm, new_client_password: e.target.value})} placeholder="Temporary Password" className="w-full bg-white border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand" />
                    </div>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Job Title</label>
                  <input 
                    type="text" required
                    value={newJobForm.title}
                    onChange={(e) => setNewJobForm({...newJobForm, title: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="e.g. Need a Plumber"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Category</label>
                  <input 
                    type="text" required
                    value={newJobForm.category}
                    onChange={(e) => setNewJobForm({...newJobForm, category: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="e.g. Plumbing"
                  />
                </div>

                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Offered Price (Br)</label>
                  <input 
                    type="number" required min="0" step="0.01"
                    value={newJobForm.offered_price}
                    onChange={(e) => setNewJobForm({...newJobForm, offered_price: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="e.g. 1500"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Description</label>
                  <textarea 
                    required rows="3"
                    value={newJobForm.description}
                    onChange={(e) => setNewJobForm({...newJobForm, description: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="Job details..."
                  ></textarea>
                </div>
              </div>

              <div className="mt-8 flex gap-3 justify-end">
                <button type="button" onClick={() => setShowAddJobModal(false)} className="text-slate-500 font-semibold px-4 py-2 hover:bg-slate-50 rounded-lg transition-colors border border-slate-200 text-sm">Cancel</button>
                <button type="submit" disabled={isSubmitting} className="bg-brand text-white font-bold px-6 py-2 rounded-lg hover:bg-brand-dark transition-colors shadow-sm text-sm disabled:opacity-50">
                  {isSubmitting ? 'Creating...' : 'Create Job'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </AdminLayout>
  );
}
