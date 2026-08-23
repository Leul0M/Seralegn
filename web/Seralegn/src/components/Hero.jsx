import { useEffect, useState } from 'react'

export default function Hero() {
  const [pointer, setPointer] = useState({ x: 0, y: 0 })

  useEffect(() => {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (reduced || !window.matchMedia('(pointer: fine)').matches) return
    const onMove = (event) => setPointer({ x: event.clientX / window.innerWidth - 0.5, y: event.clientY / window.innerHeight - 0.5 })
    window.addEventListener('mousemove', onMove, { passive: true })
    return () => window.removeEventListener('mousemove', onMove)
  }, [])

  return (
    <section id="hero" className="relative overflow-hidden pt-14 pb-24 lg:pt-20 lg:pb-32">
      <div className="hidden lg:block absolute top-24 left-[7%] w-10 h-10 rounded-full border-4 border-brand/25 pointer-events-none" style={{ transform: `translate(${pointer.x * 24 * 0.4}px, ${pointer.y * 24 * 0.4}px)` }}></div>
      <div className="hidden lg:block absolute top-[19rem] left-[3%] w-2.5 h-2.5 rounded-full bg-brand/40 pointer-events-none" style={{ transform: `translate(${pointer.x * 24 * 0.7}px, ${pointer.y * 24 * 0.7}px)` }}></div>
      <div className="hidden lg:block absolute bottom-16 left-[6%] w-16 h-16 rounded-full border-[6px] border-brand/15 pointer-events-none" style={{ transform: `translate(${pointer.x * 24 * 0.3}px, ${pointer.y * 24 * 0.3}px)` }}></div>
      <div className="hidden lg:block absolute top-10 right-[26%] w-16 h-16 rounded-full border-[6px] border-mint pointer-events-none animate-spin-slow" style={{ transform: `translate(${pointer.x * 24 * 0.6}px, ${pointer.y * 24 * 0.6}px)` }}></div>
      <div className="hidden lg:block absolute top-8 right-[6%] w-3 h-3 rounded-full bg-ink pointer-events-none" style={{ transform: `translate(${pointer.x * 24 * 0.9}px, ${pointer.y * 24 * 0.9}px)` }}></div>
      <div className="hidden lg:block absolute bottom-28 right-[2%] w-9 h-9 rounded-full border-4 border-brand/20 pointer-events-none" style={{ transform: `translate(${pointer.x * 24 * 0.5}px, ${pointer.y * 24 * 0.5}px)` }}></div>
      <div className="hidden lg:block absolute top-1/2 right-[9%] w-2 h-2 rounded-full bg-brand/50 pointer-events-none" style={{ transform: `translate(${pointer.x * 24 * 0.8}px, ${pointer.y * 24 * 0.8}px)` }}></div>

      <div className="max-w-7xl mx-auto grid lg:grid-cols-2 gap-16 items-center px-6 lg:px-10">
        <div className="relative z-10">
          <h1 data-reveal style={{ '--reveal-delay': '0ms' }} className="font-display font-extrabold text-[2.75rem] leading-[1.1] sm:text-6xl sm:leading-[1.05] text-slate-900">
            Find trusted home<br className="hidden sm:block" /> repair workers near you
          </h1>
          <p data-reveal style={{ '--reveal-delay': '120ms' }} className="mt-6 text-slate-500 text-lg max-w-md leading-relaxed">
            Post a job, receive bids from verified local professionals, and pay safely through Chapa. No middlemen. No waiting days.
          </p>
          <div className="mt-9 flex flex-wrap items-center gap-4" data-reveal style={{ '--reveal-delay': '220ms' }}>
            <a href="#categories" className="magnetic group inline-flex items-center gap-2.5 bg-brand hover:bg-brand-dark text-white font-semibold pl-7 pr-6 py-4 rounded-full shadow-soft transition-colors">
              Explore Services
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 transition-transform duration-300 group-hover:translate-x-1"><path d="M5 12h14M13 6l6 6-6 6" /></svg>
            </a>
            <a href="#download-app" className="magnetic inline-flex items-center gap-2.5 bg-slate-900 hover:bg-slate-800 text-white font-semibold px-6 py-4 rounded-full shadow-soft transition-colors border border-slate-700">
              <span className="w-2 h-2 rounded-full bg-mint animate-pulse"></span>
              Download Mobile App
            </a>
          </div>

          <div data-reveal style={{ '--reveal-delay': '320ms' }} className="mt-16 flex items-center gap-5">
            <span className="hidden sm:block w-2.5 h-2.5 rounded-full bg-brand/50 shrink-0"></span>
            <div className="bg-white rounded-2xl shadow-xl shadow-slate-200/60 px-8 py-6 flex items-center divide-x divide-slate-100 gap-8">
              <div>
                <p className="font-display font-extrabold text-2xl sm:text-3xl text-slate-900"><span className="counter" data-count-to="300">0</span>k+</p>
                <p className="text-sm text-slate-500 mt-1">Active Users</p>
              </div>
              <div className="pl-8">
                <p className="font-display font-extrabold text-2xl sm:text-3xl text-slate-900"><span className="counter" data-count-to="12">0</span>k+</p>
                <p className="text-sm text-slate-500 mt-1">Jobs Completed</p>
              </div>
            </div>
          </div>
        </div>

        <div data-reveal="zoom" style={{ '--reveal-delay': '150ms' }} className="relative flex justify-center lg:justify-end">
          <div id="hero-portrait" className="relative w-[300px] h-[300px] sm:w-[380px] sm:h-[380px] transition-transform duration-300 ease-out" style={{ transform: `rotate(${pointer.x * 3}deg) translate(${pointer.x * 8}px, ${pointer.y * 8}px)` }}>
            <div className="absolute inset-0 rounded-full border-[16px] border-mint/70"></div>
            <div className="absolute inset-[8%] rounded-full overflow-hidden shadow-2xl ring-8 ring-white">
              <img src="/assets/hero.jpeg" className="w-full h-full object-cover" alt="Portrait of a smiling Seralgn job seeker holding a laptop" />
            </div>
            <div className="absolute -bottom-3 -right-3 w-14 h-14 bg-ink rounded-xl rotate-6 shadow-lg"></div>
            <div className="hidden sm:block absolute -top-6 -left-8 w-14 h-14 rounded-full border-[5px] border-brand/20"></div>
            <div className="hidden sm:block absolute top-1/3 -right-10 w-5 h-5 rounded-full bg-mint animate-float [animation-delay:.8s]"></div>
          </div>
        </div>
      </div>
    </section>
  )
}
