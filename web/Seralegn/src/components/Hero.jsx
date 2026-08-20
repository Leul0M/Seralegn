import { useEffect, useState } from 'react'
import { ArrowIcon } from './icons'
import heroImage from '../assets/images/hero.jpeg'
import { useReveal } from '../hooks/useLandingInteractions'

function Stat({ value, label }) {
  const [count, setCount] = useState(0)
  useEffect(() => {
    const start = performance.now()
    const animate = (now) => {
      const progress = Math.min((now - start) / 1400, 1)
      setCount(Math.round((1 - 2 ** (-10 * progress)) * value))
      if (progress < 1) requestAnimationFrame(animate)
    }
    requestAnimationFrame(animate)
  }, [value])
  return <div><strong>{count}k+</strong><span>{label}</span></div>
}

export default function Hero() {
  const revealRef = useReveal()
  const [pointer, setPointer] = useState({ x: 0, y: 0 })
  useEffect(() => {
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (reduced || !window.matchMedia('(pointer: fine)').matches) return undefined
    const onMove = (event) => setPointer({ x: event.clientX / window.innerWidth - 0.5, y: event.clientY / window.innerHeight - 0.5 })
    window.addEventListener('mousemove', onMove, { passive: true })
    return () => window.removeEventListener('mousemove', onMove)
  }, [])
  return (
    <section id="hero" className="hero-section" ref={revealRef}>
      <div className="hero-orbit orbit-one" style={{ transform: `translate(${pointer.x * 12}px, ${pointer.y * 12}px)` }} />
      <div className="hero-orbit orbit-two" style={{ transform: `translate(${pointer.x * 18}px, ${pointer.y * 18}px)` }} />
      <div className="hero-orbit orbit-three" style={{ transform: `translate(${pointer.x * 8}px, ${pointer.y * 8}px)` }} />
      <div className="hero-orbit orbit-four" />
      <div className="hero-grid page-width">
        <div className="hero-copy">
          <h1 data-reveal>Find trusted home<br className="desktop-only" /> repair workers near you</h1>
          <p data-reveal style={{ '--reveal-delay': '120ms' }}>Post a job, receive bids from verified local professionals, and pay safely through Chapa. No middlemen. No waiting days.</p>
          <a href="#categories" className="button hero-button" data-reveal style={{ '--reveal-delay': '220ms' }}>Explore Now <ArrowIcon /></a>
          <div className="stats-panel" data-reveal style={{ '--reveal-delay': '320ms' }}>
            <Stat value={300} label="Active Users" /><Stat value={12} label="Jobs Completed" />
          </div>
        </div>
        <div className="hero-portrait" data-reveal="zoom" style={{ '--reveal-delay': '150ms', transform: `rotate(${pointer.x * 3}deg) translate(${pointer.x * 8}px, ${pointer.y * 8}px)` }}>
          <div className="portrait-ring" /><img src={heroImage} alt="Smiling Seralgn job seeker holding a laptop" />
          <div className="portrait-block" /><div className="portrait-dot" />
        </div>
      </div>
    </section>
  )
}
