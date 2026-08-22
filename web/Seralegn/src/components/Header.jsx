import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { logout } from '../services/authService'
import { useAuth } from '../context/AuthContext'

export default function Header() {
  const [open, setOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)
  const { user } = useAuth()

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12)
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  const closeMenu = () => setOpen(false)

  return (
    <header id="site-header" className={`sticky top-0 z-50 bg-white/90 backdrop-blur border-b border-slate-100 ${scrolled ? 'is-scrolled' : ''}`}>
      <div className="header-inner max-w-7xl mx-auto flex items-center justify-between px-6 lg:px-10 py-4 transition-[padding] duration-300">
        <Link to="/" className="flex items-center gap-2.5 shrink-0 group" onClick={closeMenu}>
          <span className="w-10 h-10 rounded-2xl flex items-center justify-center shadow-md transition-transform duration-500 group-hover:rotate-[18deg] overflow-hidden">
            <img src="/logo.svg" alt="Seralgn logo" className="w-full h-full object-cover" />
          </span>
          <span className="font-display font-extrabold text-2xl text-slate-900">Seralgn</span>
        </Link>

        <nav className="hidden md:flex items-center gap-9 text-[15px] font-medium text-slate-600">
          <Link to="/" className="relative py-1 hover:text-brand transition-colors after:content-[''] after:absolute after:left-0 after:-bottom-0.5 after:h-[2px] after:w-0 after:bg-brand after:transition-all after:duration-300 hover:after:w-full">Home</Link>
          <a href="#about" className="relative py-1 hover:text-brand transition-colors after:content-[''] after:absolute after:left-0 after:-bottom-0.5 after:h-[2px] after:w-0 after:bg-brand after:transition-all after:duration-300 hover:after:w-full">About Us</a>
          <a href="#how-it-works" className="relative py-1 hover:text-brand transition-colors after:content-[''] after:absolute after:left-0 after:-bottom-0.5 after:h-[2px] after:w-0 after:bg-brand after:transition-all after:duration-300 hover:after:w-full">How it Works</a>
          <a href="#categories" className="relative py-1 hover:text-brand transition-colors after:content-[''] after:absolute after:left-0 after:-bottom-0.5 after:h-[2px] after:w-0 after:bg-brand after:transition-all after:duration-300 hover:after:w-full">Services</a>
        </nav>

        <div className="hidden sm:flex items-center gap-5" id="auth-buttons">
          {user && user.role === 'admin' ? (
            <div className="flex items-center gap-4">
              <span className="text-sm font-medium text-slate-600">Hi, {user.name.split(' ')[0]}</span>
              <button onClick={logout} className="text-[15px] font-medium text-slate-600 hover:text-brand transition-colors cursor-pointer">Logout</button>
              <Link to="/admin/dashboard" className="bg-brand text-white text-sm font-semibold px-5 py-2.5 rounded-full">Admin Dashboard</Link>
            </div>
          ) : (
            <>
              <Link to="/sign-in" className="text-[15px] font-medium text-slate-600 hover:text-brand transition-colors">Login</Link>
              <Link to="/sign-up" className="magnetic bg-brand hover:bg-brand-dark text-white text-sm font-semibold px-5 py-2.5 rounded-full transition-colors shadow-md shadow-brand/20 hover:shadow-lg hover:shadow-brand/30">Sign Up</Link>
            </>
          )}
        </div>

        <button id="menu-btn" className={`md:hidden w-10 h-10 flex items-center justify-center rounded-full text-slate-700 hover:bg-slate-100 transition-colors ${open ? 'is-open' : ''}`} aria-label="Toggle menu" aria-expanded={open} aria-controls="mobile-menu" onClick={() => setOpen(!open)}>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" className="w-6 h-6"><path d="M4 6h16M4 12h16M4 18h16"/></svg>
        </button>
      </div>

      <div id="mobile-menu" className={`md:hidden border-t border-slate-100 bg-white ${open ? 'is-open' : ''}`}>
        <div className="px-6 py-5 space-y-4">
          <a href="#" className="block text-slate-600 font-medium" onClick={closeMenu}>Home</a>
          <a href="#about" className="block text-slate-600 font-medium" onClick={closeMenu}>About Us</a>
          <a href="#how-it-works" className="block text-slate-600 font-medium" onClick={closeMenu}>How it Works</a>
          <a href="#categories" className="block text-slate-600 font-medium" onClick={closeMenu}>Services</a>
          
          <div id="mobile-auth-buttons" className="pt-3 flex flex-col gap-4 border-t border-slate-100">
            {user && user.role === 'admin' ? (
              <>
                <span className="text-slate-600 font-medium">Hi, {user.name}</span>
                <Link to="/admin/dashboard" className="bg-brand text-white text-center text-sm font-semibold px-5 py-2.5 rounded-full" onClick={closeMenu}>Admin Dashboard</Link>
                <button onClick={() => { logout(); closeMenu(); }} className="text-left text-slate-600 font-medium cursor-pointer">Logout</button>
              </>
            ) : (
              <>
                <Link to="/sign-in" className="text-slate-600 font-medium" onClick={closeMenu}>Login</Link>
                <Link to="/sign-up" className="bg-brand text-white text-center text-sm font-semibold px-5 py-2.5 rounded-full" onClick={closeMenu}>Sign Up</Link>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}
