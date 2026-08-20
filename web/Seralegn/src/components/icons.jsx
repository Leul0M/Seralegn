export function ArrowIcon({ direction = 'right' }) {
  const path = direction === 'left' ? 'M15 6l-6 6 6 6' : direction === 'up' ? 'M12 19V5M5 12l7-7 7 7' : 'M5 12h14M13 6l6 6-6 6'

  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d={path} />
    </svg>
  )
}

export function CheckBadge() {
  return (
    <svg viewBox="0 0 24 24" fill="#3B82F6" aria-hidden="true">
      <path d="M12 2l2.4 2.1 3.1-.5.9 3 2.6 1.7-1 3 1 3-2.6 1.7-.9 3-3.1-.5L12 22l-2.4-2.1-3.1.5-.9-3-2.6-1.7 1-3-1-3 2.6-1.7.9-3 3.1.5z" />
      <path d="M8.5 12.3l2.3 2.3 4.5-4.8" stroke="white" strokeWidth="1.6" fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  )
}

export function MenuIcon({ open }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" aria-hidden="true">
      {open ? <path d="M6 6l12 12M18 6L6 18" /> : <path d="M4 6h16M4 12h16M4 18h16" />}
    </svg>
  )
}

export function StarIcon({ muted = false }) {
  return <svg viewBox="0 0 24 24" fill={muted ? '#E5E7EB' : '#F59E0B'} aria-hidden="true"><path d="M12 2l3.1 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.8 21l1.2-6.8-5-4.9 6.9-1z" /></svg>
}

export function HalfStar() {
  return <span className="half-star"><StarIcon muted /><span><StarIcon /></span></span>
}

export function CalendarIcon() {
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><rect x="3.5" y="5" width="17" height="15" rx="2" /><path d="M8 3v4M16 3v4M3.5 9.5h17" /></svg>
}
