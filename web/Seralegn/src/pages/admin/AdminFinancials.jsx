import React, { useState, useEffect } from 'react';
import AdminLayout from '../../layouts/AdminLayout';
import { fetchFinancialTransactions, fetchFinancialStats } from '../../services/dashboardService';
import { useToast } from '../../context/ToastContext';
import TableLoader from '../../components/common/TableLoader';
import EmptyState from '../../components/common/EmptyState';
import Pagination from '../../components/common/Pagination';
import { useDebounce } from '../../hooks/useDebounce';

export default function AdminFinancials() {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [revenue, setRevenue] = useState(0);
  const [filter, setFilter] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  const [page, setPage] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [allTimeSuccessCount, setAllTimeSuccessCount] = useState(0);
  const [allTimeFailedCount, setAllTimeFailedCount] = useState(0);
  const PAGE_SIZE = 10;
  const { showToast } = useToast();

  useEffect(() => {
    setPage(1);
  }, [debouncedSearchTerm, filter]);

  useEffect(() => {
    fetchFinancials();
  }, [page, debouncedSearchTerm, filter]);

  const fetchFinancials = async () => {
    setLoading(true);
    try {
      // 1. Fetch paginated transactions
      const { data, error, count } = await fetchFinancialTransactions({
        page,
        pageSize: PAGE_SIZE,
        filter,
        searchTerm: debouncedSearchTerm
      });

      if (error) throw error;
      setTransactions(data || []);
      setTotalCount(count || 0);
      
      // 2. Fetch overall stats
      const { revenue: rev, successCount, failedCount, error: statsError } = await fetchFinancialStats();
        
      if (!statsError) {
        setRevenue(rev);
        setAllTimeSuccessCount(successCount);
        setAllTimeFailedCount(failedCount);
      }
    } catch (error) {
      console.error('Error fetching financials:', error);
      showToast('Failed to load financials: ' + error.message, 'error');
    } finally {
      setLoading(false);
    }
  };
  
  // Frontend filtering removed, using server-side query filtering

  return (
    <AdminLayout activeTab="financials">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">Financials</h1>
          <p className="text-slate-500 mt-1">Track revenue from worker subscriptions.</p>
        </div>
        <div className="flex gap-2">
          <button className="bg-white border border-slate-200 text-slate-600 font-semibold px-4 py-2 rounded-lg hover:bg-slate-50 transition-colors shadow-sm text-sm">Download Ledger</button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-gradient-to-br from-brand to-brand-dark rounded-2xl p-6 text-white shadow-soft">
          <p className="text-white/80 text-sm font-medium mb-1">Total Revenue (All Time)</p>
          <h3 className="font-display font-extrabold text-4xl">{revenue.toLocaleString()} <span className="text-lg">ETB</span></h3>
        </div>
        <div className="bg-white rounded-2xl p-6 border border-slate-100 shadow-soft">
          <p className="text-slate-500 text-sm font-medium mb-1">Successful Subscriptions</p>
          <h3 className="font-display font-extrabold text-3xl text-slate-900">{allTimeSuccessCount}</h3>
        </div>
        <div className="bg-white rounded-2xl p-6 border border-slate-100 shadow-soft">
          <p className="text-slate-500 text-sm font-medium mb-1">Failed/Pending Subscriptions</p>
          <h3 className="font-display font-extrabold text-3xl text-slate-900">{allTimeFailedCount}</h3>
        </div>
      </div>

      <div className="bg-white p-4 rounded-t-2xl border-x border-t border-slate-100 flex items-center gap-4 border-b">
        <select 
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-sm outline-none focus:border-brand cursor-pointer"
        >
          <option value="All">All Statuses</option>
          <option value="success">Successful</option>
          <option value="pending">Pending</option>
          <option value="failed">Failed</option>
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
            placeholder="Search ref, user..." 
          />
        </div>
        
        <div className="text-sm text-slate-500">
          {totalCount} Transaction{totalCount !== 1 ? 's' : ''} found
        </div>
      </div>

      <div className="bg-white rounded-b-2xl shadow-soft border-x border-b border-slate-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                <th className="p-4 font-bold">Transaction Ref</th>
                <th className="p-4 font-bold">Date & Time</th>
                <th className="p-4 font-bold">User</th>
                <th className="p-4 font-bold">Amount</th>
                <th className="p-4 font-bold">Status</th>
              </tr>
            </thead>
            {loading ? (
              <TableLoader columns={5} />
            ) : transactions.length === 0 ? (
              <EmptyState message="No transactions found." colSpan={5} />
            ) : (
              <tbody className="text-sm divide-y divide-slate-100">
                {transactions.map(tx => (
                  <tr key={tx.id} className="hover:bg-slate-50 transition-colors">
                    <td className="p-4 font-mono text-slate-500">{tx.chapa_tx_ref}</td>
                    <td className="p-4 text-slate-600">
                      {new Date(tx.created_at).toLocaleDateString()}<br/>
                      <span className="text-xs text-slate-400">{new Date(tx.created_at).toLocaleTimeString()}</span>
                    </td>
                    <td className="p-4 font-medium text-slate-900">{tx.workers?.full_name || 'Unknown User'}</td>
                    <td className="p-4 font-bold text-slate-900">{tx.amount} ETB</td>
                    <td className="p-4 font-medium">
                      {tx.status === 'success' && <span className="text-green-600 font-bold flex items-center gap-1"><svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"/></svg> Successful</span>}
                      {tx.status === 'pending' && <span className="text-yellow-600 font-bold flex items-center gap-1">Pending</span>}
                      {tx.status === 'failed' && <span className="text-red-500 font-bold flex items-center gap-1"><svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"/></svg> Failed</span>}
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
    </AdminLayout>
  );
}
