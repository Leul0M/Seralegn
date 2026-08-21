import React, { useState, useEffect } from 'react';
import Header from '../components/Header';
import Hero from '../components/Hero';
import TrustedBy, { About, Categories, HowItWorks, Testimonials, Verification } from '../components/LandingSections';
import Footer from '../components/Footer';
import { useReveal } from '../hooks/useLandingInteractions';

export default function LandingPage() {
  const [showTop, setShowTop] = useState(false);
  const revealRef = useReveal();

  useEffect(() => {
    const onScroll = () => setShowTop(window.scrollY > 600);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <div ref={revealRef} className="bg-canvas text-slate-900 antialiased min-h-screen flex flex-col overflow-x-hidden">
      <Header />
      <main className="flex-1">
        <Hero />
        <TrustedBy />
        <About />
        <Categories />
        <HowItWorks />
        <Verification />
        <Testimonials />
      </main>
      <Footer />
      <button 
        className={`fixed bottom-6 right-6 z-40 w-12 h-12 bg-white text-slate-800 rounded-full shadow-[0_8px_30px_rgb(0,0,0,0.12)] flex items-center justify-center hover:-translate-y-1 hover:shadow-[0_12px_40px_rgb(0,0,0,0.16)] transition-all pointer-events-none opacity-0 translate-y-3 ${showTop ? 'opacity-100 translate-y-0 !pointer-events-auto' : ''}`}
        type="button" 
        aria-label="Back to top" 
        onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5"><path d="M18 15l-6-6-6 6"/></svg>
      </button>
    </div>
  );
}
