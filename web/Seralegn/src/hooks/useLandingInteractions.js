import { useEffect, useRef } from 'react'

export function useReveal() {
  const ref = useRef(null)

  useEffect(() => {
    const elements = ref.current?.querySelectorAll('[data-reveal]')
    if (!elements?.length) return undefined

    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (reduced || !('IntersectionObserver' in window)) {
      elements.forEach((element) => element.classList.add('reveal-visible'))
      return undefined
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal-visible')
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.15, rootMargin: '0px 0px -8% 0px' })

    elements.forEach((element) => observer.observe(element))
    return () => observer.disconnect()
  }, [])

  return ref
}
