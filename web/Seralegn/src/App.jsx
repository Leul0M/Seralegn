
import { useEffect, useState } from 'react'
import './App.css'
import Header from './components/Header'
import Hero from './components/Hero'
import TrustedBy, { About, Categories, HowItWorks, Testimonials, Verification } from './components/LandingSections'
import Footer from './components/Footer'
import { ArrowIcon } from './components/icons'

function App() {
  const [showTop, setShowTop] = useState(false)

  useEffect(() => {
    const onScroll = () => setShowTop(window.scrollY > 600)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return <>
    <Header />
    <main><Hero /><TrustedBy /><About /><Categories /><HowItWorks /><Verification /><Testimonials /></main>
    <Footer />
    <button className={`back-to-top ${showTop ? 'visible' : ''}`} type="button" aria-label="Back to top" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}><ArrowIcon direction="up" /></button>
  </>
}

export default App
