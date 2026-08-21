import React, { useState, useEffect } from 'react';
import AdminLayout from './AdminLayout';
import { supabase } from '../../lib/supabase';

export default function AdminUsers() {
  const [workers, setWorkers] = useState([]);
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showAddUserModal, setShowAddUserModal] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [newUserForm, setNewUserForm] = useState({
    full_name: '',
    phone_number: '',
    email: '',
    password: '',
    role: 'worker',
    fayda_number: ''
  });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      // Fetch workers from the view
      const { data: workersData, error: workersError } = await supabase
        .from('admin_worker_status')
        .select('*')
        .order('full_name');

      if (workersError) throw workersError;
      setWorkers(workersData || []);

      // Fetch clients
      const { data: clientsData, error: clientsError } = await supabase
        .from('clients')
        .select('*')
        .order('full_name');

      if (clientsError) throw clientsError;
      setClients(clientsData || []);
      
    } catch (error) {
      console.error('Error fetching users:', error);
      alert('Failed to load users: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleSuspendWorker = async (workerId, currentStatus) => {
    if (!window.confirm(`Are you sure you want to ${currentStatus ? 'unsuspend' : 'suspend'} this worker?`)) return;

    try {
      const { error } = await supabase
        .from('workers')
        .update({ is_suspended: !currentStatus })
        .eq('id', workerId);
      
      if (error) throw error;
      
      // Update local state
      setWorkers(workers.map(w => w.id === workerId ? { ...w, is_suspended: !currentStatus } : w));
    } catch (error) {
      console.error('Error updating worker status:', error);
      alert('Failed to update worker status: ' + error.message);
    }
  };

  const handleAddUser = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const { data, error } = await supabase.rpc('admin_create_user', {
        email: newUserForm.email,
        password: newUserForm.password,
        full_name: newUserForm.full_name,
        phone_number: newUserForm.phone_number,
        user_role: newUserForm.role,
        fayda_number: newUserForm.fayda_number || null
      });

      if (error) throw error;

      alert(`Successfully created ${newUserForm.role}!`);
      setShowAddUserModal(false);
      setNewUserForm({ full_name: '', phone_number: '', email: '', password: '', role: 'worker', fayda_number: '' });
      
      // Refresh list
      fetchUsers();
    } catch (error) {
      console.error('Error creating user:', error);
      alert('Failed to create user: ' + error.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const filteredWorkers = workers.filter(w => 
    w.full_name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    w.phone_number.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const filteredClients = clients.filter(c => 
    c.full_name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    c.phone_number.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <AdminLayout activeTab="users">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">Users & Subscribers</h1>
          <p className="text-slate-500 mt-1">Manage user accounts and subscriptions.</p>
        </div>
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
              <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
            </div>
            <input 
              type="text" 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="bg-slate-50 border border-slate-200 text-slate-800 text-sm rounded-lg focus:ring-brand focus:border-brand block w-full sm:w-64 pl-9 p-2 transition-colors" 
              placeholder="Search users by name, phone..." 
            />
          </div>
          <button 
            onClick={() => setShowAddUserModal(true)}
            className="bg-brand text-white font-bold px-4 py-2 rounded-lg hover:bg-brand-dark transition-colors shadow-sm flex items-center gap-2 text-sm"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4"/></svg>
            Add User
          </button>
        </div>
      </div>
      
      <div className="bg-white rounded-2xl shadow-soft border border-slate-100 overflow-hidden mb-8">
        <div className="px-6 py-4 border-b border-slate-100 bg-slate-50 flex justify-between items-center">
          <h2 className="font-bold text-slate-900">Workers</h2>
          <span className="bg-brand/10 text-brand text-xs font-bold px-2.5 py-1 rounded-full">{workers.length} Total</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-white text-slate-500 text-xs uppercase tracking-wider border-b border-slate-100">
                <th className="p-4 font-bold">Name</th>
                <th className="p-4 font-bold">Phone</th>
                <th className="p-4 font-bold">Verification</th>
                <th className="p-4 font-bold text-center">Flags</th>
                <th className="p-4 font-bold">Sub. Days Left</th>
                <th className="p-4 font-bold text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-sm divide-y divide-slate-100">
              {loading ? (
                <tr><td colSpan="6" className="p-8 text-center text-slate-500">Loading workers...</td></tr>
              ) : filteredWorkers.length === 0 ? (
                <tr><td colSpan="6" className="p-8 text-center text-slate-500">No workers found.</td></tr>
              ) : (
                filteredWorkers.map(worker => (
                  <tr key={worker.id} className="hover:bg-slate-50 transition-colors">
                    <td className="p-4 font-medium text-slate-900">{worker.full_name}</td>
                    <td className="p-4 text-slate-600">{worker.phone_number}</td>
                    <td className="p-4">
                      {worker.fayda_verified ? (
                        <span className="bg-green-50 text-green-600 px-2.5 py-1 rounded-full text-xs font-bold border border-green-200">Verified</span>
                      ) : (
                        <span className="bg-yellow-50 text-yellow-600 px-2.5 py-1 rounded-full text-xs font-bold border border-yellow-200">Pending</span>
                      )}
                    </td>
                    <td className="p-4 text-center">
                      <span className={`font-bold ${worker.flag_count > 0 ? 'text-red-500' : 'text-slate-400'}`}>{worker.flag_count}</span>
                    </td>
                    <td className="p-4">
                      {worker.days_left > 0 ? (
                        <span className="text-slate-900 font-medium">{worker.days_left} days</span>
                      ) : (
                        <span className="text-red-500 font-medium">Expired</span>
                      )}
                    </td>
                    <td className="p-4 text-right">
                      <button 
                        onClick={() => handleSuspendWorker(worker.id, worker.is_suspended)}
                        className={`px-3 py-1.5 rounded-lg font-semibold transition-colors shadow-sm text-xs ${worker.is_suspended ? 'bg-green-500 hover:bg-green-600 text-white' : 'bg-red-50 text-red-600 hover:bg-red-100 border border-red-200'}`}
                      >
                        {worker.is_suspended ? 'Unsuspend' : 'Suspend'}
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      <div className="bg-white rounded-2xl shadow-soft border border-slate-100 overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-100 bg-slate-50 flex justify-between items-center">
          <h2 className="font-bold text-slate-900">Clients</h2>
          <span className="bg-brand/10 text-brand text-xs font-bold px-2.5 py-1 rounded-full">{clients.length} Total</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-white text-slate-500 text-xs uppercase tracking-wider border-b border-slate-100">
                <th className="p-4 font-bold">Name</th>
                <th className="p-4 font-bold">Phone</th>
                <th className="p-4 font-bold">Joined</th>
              </tr>
            </thead>
            <tbody className="text-sm divide-y divide-slate-100">
              {loading ? (
                <tr><td colSpan="3" className="p-8 text-center text-slate-500">Loading clients...</td></tr>
              ) : filteredClients.length === 0 ? (
                <tr><td colSpan="3" className="p-8 text-center text-slate-500">No clients found.</td></tr>
              ) : (
                filteredClients.map(client => (
                  <tr key={client.id} className="hover:bg-slate-50 transition-colors">
                    <td className="p-4 font-medium text-slate-900">{client.full_name}</td>
                    <td className="p-4 text-slate-600">{client.phone_number}</td>
                    <td className="p-4 text-slate-500">{new Date(client.created_at).toLocaleDateString()}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add User Modal */}
      {showAddUserModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 backdrop-blur-sm bg-slate-900/40">
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md flex flex-col overflow-hidden border border-slate-200">
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <h2 className="font-display font-bold text-xl text-slate-900 flex items-center gap-2">
                <svg className="w-6 h-6 text-brand" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" /></svg>
                Create New User
              </h2>
              <button onClick={() => setShowAddUserModal(false)} className="text-slate-400 hover:text-slate-600 transition-colors p-1 rounded-full hover:bg-slate-200">
                <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>
            
            <form onSubmit={handleAddUser} className="p-6 overflow-y-auto max-h-[70vh]">
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Account Role</label>
                  <select 
                    required
                    value={newUserForm.role}
                    onChange={(e) => setNewUserForm({...newUserForm, role: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                  >
                    <option value="worker">Worker</option>
                    <option value="client">Client</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Full Name</label>
                  <input 
                    type="text" required
                    value={newUserForm.full_name}
                    onChange={(e) => setNewUserForm({...newUserForm, full_name: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="e.g. Abebe Kebede"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Phone Number</label>
                  <input 
                    type="text" required
                    value={newUserForm.phone_number}
                    onChange={(e) => setNewUserForm({...newUserForm, phone_number: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="+251911..."
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Email Address</label>
                  <input 
                    type="email" required
                    value={newUserForm.email}
                    onChange={(e) => setNewUserForm({...newUserForm, email: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="user@example.com"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-bold text-slate-700 mb-1">Temporary Password</label>
                  <input 
                    type="text" required
                    value={newUserForm.password}
                    onChange={(e) => setNewUserForm({...newUserForm, password: e.target.value})}
                    className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                    placeholder="min 6 characters"
                    minLength={6}
                  />
                </div>
                
                {newUserForm.role === 'worker' && (
                  <div>
                    <label className="block text-sm font-bold text-slate-700 mb-1">Fayda ID Number (Optional)</label>
                    <input 
                      type="text"
                      value={newUserForm.fayda_number}
                      onChange={(e) => setNewUserForm({...newUserForm, fayda_number: e.target.value})}
                      className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-brand focus:ring-1 focus:ring-brand transition-colors"
                      placeholder="Leave blank to generate automatically"
                    />
                  </div>
                )}
              </div>

              <div className="mt-8 flex gap-3 justify-end">
                <button type="button" onClick={() => setShowAddUserModal(false)} className="text-slate-500 font-semibold px-4 py-2 hover:bg-slate-50 rounded-lg transition-colors border border-slate-200 text-sm">Cancel</button>
                <button type="submit" disabled={isSubmitting} className="bg-brand text-white font-bold px-6 py-2 rounded-lg hover:bg-brand-dark transition-colors shadow-sm text-sm disabled:opacity-50">
                  {isSubmitting ? 'Creating...' : 'Create Account'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </AdminLayout>
  );
}
