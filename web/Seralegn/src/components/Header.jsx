import { useEffect, useState } from 'react'
import { MenuIcon } from './icons'

const links = [
  ['Home', '#hero'],
  ['About Us', '#about'],
  ['How it Works', '#how-it-works'],
  ['Services', '#categories'],
]

export default function Header() {
  const [open, setOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 12)
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  const closeMenu = () => setOpen(false)

  return (
    <header className={`site-header ${scrolled ? 'is-scrolled' : ''}`}>
      <div className="header-inner page-width">
        <a href="#hero" className="brand-mark" onClick={closeMenu}>
          <span className="brand-logo"><img src="/logo.svg" alt="Seralgn logo" /></span>
          <span>Seralgn</span>
        </a>
        <nav className="desktop-nav" aria-label="Primary navigation">
          {links.map(([label, href]) => <a href={href} key={href}>{label}</a>)}
        </nav>
        <div className="auth-actions desktop-auth">
          <a href="/sign-in.html">Login</a>
          <a className="button button-small" href="/sign-up.html">Sign Up</a>
        </div>
        <button className="menu-button" type="button" aria-label="Toggle menu" aria-expanded={open} onClick={() => setOpen(!open)}>
          <MenuIcon open={open} />
        </button>
      </div>
      <div className={`mobile-menu ${open ? 'is-open' : ''}`}>
        <div>
          {links.map(([label, href]) => <a href={href} key={href} onClick={closeMenu}>{label}</a>)}
          <div className="mobile-auth auth-actions">
            <a href="/sign-in.html" onClick={closeMenu}>Login</a>
            <a className="button" href="/sign-up.html">Sign Up</a>
          </div>
        </div>
      </div>
    </header>
  )
}
