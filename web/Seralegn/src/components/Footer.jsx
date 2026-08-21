export default function Footer() {
  return (
    <footer className="bg-ink text-slate-300 pt-20 pb-8 relative overflow-hidden">
      <div className="hidden lg:block absolute -top-10 right-10 w-40 h-40 rounded-full border border-white/5 pointer-events-none"></div>
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <div className="grid sm:grid-cols-2 lg:grid-cols-[1.5fr_1fr_1fr_1fr_1.1fr] gap-10 pb-14 border-b border-white/10">
          <div data-reveal>
            <a href="/" className="flex items-center gap-2.5">
              <span className="w-10 h-10 rounded-2xl bg-white/10 flex items-center justify-center">
                <img src="/logo.svg" alt="Seralgn logo" className="w-6 h-6" />
              </span>
              <span className="font-display font-extrabold text-2xl text-white">Seralgn</span>
            </a>
            <p className="text-sm text-slate-400 leading-relaxed mt-5 max-w-xs">
              ሰራለኝ — Ethiopia's trusted platform connecting homeowners with verified local workers across Addis Ababa.
            </p>
          </div>

          <div data-reveal style={{ '--reveal-delay': '60ms' }}>
            <h5 className="font-display font-bold text-white mb-5">Home</h5>
            <ul className="space-y-3 text-sm text-slate-400">
              <li><a href="#hero" className="hover:text-mint transition-colors">Discover Jobs</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Browse Companies</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Career Advice</a></li>
            </ul>
          </div>

          <div data-reveal style={{ '--reveal-delay': '120ms' }}>
            <h5 className="font-display font-bold text-white mb-5">Company</h5>
            <ul className="space-y-3 text-sm text-slate-400">
              <li><a href="#about" className="hover:text-mint transition-colors">About Us</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Our Partners</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Careers</a></li>
            </ul>
          </div>

          <div data-reveal style={{ '--reveal-delay': '180ms' }}>
            <h5 className="font-display font-bold text-white mb-5">Features</h5>
            <ul className="space-y-3 text-sm text-slate-400">
              <li><a href="#hero" className="hover:text-mint transition-colors">Job Alerts</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Resume Builder</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Salary Guide</a></li>
              <li><a href="#hero" className="hover:text-mint transition-colors">Help Center</a></li>
            </ul>
          </div>

          <div data-reveal style={{ '--reveal-delay': '240ms' }}>
            <h5 className="font-display font-bold text-white mb-5">Contact Us</h5>
            <ul className="space-y-4 text-sm text-slate-400">
              <li className="flex items-center gap-2.5">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-mint shrink-0"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                <a href="mailto:hello@seralgn.com" className="hover:text-mint transition-colors">hello@Seralgn.com</a>
              </li>
              <li className="flex items-center gap-2.5">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-mint shrink-0"><path d="M6 3h3l1.5 4.5-2 1.5a12 12 0 006 6l1.5-2L20 14.5V18a2 2 0 01-2 2C10.5 20 4 13.5 4 6a2 2 0 012-2z"/></svg>
                <a href="tel:+251112345678" className="hover:text-mint transition-colors">+251 11 234 5678</a>
              </li>
              <li className="flex items-start gap-2.5">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-mint shrink-0 mt-0.5"><path d="M12 21s7-6.5 7-12a7 7 0 10-14 0c0 5.5 7 12 7 12z"/><circle cx="12" cy="9" r="2.3"/></svg>
                Addis Ababa, Ethiopia
              </li>
            </ul>
          </div>
        </div>

        <div className="pt-6 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
          <p>© 2026 Seralgn. All rights reserved.</p>
          <div className="flex items-center gap-6">
            <a href="#hero" className="hover:text-mint transition-colors">Privacy Policy</a>
            <a href="#hero" className="hover:text-mint transition-colors">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
  )
}
