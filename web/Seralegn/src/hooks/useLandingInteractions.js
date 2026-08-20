import { useEffect, useRef } from 'react'

export function useReveal() {
  const ref = useRef(null)

  useEffect(() => {
    const elements = ref.current?.querySelectorAll('[data-reveal]')
    if (!elements?.length) return undefined

    const animateCounters = (element) => {
      const counters = element.querySelectorAll('.counter')
      counters.forEach(counter => {
        const target = parseInt(counter.getAttribute('data-count-to') || '0', 10)
        let startTimestamp = null
        const duration = 2000
        const step = (timestamp) => {
          if (!startTimestamp) startTimestamp = timestamp
          const progress = Math.min((timestamp - startTimestamp) / duration, 1)
          const easeOut = 1 - Math.pow(1 - progress, 3)
          counter.textContent = Math.floor(easeOut * target)
          if (progress < 1) window.requestAnimationFrame(step)
        }
        window.requestAnimationFrame(step)
      })
    }

    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (reduced || !('IntersectionObserver' in window)) {
      elements.forEach((element) => {
        element.classList.add('reveal-visible')
        animateCounters(element)
      })
      return undefined
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal-visible')
          animateCounters(entry.target)
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.15, rootMargin: '0px 0px -8% 0px' })

    elements.forEach((element) => observer.observe(element))
    return () => observer.disconnect()
  }, [])

  return ref
}
