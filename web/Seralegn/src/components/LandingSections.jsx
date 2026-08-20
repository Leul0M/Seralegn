import { useEffect, useRef, useState } from 'react'

export default function TrustedBy() {
  return (
    <section className="bg-mint py-10 md:py-14 overflow-hidden">
      <div className="max-w-5xl mx-auto px-6 text-center">
        <h3 data-reveal className="font-display font-bold text-lg md:text-xl text-brand-dark mb-8">Trusted by 10+ Ethiopian Leading Companies</h3>
      </div>
      <div className="marquee-wrap marquee-fade">
        <div className="marquee-track animate-marquee flex w-max items-center gap-16 pr-16">
          <span className="text-xl font-semibold text-slate-800/80">Insa</span>
          <span className="text-xl font-bold italic text-slate-800/80">Chapa</span>
          <span className="text-xl font-bold text-slate-800/80">Ministry Of Innovation</span>
          <span className="text-xl font-bold text-slate-800/80">Santim Pay</span>
          <span className="text-xl font-semibold text-slate-800/80" aria-hidden="true">Insa</span>
          <span className="text-xl font-bold italic text-slate-800/80" aria-hidden="true">Chapa</span>
          <span className="text-xl font-bold text-slate-800/80" aria-hidden="true">Ministry Of Innovation</span>
          <span className="text-xl font-bold text-slate-800/80" aria-hidden="true">Santim Pay</span>
        </div>
      </div>
    </section>
  )
}

export function About() {
  return (
    <section id="about" className="relative overflow-hidden py-24 md:py-32">
      <div className="hidden lg:block absolute top-16 left-[4%] w-11 h-11 rounded-full border-4 border-brand/20 pointer-events-none"></div>
      <div className="hidden lg:block absolute top-40 right-[6%] w-16 h-16 rounded-full border-[6px] border-brand/15 pointer-events-none"></div>
      <div className="hidden lg:block absolute bottom-24 right-[3%] w-3 h-3 rounded-full bg-brand/40 pointer-events-none"></div>

      <div className="max-w-7xl mx-auto grid lg:grid-cols-2 gap-16 items-center px-6 lg:px-10">
        <div data-reveal="zoom" className="order-2 lg:order-1 relative h-[380px] sm:h-[440px] flex items-center justify-center">
          <div className="bg-white rounded-3xl shadow-soft px-10 py-9 text-center z-10">
            <p className="font-display font-extrabold text-4xl text-slate-900"><span className="counter" data-count-to="500">0</span>+</p>
            <p className="text-xs font-bold tracking-wider text-brand mt-2 uppercase leading-relaxed">Verified Workers<br/>in Addis Ababa</p>
          </div>

          <div className="animate-float [animation-delay:0.2s] absolute top-2 left-4 sm:left-10">
            <div className="relative w-16 h-16 rounded-full ring-[5px] ring-white shadow-lg overflow-hidden">
              <img src="/assets/habesha_worker_1.jpg" className="w-full h-full object-cover" alt="Tigist, Verified Electrician" />
            </div>
            <span className="absolute -bottom-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center shadow">
              <svg viewBox="0 0 24 24" className="w-4 h-4" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </span>
          </div>

          <div className="animate-float [animation-delay:1.1s] absolute top-6 right-6 sm:right-14">
            <div className="relative w-14 h-14 rounded-full ring-[5px] ring-white shadow-lg overflow-hidden">
              <img src="/assets/habesha_worker_2.jpg" className="w-full h-full object-cover" alt="Dawit, Verified Plumber" />
            </div>
            <span className="absolute -bottom-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center shadow">
              <svg viewBox="0 0 24 24" className="w-4 h-4" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </span>
          </div>

          <div className="animate-float [animation-delay:1.9s] absolute bottom-4 left-0 sm:left-6">
            <div className="relative w-16 h-16 rounded-full ring-[5px] ring-white shadow-lg overflow-hidden">
              <img src="/assets/habesha_worker_3.jpg" className="w-full h-full object-cover" alt="Yonas, Verified Carpenter" />
            </div>
            <span className="absolute -bottom-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center shadow">
              <svg viewBox="0 0 24 24" className="w-4 h-4" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </span>
          </div>

          <div className="animate-float [animation-delay:0.6s] absolute bottom-2 right-2 sm:right-16">
            <div className="relative w-14 h-14 rounded-full ring-[5px] ring-white shadow-lg overflow-hidden">
              <img src="/assets/habesha_worker_4.jpg" className="w-full h-full object-cover" alt="Selam, Verified Cleaner" />
            </div>
            <span className="absolute -bottom-1 -right-1 w-5 h-5 bg-white rounded-full flex items-center justify-center shadow">
              <svg viewBox="0 0 24 24" className="w-4 h-4" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </span>
          </div>

          <div className="hidden sm:block absolute top-1/2 -left-2 w-9 h-9 rounded-full border-4 border-brand/20 pointer-events-none"></div>
          <div className="hidden sm:block absolute top-6 left-1/2 w-2.5 h-2.5 rounded-full bg-brand/40 pointer-events-none"></div>
        </div>

        <div className="order-1 lg:order-2">
          <h2 data-reveal className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 leading-tight">Formalizing the Informal Sector</h2>
          <p data-reveal style={{ '--reveal-delay': '100ms' }} className="mt-6 text-slate-500 text-base leading-relaxed max-w-lg">
            For too long, finding a reliable home repair worker meant risking the unknown. We are on a mission to digitize Ethiopia's informal service sector. By providing a trusted platform with verified professionals and secure payments, we protect homeowners while giving skilled workers the steady income they deserve.
          </p>
          <a href="#categories" data-reveal style={{ '--reveal-delay': '200ms' }} className="magnetic mt-9 inline-flex items-center gap-2.5 bg-brand hover:bg-brand-dark text-white font-semibold px-7 py-4 rounded-full shadow-soft transition-colors hover:shadow-lg">Explore More</a>
        </div>
      </div>
    </section>
  )
}

export function Categories() {
  return (
    <section id="categories" className="py-24 md:py-32 scroll-mt-24">
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <div className="grid lg:grid-cols-5 gap-10 items-start">
          <div data-reveal className="lg:col-span-2">
            <h2 className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 leading-tight">Let's help you choose the category you want</h2>
            <p className="mt-5 text-slate-500 leading-relaxed">
              Every home repair need covered — all in one place, across Addis Ababa.
            </p>
          </div>

          <div className="lg:col-span-3 grid grid-cols-1 sm:grid-cols-2 gap-5">
            <button type="button" data-cat data-reveal style={{ '--reveal-delay': '0ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
              <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M14.7 6.3a4 4 0 10-5.4 5.4L4 17v3h3l5.3-5.3a4 4 0 005.4-5.4l-2.5 2.5-2-2 2.2-2.2z"/><path d="M18 2l4 4"/><path d="M19 3l3 1-1 3"/></svg>
              </span>
              <p className="font-display font-bold text-lg text-slate-900">Plumbing</p>
            </button>

            <button type="button" data-cat data-reveal style={{ '--reveal-delay': '80ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
              <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
              </span>
              <p className="font-display font-bold text-lg text-slate-900">Electrical</p>
            </button>
          </div>
        </div>

        <div className="mt-6 grid grid-cols-2 md:grid-cols-4 gap-5">
          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '0ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M15 12l-8.5 8.5a2.12 2.12 0 01-3-3L12 9"/><path d="M17.64 15L22 10.64"/><path d="M20.91 11.7l-1.25-1.25a3.12 3.12 0 00-4.41 0L14 14"/><path d="M11.5 5.5l2 2"/></svg>
              </span>
            <p className="font-display font-bold text-lg text-slate-900">Carpentry</p>
          </button>

          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '60ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M19 3H5a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2z"/><path d="M12 9v4"/><path d="M8 21h8"/><path d="M10 13v8"/><path d="M14 13v8"/></svg>
              </span>
            <p className="font-display font-bold text-lg text-slate-900">Painting</p>
          </button>

          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '120ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M12 2v20"/><path d="M2 12h20"/><path d="M4.93 4.93l14.14 14.14"/><path d="M19.07 4.93L4.93 19.07"/></svg>
              </span>
            <p className="font-display font-bold text-lg text-slate-900">HVAC</p>
          </button>

          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '180ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M3 21h18"/><path d="M5 21V7l7-4 7 4v14"/><path d="M9 21v-6h6v6"/></svg>
            </span>
            <p className="font-display font-bold text-lg text-slate-900">Roofing</p>
          </button>
        </div>

        <div className="mt-5 grid grid-cols-2 md:grid-cols-4 gap-5">
          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '0ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            </span>
            <p className="font-display font-bold text-lg text-slate-900">Flooring</p>
          </button>

          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '60ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 7V5a4 4 0 00-8 0v2"/><path d="M12 14v3"/></svg>
              </span>
            <p className="font-display font-bold text-lg text-slate-900">General Repairs</p>
          </button>

          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '120ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M6 21c3-3 6-9 6-14 0 5 3 11 6 14"/><path d="M12 7c0 3-2 6-6 9"/><path d="M12 7c0 3 2 6 6 9"/></svg>
              </span>
            <p className="font-display font-bold text-lg text-slate-900">Landscaping</p>
          </button>

          <button type="button" data-cat data-reveal style={{ '--reveal-delay': '180ms' }} className="text-left bg-white rounded-2xl p-6 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all border-2 border-transparent">
            <span className="cat-icon w-12 h-12 rounded-xl bg-brand/10 text-brand flex items-center justify-center mb-6 transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6"><path d="M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3z"/><path d="M19 14l1 3 3 1-3 1-1 3-1-3-3-1 3-1 1-3z"/><path d="M5 17l.5 1.5L7 19l-1.5.5L5 21l-.5-1.5L3 19l1.5-.5L5 17z"/></svg>
              </span>
            <p className="font-display font-bold text-lg text-slate-900">Cleaning</p>
          </button>
        </div>
      </div>
    </section>
  )
}

export function HowItWorks() {
  return (
    <section id="how-it-works" className="relative overflow-hidden py-24 md:py-32">
      <div className="hidden lg:block absolute top-20 left-[5%] w-3 h-3 rounded-full bg-brand/40 pointer-events-none"></div>
      <div className="hidden lg:block absolute bottom-24 right-[4%] w-12 h-12 rounded-full border-4 border-brand/20 pointer-events-none"></div>

      <div className="max-w-7xl mx-auto grid lg:grid-cols-2 gap-16 lg:gap-20 items-center px-6 lg:px-10">
        <div>
          <h2 data-reveal className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 leading-tight">How Seralgn works</h2>
          <p data-reveal style={{ '--reveal-delay': '100ms' }} className="mt-6 text-slate-500 leading-relaxed max-w-md">
            From broken pipe to fixed pipe in three simple steps — with secure payments protecting both sides.
          </p>

          <div className="mt-10 space-y-7">
            <div data-reveal style={{ '--reveal-delay': '180ms' }}>
              <h4 className="font-bold text-slate-900"><span className="text-brand">01.</span> Post your job</h4>
              <p className="text-sm text-slate-500 mt-1.5 max-w-sm leading-relaxed">Describe the problem, add photos and Pay securely through Chapa. Takes under 5 minutes.</p>
            </div>
            <div data-reveal style={{ '--reveal-delay': '260ms' }}>
              <h4 className="font-bold text-slate-900"><span className="text-brand">02.</span> Receive bids</h4>
              <p className="text-sm text-slate-500 mt-1.5 max-w-sm leading-relaxed">Triple-verified local workers send offers. Review ratings, profiles, and prices.</p>
            </div>
            <div data-reveal style={{ '--reveal-delay': '340ms' }}>
              <h4 className="font-bold text-slate-900"><span className="text-brand">03.</span> Your job is done</h4>
              <p className="text-sm text-slate-500 mt-1.5 max-w-sm leading-relaxed">Leave a review. No middlemen, no waiting days.</p>
            </div>
          </div>
        </div>

        <div data-reveal="zoom" className="relative flex justify-center mt-14 lg:mt-0">
          <div className="hidden sm:block absolute -top-8 left-1/2 -translate-x-1/2 w-72 h-72 rounded-full border-[10px] border-mint/60 pointer-events-none animate-spin-slow"></div>
          <div className="relative w-64 sm:w-80 aspect-[4/5] rounded-[2.5rem] overflow-hidden shadow-2xl">
            <img src="/assets/habesha_worker_2.jpg" className="w-full h-full object-cover" alt="Seralgn member working" />
          </div>

          <div className="animate-float absolute -top-4 right-2 sm:right-0 bg-white rounded-2xl shadow-xl p-4 w-52">
            <div className="flex items-center gap-3">
              <div className="relative w-11 h-11 rounded-full overflow-hidden shrink-0">
                <img src="/assets/habesha_worker_1.jpg" className="w-full h-full object-cover" alt="Tigist, Seralgn Plumber" />
                <span className="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-white rounded-full flex items-center justify-center">
                  <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </span>
              </div>
              <div>
                <p className="font-bold text-sm text-slate-900">Tigist A.</p>
                <p className="text-xs text-slate-400">Master Electrician</p>
              </div>
            </div>
            <div className="flex items-center gap-0.5 mt-3">
              <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#F59E0B"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
              <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#F59E0B"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
              <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#F59E0B"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
              <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#F59E0B"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
              <div className="relative w-3.5 h-3.5">
                <svg viewBox="0 0 24 24" className="w-3.5 h-3.5 absolute inset-0" fill="#E5E7EB"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
                <div className="absolute inset-0 overflow-hidden" style={{ width: '50%' }}>
                  <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#F59E0B"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
                </div>
              </div>
              <span className="text-xs text-slate-400 ml-1">4.5</span>
            </div>
            <span className="inline-block mt-3 bg-mint-light text-brand text-xs font-bold px-2.5 py-1 rounded-full">ETB 400</span>
          </div>

          <div className="animate-float [animation-delay:1.5s] absolute -bottom-6 left-2 sm:-left-10 bg-white rounded-2xl shadow-xl p-4 flex items-center gap-3 w-60">
            <span className="w-10 h-10 rounded-xl bg-mint-light text-brand flex items-center justify-center shrink-0">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5"><rect x="3.5" y="5" width="17" height="15" rx="2"/><path d="M8 3v4M16 3v4M3.5 9.5h17"/></svg>
            </span>
            <div>
              <p className="font-bold text-sm text-slate-900">Job Completed</p>
              <p className="text-xs text-slate-400">Today · Bole, Addis Ababa</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

export function Verification() {
  return (
    <section className="relative overflow-hidden py-24 md:py-32 bg-slate-50">
      <div className="hidden lg:block absolute top-16 left-[4%] w-11 h-11 rounded-full border-4 border-brand/20 pointer-events-none"></div>
      <div className="hidden lg:block absolute top-40 right-[6%] w-16 h-16 rounded-full border-[6px] border-brand/15 pointer-events-none"></div>
      <div className="hidden lg:block absolute bottom-24 right-[3%] w-3 h-3 rounded-full bg-brand/40 pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <div data-reveal className="text-center max-w-2xl mx-auto mb-16">
          <h2 className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 leading-tight">Every worker is triple-verified</h2>
          <p data-reveal style={{ '--reveal-delay': '100ms' }} className="mt-5 text-slate-500 text-base leading-relaxed">
            Workers enter your home. We take that responsibility seriously. No one joins without passing our rigorous 3-step verification process.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-10">
          <div data-reveal style={{ '--reveal-delay': '150ms' }} className="bg-white rounded-3xl p-8 shadow-sm border border-slate-100">
            <h3 className="font-display font-bold text-xl text-slate-900 mb-6 flex items-center gap-3">
              <span className="w-10 h-10 rounded-xl bg-brand/10 text-brand flex items-center justify-center shrink-0">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5"><path d="M9 12l2 2 4-4"/><path d="M12 2a10 10 0 100 20 10 10 0 000-20z"/></svg>
              </span>
              2-Step Verification
            </h3>
            <div className="space-y-0">
              <div className="flex items-start gap-4 py-4 border-b border-slate-100 last:border-0">
                <span className="w-9 h-9 rounded-lg bg-brand/10 text-brand flex items-center justify-center shrink-0 mt-0.5">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4.5 h-4.5"><rect x="5" y="2" width="14" height="20" rx="2"/><path d="M12 18h.01"/></svg>
                </span>
                <div>
                  <p className="font-bold text-slate-900 text-sm">Phone OTP</p>
                  <p className="text-sm text-slate-500 mt-0.5">Real Ethiopian number confirmed instantly</p>
                </div>
              </div>
              <div className="flex items-start gap-4 py-4 border-b border-slate-100 last:border-0">
                <span className="w-9 h-9 rounded-lg bg-brand/10 text-brand flex items-center justify-center shrink-0 mt-0.5">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4.5 h-4.5"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                </span>
                <div>
                  <p className="font-bold text-slate-900 text-sm">National ID</p>
                  <p className="text-sm text-slate-500 mt-0.5">Government-issued ID reviewed by admins</p>
                </div>
              </div>
            </div>
          </div>

          <div data-reveal style={{ '--reveal-delay': '250ms' }} className="bg-white rounded-3xl p-8 shadow-sm border border-slate-100">
            <h3 className="font-display font-bold text-xl text-slate-900 mb-6 flex items-center gap-3">
              <span className="w-10 h-10 rounded-xl bg-brand/10 text-brand flex items-center justify-center shrink-0">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
              </span>
              Platform Protections
            </h3>
            <div className="space-y-0">
              <div className="flex items-start gap-4 py-4 border-b border-slate-100 last:border-0">
                <span className="w-9 h-9 rounded-lg bg-brand/10 text-brand flex items-center justify-center shrink-0 mt-0.5">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4.5 h-4.5"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg>
                </span>
                <div>
                  <p className="font-bold text-slate-900 text-sm">Flag system bans bad actors after 3 violations</p>
                  <p className="text-sm text-slate-500 mt-0.5">1-year ban for 3 flags, permanent if repeated</p>
                </div>
              </div>
              <div className="flex items-start gap-4 py-4 border-b border-slate-100 last:border-0">
                <span className="w-9 h-9 rounded-lg bg-brand/10 text-brand flex items-center justify-center shrink-0 mt-0.5">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4.5 h-4.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>
                </span>
                <div>
                  <p className="font-bold text-slate-900 text-sm">Chapa payments create verifiable proof records</p>
                  <p className="text-sm text-slate-500 mt-0.5">Non-payers get flagged — 3 flags = banned</p>
                </div>
              </div>
              
              <div className="flex items-start gap-4 py-4 border-b border-slate-100 last:border-0">
                <span className="w-9 h-9 rounded-lg bg-brand/10 text-brand flex items-center justify-center shrink-0 mt-0.5">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" className="w-4.5 h-4.5"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z"/></svg>
                </span>
                <div>
                  <p className="font-bold text-slate-900 text-sm">Ratings & reviews after every completed job</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

export function Testimonials() {
  const trackRef = useRef(null)
  const [active, setActive] = useState(0)

  useEffect(() => {
    const track = trackRef.current
    if (!track) return

    const cardStep = () => track.children[1] ? track.children[1].offsetLeft - track.children[0].offsetLeft : track.clientWidth

    const updateDots = () => {
      const step = cardStep()
      const idx = Math.round(track.scrollLeft / step)
      setActive(Math.min(idx, track.children.length - 1))
    }
    track.addEventListener('scroll', () => window.requestAnimationFrame(updateDots), { passive: true })

    let autoplayTimer = null
    const startAutoplay = () => {
      if (window.matchMedia('(prefers-reduced-motion: reduce)').matches || autoplayTimer) return
      autoplayTimer = setInterval(() => {
        const atEnd = track.scrollLeft + track.clientWidth >= track.scrollWidth - 8
        track.scrollTo({ left: atEnd ? 0 : track.scrollLeft + cardStep(), behavior: 'smooth' })
      }, 4200)
    }
    const stopAutoplay = () => { clearInterval(autoplayTimer); autoplayTimer = null }

    track.addEventListener('mouseenter', stopAutoplay)
    track.addEventListener('mouseleave', startAutoplay)
    track.addEventListener('touchstart', stopAutoplay, { passive: true })
    startAutoplay()

    // Drag to scroll
    if (window.matchMedia('(pointer: fine)').matches) {
      let isDown = false, startX = 0, startScroll = 0
      track.addEventListener('pointerdown', (e) => {
        isDown = true
        track.classList.add('is-dragging')
        startX = e.clientX
        startScroll = track.scrollLeft
        stopAutoplay()
      })
      window.addEventListener('pointerup', () => {
        if (!isDown) return
        isDown = false
        track.classList.remove('is-dragging')
        startAutoplay()
      })
      window.addEventListener('pointermove', (e) => {
        if (!isDown) return
        track.scrollLeft = startScroll - (e.clientX - startX)
      })
    }

    return () => stopAutoplay()
  }, [])

  const scrollTo = (index) => {
    const track = trackRef.current
    if (!track) return
    track.scrollTo({ left: track.children[index].offsetLeft - track.children[0].offsetLeft, behavior: 'smooth' })
  }

  return (
    <section className="py-24 md:py-32 overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <div data-reveal className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-6 mb-12">
          <div>
            <h2 className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900">What Our Clients Say About Us</h2>
            <p className="mt-4 text-slate-500 max-w-md">Real feedback from real people who found their next opportunity with Seralgn.</p>
          </div>
          <div className="flex items-center gap-3 shrink-0">
            <button type="button" onClick={() => scrollTo(Math.max(0, active - 1))} aria-label="Previous testimonial" className="magnetic w-11 h-11 rounded-full bg-slate-100 text-slate-500 hover:bg-slate-200 flex items-center justify-center transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5"><path d="M15 6l-6 6 6 6"/></svg>
            </button>
            <button type="button" onClick={() => scrollTo(Math.min(3, active + 1))} aria-label="Next testimonial" className="magnetic w-11 h-11 rounded-full bg-brand text-white hover:bg-brand-dark flex items-center justify-center transition-colors">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5"><path d="M9 6l6 6-6 6"/></svg>
            </button>
          </div>
        </div>
      </div>

      <div id="testimonial-track" ref={trackRef} className="flex gap-6 overflow-x-auto scrollbar-hide snap-x snap-mandatory px-6 lg:px-10 pb-4 max-w-7xl mx-auto">
        <article className="snap-start shrink-0 w-[280px] sm:w-[320px] bg-white border border-slate-100 rounded-2xl p-7 shadow-sm hover:-translate-y-1 transition-transform">
          <div className="flex items-center gap-3">
            <div className="relative w-12 h-12 rounded-full overflow-hidden shrink-0">
              <img src="/assets/habesha_customer_1.jpg" className="w-full h-full object-cover" alt="Aster Yilma" />
              <span className="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-white rounded-full flex items-center justify-center">
                <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </span>
            </div>
            <div>
              <p className="font-bold text-slate-900">Aster Yilma</p>
              <p className="text-xs text-slate-400">Homeowner in Bole</p>
            </div>
          </div>
          <p className="text-sm text-slate-500 leading-relaxed mt-5">Seralgn helped me find an electrician in under an hour when my power went out. The whole process felt completely effortless and safe.</p>
        </article>

        <article className="snap-start shrink-0 w-[280px] sm:w-[320px] bg-brand text-white rounded-2xl p-7 shadow-xl hover:-translate-y-1 transition-transform">
          <div className="flex items-center gap-3">
            <div className="relative w-12 h-12 rounded-full overflow-hidden shrink-0 ring-2 ring-white/30">
              <img src="/assets/habesha_worker_2.jpg" className="w-full h-full object-cover" alt="Daniel Bekele" />
            </div>
            <div>
              <p className="font-bold">Daniel Bekele</p>
              <p className="text-xs text-white/60">Professional Painter</p>
            </div>
          </div>
          <p className="text-sm text-white/80 leading-relaxed mt-5">The platform matched me with three new clients in my first week. Getting paid securely through Chapa gives me total peace of mind.</p>
        </article>

        <article className="snap-start shrink-0 w-[280px] sm:w-[320px] bg-white border border-slate-100 rounded-2xl p-7 shadow-sm hover:-translate-y-1 transition-transform">
          <div className="flex items-center gap-3">
            <div className="relative w-12 h-12 rounded-full overflow-hidden shrink-0">
              <img src="/assets/habesha_customer_2.jpg" className="w-full h-full object-cover" alt="Yosef Alemu" />
              <span className="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-white rounded-full flex items-center justify-center">
                <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </span>
            </div>
            <div>
              <p className="font-bold text-slate-900">Yosef Alemu</p>
              <p className="text-xs text-slate-400">Restaurant Manager</p>
            </div>
          </div>
          <p className="text-sm text-slate-500 leading-relaxed mt-5">Knowing that every worker is triple-verified by their National ID makes all the difference when inviting someone into our business.</p>
        </article>

        <article className="snap-start shrink-0 w-[280px] sm:w-[320px] bg-white border border-slate-100 rounded-2xl p-7 shadow-sm hover:-translate-y-1 transition-transform">
          <div className="flex items-center gap-3">
            <div className="relative w-12 h-12 rounded-full overflow-hidden shrink-0">
              <img src="/assets/habesha_customer_1.jpg" className="w-full h-full object-cover" alt="Bethlehem Tadesse" />
              <span className="absolute -bottom-0.5 -right-0.5 w-4 h-4 bg-white rounded-full flex items-center justify-center">
                <svg viewBox="0 0 24 24" className="w-3.5 h-3.5" fill="#3B82F6"><path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z"/><path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </span>
            </div>
            <div>
              <p className="font-bold text-slate-900">Bethlehem Tadesse</p>
              <p className="text-xs text-slate-400">Apartment Resident</p>
            </div>
          </div>
          <p className="text-sm text-slate-500 leading-relaxed mt-5">Our kitchen sink burst at 2 PM, and a verified plumber arrived in 20 minutes. I recommend Seralgn to everyone.</p>
        </article>
      </div>

      <div id="testimonial-dots" className="flex items-center justify-center gap-2 mt-8">
        {[0, 1, 2, 3].map(i => (
          <button key={i} type="button" aria-label={`Go to testimonial ${i + 1}`} onClick={() => scrollTo(i)} className={`t-dot ${active === i ? 'is-active' : ''}`}></button>
        ))}
      </div>
    </section>
  )
}
