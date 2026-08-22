import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { logout } from '../services/authService';
import { fetchPendingVerificationsCount } from '../services/userService';
import { useAuth } from '../context/AuthContext';

export default function AdminLayout({ children, activeTab = 'dashboard' }) {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [pendingVerifications, setPendingVerifications] = useState(0);

  useEffect(() => {
    const fetchPendingCount = async () => {
      try {
        const { count, error } = await fetchPendingVerificationsCount();
        
        if (!error && count !== null) {
          setPendingVerifications(count);
        }
      } catch (err) {
        console.error('Error fetching pending verifications count:', err);
      }
    };

    fetchPendingCount();
  }, []);

  const navItems = [
    { id: 'dashboard', name: 'Overview', href: '/admin/dashboard', icon: (
      <svg className="w-5 h-5 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/></svg>
    )},
    { id: 'users', name: 'Users & Subscribers', href: '/admin/users', icon: (
      <svg className="w-5 h-5 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
    )},
    { id: 'verifications', name: 'ID Verifications', href: '/admin/verifications', badge: pendingVerifications > 0 ? pendingVerifications : null, icon: (
      <svg className="w-5 h-5 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/></svg>
    )},
    { id: 'jobs', name: 'Job Moderation', href: '/admin/jobs', icon: (
      <svg className="w-5 h-5 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
    )},
    { id: 'financials', name: 'Financials', href: '/admin/financials', icon: (
      <svg className="w-5 h-5 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
    )},
  ];

  const settingsNavItems = [
    { id: 'settings', name: 'Platform Settings', href: '/admin/settings', icon: (
      <svg className="w-5 h-5 transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
    )}
  ];

  if (!user) return null; // Or a loading spinner

  const displayName = user.user_metadata?.name || user.email || 'Admin';

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <div className="flex h-screen overflow-hidden bg-canvas text-slate-800">
      <aside className="w-64 bg-ink flex-col hidden md:flex shrink-0 z-20">
        <div className="h-20 flex items-center px-8 border-b border-white/5">
          <div className="flex items-center gap-2.5">
            <span className="w-8 h-8 rounded-xl bg-white flex items-center justify-center overflow-hidden">
              <img src="/logo.svg" alt="Seralgn logo" className="w-full h-full object-cover" onError={(e) => { e.target.onerror = null; e.target.src = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%230E5257'%3E%3Cpath d='M12 2L2 22h20L12 2z'/%3E%3C/svg%3E"; }} />
            </span>
            <span className="font-display font-extrabold text-xl text-white">Seralgn <span className="text-mint font-medium text-lg">admin</span></span>
          </div>
        </div>
        <nav className="flex-1 py-6 flex flex-col gap-1 px-4 overflow-y-auto">
          <p className="px-4 text-xs font-bold text-slate-500 uppercase tracking-wider mb-2">Main Menu</p>
          {navItems.map(item => (
            <Link key={item.id} to={item.href} className={`flex items-center justify-between px-4 py-3 rounded-xl transition-all ${activeTab === item.id ? 'bg-brand text-white font-semibold border-r-4 border-mint' : 'text-slate-400 hover:bg-white/5 hover:text-white'}`}>
              <div className="flex items-center gap-3">
                {item.icon}
                {item.name}
              </div>
              {item.badge && <span className="bg-mint text-brand-dark text-[10px] font-bold px-2 py-0.5 rounded-full">{item.badge}</span>}
            </Link>
          ))}
          <p className="px-4 text-xs font-bold text-slate-500 uppercase tracking-wider mt-8 mb-2">Settings</p>
          {settingsNavItems.map(item => (
            <Link key={item.id} to={item.href} className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${activeTab === item.id ? 'bg-brand text-white font-semibold border-r-4 border-mint' : 'text-slate-400 hover:bg-white/5 hover:text-white'}`}>
              {item.icon}
              {item.name}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-white/5">
          <button onClick={handleLogout} className="w-full flex items-center gap-3 px-4 py-3 text-slate-400 hover:text-red-400 transition-colors rounded-xl hover:bg-white/5">
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
            Sign Out
          </button>
        </div>
      </aside>

      <main className="flex-1 flex flex-col h-full overflow-hidden relative">
        <header className="h-20 bg-white border-b border-slate-100 flex items-center justify-between px-8 shrink-0">
          <div className="flex items-center gap-4">
            <button className="md:hidden text-slate-500 hover:text-brand">
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
            </button>
            {activeTab !== 'dashboard' && activeTab !== 'verifications' && activeTab !== 'settings' && (
              <div className="relative hidden sm:block">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                </div>
                <input type="text" className="bg-slate-50 border border-slate-200 text-slate-800 text-sm rounded-full focus:ring-brand focus:border-brand block w-64 pl-9 p-2.5 transition-colors" placeholder={activeTab === 'jobs' ? "Search jobs, categories..." : (activeTab === 'financials' ? "Search transactions..." : "Search users, jobs, IDs...")} />
              </div>
            )}
            {activeTab === 'dashboard' && (
              <div className="relative hidden sm:block">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                </div>
                <input type="text" className="bg-slate-50 border border-slate-200 text-slate-800 text-sm rounded-full focus:ring-brand focus:border-brand block w-64 pl-9 p-2.5 transition-colors" placeholder="Search users, jobs, IDs..." />
              </div>
            )}
          </div>
          <div className="flex items-center gap-6">
            {activeTab === 'dashboard' && (
              <button className="relative text-slate-400 hover:text-brand transition-colors">
                <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.8" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/></svg>
                <span className="absolute top-0 right-0 w-2 h-2 bg-red-500 border-2 border-white rounded-full"></span>
              </button>
            )}
            <div className="flex items-center gap-3 pl-6 border-l border-slate-100">
              <div className="text-right hidden sm:block">
                <p className="text-sm font-bold text-slate-900">{displayName}</p>
                <p className="text-xs text-slate-500">Superadmin</p>
              </div>
              <div className="w-10 h-10 rounded-full bg-brand/10 text-brand flex items-center justify-center font-bold">{displayName.charAt(0).toUpperCase()}</div>
            </div>
          </div>
        </header>

        <div className="flex-1 overflow-y-auto p-6 lg:p-8">
          {children}
        </div>
      </main>
    </div>
  );
}
