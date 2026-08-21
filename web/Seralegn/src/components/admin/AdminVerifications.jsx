import React, { useState, useEffect } from 'react';
import AdminLayout from './AdminLayout';
import { supabase } from '../../lib/supabase';

export default function AdminVerifications() {
  const [showReviewModal, setShowReviewModal] = useState(false);
  const [showRejectReason, setShowRejectReason] = useState(false);
  const [pendingWorkers, setPendingWorkers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedWorker, setSelectedWorker] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchPendingVerifications();
  }, []);

  const fetchPendingVerifications = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('workers')
        .select('*')
        .eq('fayda_verified', false)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setPendingWorkers(data || []);
    } catch (error) {
      console.error('Error fetching verifications:', error);
      alert('Failed to load pending verifications: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async () => {
    if (!selectedWorker) return;
    try {
      const { error } = await supabase
        .from('workers')
        .update({ fayda_verified: true })
        .eq('id', selectedWorker.id);

      if (error) throw error;
      
      // Update UI
      setPendingWorkers(pendingWorkers.filter(w => w.id !== selectedWorker.id));
      setShowReviewModal(false);
      setSelectedWorker(null);
    } catch (error) {
      console.error('Error approving worker:', error);
      alert('Failed to approve worker: ' + error.message);
    }
  };

  const handleReviewClick = (worker) => {
    setSelectedWorker(worker);
    setShowReviewModal(true);
    setShowRejectReason(false);
  };

  return (
    <AdminLayout activeTab="verifications">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">ID Verifications Queue</h1>
          <p className="text-slate-500 mt-1">Review and approve Fayda ID and Selfie submissions from workers.</p>
        </div>
      </div>

      <div className="bg-white p-4 rounded-t-2xl border-x border-t border-slate-100 flex items-center gap-4 border-b">
        <select className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-sm outline-none focus:border-brand cursor-pointer">
          <option>Pending Review ({pendingWorkers.length})</option>
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
            placeholder="Search by name or ID number..." 
          />
        </div>
      </div>

      <div className="bg-white rounded-b-2xl shadow-soft border-x border-b border-slate-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                <th className="p-4 font-bold">Worker Details</th>
                <th className="p-4 font-bold">Submission Date</th>
                <th className="p-4 font-bold">Document Type</th>
                <th className="p-4 font-bold">Status</th>
                <th className="p-4 font-bold text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="text-sm divide-y divide-slate-100">
              {loading ? (
                <tr><td colSpan="5" className="p-8 text-center text-slate-500">Loading pending verifications...</td></tr>
              ) : pendingWorkers.filter(w => 
                  w.full_name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                  w.fayda_number?.toLowerCase().includes(searchTerm.toLowerCase())
                ).length === 0 ? (
                <tr><td colSpan="5" className="p-8 text-center text-slate-500">No pending verifications found.</td></tr>
              ) : (
                pendingWorkers
                  .filter(w => 
                    w.full_name.toLowerCase().includes(searchTerm.toLowerCase()) || 
                    w.fayda_number?.toLowerCase().includes(searchTerm.toLowerCase())
                  )
                  .map(worker => (
                  <tr key={worker.id} className="hover:bg-slate-50 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-brand/10 text-brand flex items-center justify-center font-bold">
                          {worker.full_name.charAt(0).toUpperCase()}
                        </div>
                        <div>
                          <p className="font-bold text-slate-900">{worker.full_name}</p>
                          <p className="text-xs text-slate-500">{worker.phone_number}</p>
                        </div>
                      </div>
                    </td>
                    <td className="p-4 text-slate-600">
                      {new Date(worker.created_at).toLocaleDateString()}<br/>
                    </td>
                    <td className="p-4 font-medium text-slate-900">Fayda ID</td>
                    <td className="p-4">
                      <span className="bg-yellow-50 text-yellow-600 px-2.5 py-1 rounded-full text-xs font-bold border border-yellow-200">Pending</span>
                    </td>
                    <td className="p-4 text-right">
                      <button onClick={() => handleReviewClick(worker)} className="bg-brand text-white hover:bg-brand-dark px-4 py-1.5 rounded-lg font-semibold transition-colors shadow-sm text-sm">Review</button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
      
      {/* Review Modal Overlay */}
      {showReviewModal && selectedWorker && (
        <div className="absolute inset-0 z-50 flex items-center justify-center p-4 sm:p-6 backdrop-blur-sm bg-slate-900/40">
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-4xl max-h-full flex flex-col overflow-hidden border border-slate-200">
            {/* Header */}
            <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
              <h2 className="font-display font-bold text-xl text-slate-900">Review ID Submission</h2>
              <button onClick={() => setShowReviewModal(false)} className="text-slate-400 hover:text-slate-600 transition-colors p-1 rounded-full hover:bg-slate-200">
                <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
            </div>
            
            {/* Content */}
            <div className="p-6 overflow-y-auto flex-1 bg-canvas">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                {/* Details Panel */}
                <div className="bg-white p-5 rounded-2xl shadow-sm border border-slate-100 space-y-4">
                  <div>
                    <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Worker Name</p>
                    <p className="font-bold text-slate-900 text-lg">{selectedWorker.full_name}</p>
                  </div>
                  <div>
                    <p className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">ID Number Provided</p>
                    <p className="font-mono font-medium text-slate-700 bg-slate-50 px-2 py-1 rounded inline-block">{selectedWorker.fayda_number}</p>
                  </div>
                  <hr className="border-slate-100" />
                  <div className="bg-blue-50 p-3 rounded-xl border border-blue-100">
                    <p className="text-xs text-blue-800 font-medium leading-relaxed">
                      <span className="font-bold">Instructions:</span> Verify that the name and face match the provided ID, and that the ID is not expired.
                    </p>
                  </div>
                </div>
                
                {/* Images Panel (Mocked since DB has no image columns currently) */}
                <div className="md:col-span-2 grid grid-cols-2 gap-4">
                  <div className="bg-white p-2 rounded-2xl shadow-sm border border-slate-100 flex flex-col">
                    <p className="text-xs font-bold text-slate-500 mb-2 px-2 pt-1">ID Document (Front)</p>
                    <div className="bg-slate-100 rounded-xl flex-1 flex items-center justify-center overflow-hidden border border-slate-200">
                      <div className="text-slate-400 flex flex-col items-center gap-2 p-8 text-center">
                        <svg className="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"/></svg>
                        <span className="text-sm font-medium">Image Not Provided by Backend</span>
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-white p-2 rounded-2xl shadow-sm border border-slate-100 flex flex-col">
                    <p className="text-xs font-bold text-slate-500 mb-2 px-2 pt-1">Live Selfie</p>
                    <div className="bg-slate-100 rounded-xl flex-1 flex items-center justify-center overflow-hidden border border-slate-200">
                      <div className="text-slate-400 flex flex-col items-center gap-2 p-8 text-center">
                        <svg className="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zm6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                        <span className="text-sm font-medium">Image Not Provided by Backend</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              
              {/* Reject Reason */}
              {showRejectReason && (
                <div className="bg-white p-4 rounded-2xl border border-red-100 shadow-sm mb-6">
                  <label className="block text-sm font-bold text-slate-700 mb-2">Reason for Rejection</label>
                  <select className="w-full bg-slate-50 border border-slate-200 rounded-lg p-2.5 text-sm outline-none focus:border-red-400 focus:ring-1 focus:ring-red-400 transition-colors">
                    <option>ID Document is blurry or illegible</option>
                    <option>Face in selfie does not match ID</option>
                    <option>ID Document is expired</option>
                    <option>Name provided does not match ID</option>
                    <option>Suspected fraudulent document</option>
                  </select>
                </div>
              )}
            </div>
            
            {/* Footer / Actions */}
            <div className="px-6 py-4 border-t border-slate-100 bg-white flex justify-between items-center">
              <button onClick={() => setShowRejectReason(!showRejectReason)} className="text-red-500 font-semibold px-4 py-2 hover:bg-red-50 rounded-lg transition-colors text-sm">Reject Submission</button>
              <div className="flex gap-3">
                <button onClick={() => setShowReviewModal(false)} className="text-slate-500 font-semibold px-4 py-2 hover:bg-slate-50 rounded-lg transition-colors border border-slate-200 text-sm">Cancel</button>
                <button onClick={handleApprove} className="bg-brand text-white font-bold px-6 py-2 rounded-lg hover:bg-brand-dark transition-colors shadow-sm text-sm">Approve ID</button>
              </div>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
