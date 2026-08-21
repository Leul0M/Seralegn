import React from 'react';
import AdminLayout from './AdminLayout';

export default function AdminSettings() {
  return (
    <AdminLayout activeTab="settings">
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-8">
        <div>
          <h1 className="font-display font-extrabold text-3xl text-slate-900">Platform Settings</h1>
          <p className="text-slate-500 mt-1">Configure pricing models, subscriptions, and general platform parameters.</p>
        </div>
        <div className="flex gap-2">
          <button className="bg-brand text-white font-semibold px-6 py-2.5 rounded-xl hover:bg-brand-dark transition-colors shadow-sm text-sm" onClick={() => alert('Settings saved successfully!')}>Save Changes</button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-2xl shadow-soft border border-slate-100 p-6">
            <h3 className="font-bold text-lg text-slate-900 mb-6 flex items-center gap-2">
              <svg className="w-5 h-5 text-mint" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
              Pricing Model Configuration
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Client Job Post Fee (ETB)</label>
                <p className="text-xs text-slate-500">The amount a homeowner pays to post a job.</p>
                <input type="number" defaultValue="100" className="w-full border-slate-200 border rounded-xl p-3 focus:ring-brand focus:border-brand outline-none transition-colors" />
              </div>
              
              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Worker Monthly Subscription (ETB)</label>
                <p className="text-xs text-slate-500">Recurring monthly fee for workers.</p>
                <input type="number" defaultValue="500" className="w-full border-slate-200 border rounded-xl p-3 focus:ring-brand focus:border-brand outline-none transition-colors" />
              </div>

              <div className="space-y-2">
                <label className="text-sm font-bold text-slate-700">Worker Yearly Subscription (ETB)</label>
                <p className="text-xs text-slate-500">Discounted annual fee for workers.</p>
                <input type="number" defaultValue="5000" className="w-full border-slate-200 border rounded-xl p-3 focus:ring-brand focus:border-brand outline-none transition-colors" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-soft border border-slate-100 p-6">
            <h3 className="font-bold text-lg text-slate-900 mb-6 flex items-center gap-2">
              <svg className="w-5 h-5 text-mint" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"/></svg>
              Platform Access
            </h3>
            
            <div className="space-y-4">
              <label className="flex items-center justify-between p-4 border border-slate-100 rounded-xl cursor-pointer hover:bg-slate-50 transition-colors">
                <div>
                  <p className="font-bold text-slate-900">Maintenance Mode</p>
                  <p className="text-xs text-slate-500">Temporarily disable the mobile apps for updates.</p>
                </div>
                <div className="relative inline-block w-12 h-6 rounded-full bg-slate-200">
                  <input type="checkbox" className="peer opacity-0 w-0 h-0" />
                  <span className="absolute inset-y-0 left-0 w-6 h-6 bg-white border border-slate-300 rounded-full transition-all peer-checked:bg-brand peer-checked:left-6 peer-checked:border-brand"></span>
                </div>
              </label>

              <label className="flex items-center justify-between p-4 border border-slate-100 rounded-xl cursor-pointer hover:bg-slate-50 transition-colors">
                <div>
                  <p className="font-bold text-slate-900">Require ID Verification</p>
                  <p className="text-xs text-slate-500">Workers must have their Fayda ID verified before subscribing.</p>
                </div>
                <div className="relative inline-block w-12 h-6 rounded-full bg-brand">
                  <input type="checkbox" defaultChecked className="peer opacity-0 w-0 h-0" />
                  <span className="absolute inset-y-0 left-6 w-6 h-6 bg-white border border-brand rounded-full transition-all"></span>
                </div>
              </label>
            </div>
          </div>
        </div>
        
        <div className="space-y-6">
          <div className="bg-red-50 rounded-2xl shadow-soft border border-red-100 p-6">
            <h3 className="font-bold text-lg text-red-600 mb-4">Danger Zone</h3>
            <p className="text-sm text-red-800/70 mb-6">These actions are irreversible and will affect the production database.</p>
            
            <button className="w-full bg-white text-red-600 border border-red-200 font-semibold py-3 rounded-xl hover:bg-red-600 hover:text-white transition-colors mb-3">
              Clear Expired Subscriptions
            </button>
            <button className="w-full bg-white text-red-600 border border-red-200 font-semibold py-3 rounded-xl hover:bg-red-600 hover:text-white transition-colors">
              Reset Analytics Data
            </button>
          </div>
        </div>

      </div>
    </AdminLayout>
  );
}
