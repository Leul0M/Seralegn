import { useEffect, useRef, useState } from 'react'
import { ArrowIcon, CalendarIcon, CheckBadge, HalfStar, StarIcon } from './icons'
import { useReveal } from '../hooks/useLandingInteractions'
import worker1 from '../assets/images/habesha_worker_1.jpg'
import worker2 from '../assets/images/habesha_worker_2.jpg'
import worker3 from '../assets/images/habesha_worker_3.jpg'
import worker4 from '../assets/images/habesha_worker_4.jpg'
import customer1 from '../assets/images/habesha_customer_1.jpg'
import customer2 from '../assets/images/habesha_customer_2.jpg'

const categories = [
  { name: 'Plumbing', icon: { paths: ['M14.7 6.3a4 4 0 10-5.4 5.4L4 17v3h3l5.3-5.3a4 4 0 005.4-5.4l-2.5 2.5-2-2 2.2-2.2z', 'M18 2l4 4', 'M19 3l3 1-1 3'] } },
  { name: 'Electrical', icon: { paths: ['M13 2L3 14h9l-1 8 10-12h-9l1-8z'] } },
  { name: 'Carpentry', icon: { paths: ['M15 12l-8.5 8.5a2.12 2.12 0 01-3-3L12 9', 'M17.64 15L22 10.64', 'M20.91 11.7l-1.25-1.25a3.12 3.12 0 00-4.41 0L14 14', 'M11.5 5.5l2 2'] } },
  { name: 'Painting', icon: { paths: ['M19 3H5a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2z', 'M12 9v4', 'M8 21h8', 'M10 13v8', 'M14 13v8'] } },
  { name: 'HVAC', icon: { paths: ['M12 2v20', 'M2 12h20', 'M4.93 4.93l14.14 14.14', 'M19.07 4.93L4.93 19.07'] } },
  { name: 'Roofing', icon: { paths: ['M3 21h18', 'M5 21V7l7-4 7 4v14', 'M9 21v-6h6v6'] } },
  { name: 'Flooring', icon: { rects: [[3, 3, 7, 7], [14, 3, 7, 7], [14, 14, 7, 7], [3, 14, 7, 7]] } },
  { name: 'General Repairs', icon: { rects: [[2, 7, 20, 14, 2]], paths: ['M16 7V5a4 4 0 00-8 0v2', 'M12 14v3'] } },
  { name: 'Landscaping', icon: { paths: ['M6 21c3-3 6-9 6-14 0 5 3 11 6 14', 'M12 7c0 3-2 6-6 9', 'M12 7c0 3 2 6 6 9'] } },
  { name: 'Cleaning', icon: { paths: ['M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5L12 3z', 'M19 14l1 3 3 1-3 1-1 3-1-3-3-1 3-1 1-3z', 'M5 17l.5 1.5L7 19l-1.5.5L5 21l-.5-1.5L3 19l1.5-.5L5 17z'] } },
]

const testimonials = [
  ['Aster Yilma', 'Homeowner in Bole', customer1, 'Seralgn helped me find an electrician in under an hour when my power went out. The whole process felt completely effortless and safe.'],
  ['Daniel Bekele', 'Professional Painter', worker2, 'The platform matched me with three new clients in my first week. Getting paid securely through Chapa gives me total peace of mind.'],
  ['Yosef Alemu', 'Restaurant Manager', customer2, 'Knowing that every worker is triple-verified by their National ID makes all the difference when inviting someone into our business.'],
  ['Bethlehem Tadesse', 'Apartment Resident', customer1, 'Our kitchen sink burst at 2 PM, and a verified plumber arrived in 20 minutes. I recommend Seralgn to everyone.'],
]

function CategoryCard({ category, index }) {
  const { paths = [], rects = [] } = category.icon
  return <button type="button" data-cat="true" data-reveal="true" className="category-card" style={{ '--reveal-delay': `${(index % 4) * 60}ms` }}><span className="category-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">{rects.map(([x, y, width, height, rx], rectIndex) => <rect key={`rect-${rectIndex}`} x={x} y={y} width={width} height={height} rx={rx} />)}{paths.map((path, pathIndex) => <path key={`path-${pathIndex}`} d={path} />)}</svg></span><strong>{category.name}</strong></button>
}

function TrustedBy() {
  const companies = ['Insa', 'Chapa', 'Ministry Of Innovation', 'Santim Pay']
  return <section className="trusted"><h3>Trusted by 10+ Ethiopian Leading Companies</h3><div className="marquee"><div>{[...companies, ...companies].map((company, index) => <span key={`${company}-${index}`}>{company}</span>)}</div></div></section>
}

export function About() {
  const ref = useReveal()
  const workers = [worker1, worker2, worker3, worker4]
  return <section id="about" className="section about-section" ref={ref}><div className="about-art" data-reveal="zoom"><div className="verified-count"><strong>500+</strong><span>Verified Workers<br />in Addis Ababa</span></div>{workers.map((image, index) => <div className={`worker-wrap worker-wrap-${index + 1}`} key={image}><img className="worker" src={image} alt="Verified local worker" /><CheckBadge /></div>)}</div><div className="section-copy"><h2 data-reveal="true">Formalizing the Informal Sector</h2><p data-reveal="true" style={{ '--reveal-delay': '100ms' }}>For too long, finding a reliable home repair worker meant risking the unknown. We are on a mission to digitize Ethiopia's informal service sector. By providing a trusted platform with verified professionals and secure payments, we protect homeowners while giving skilled workers the steady income they deserve.</p><a href="#categories" className="button" data-reveal="true" style={{ '--reveal-delay': '200ms' }}>Explore More</a></div></section>
}

export function Categories() {
  const ref = useReveal()
  return <section id="categories" className="section categories-section" ref={ref}><div className="categories-layout"><div className="categories-intro"><h2 data-reveal="true">Let's help you choose the category you want</h2><p data-reveal="true">Every home repair need covered — all in one place, across Addis Ababa.</p></div><div className="category-feature-grid">{categories.slice(0, 2).map((category, index) => <CategoryCard category={category} index={index} key={category.name} />)}</div></div><div className="category-grid category-grid-four">{categories.slice(2, 6).map((category, index) => <CategoryCard category={category} index={index + 2} key={category.name} />)}</div><div className="category-grid category-grid-four category-grid-last">{categories.slice(6).map((category, index) => <CategoryCard category={category} index={index + 6} key={category.name} />)}</div></section>
}

export function HowItWorks() {
  const ref = useReveal()
  const steps = [['01', 'Post your job', 'Describe the problem, add photos, and pay securely through Chapa. Takes under 5 minutes.'], ['02', 'Receive bids', 'Triple-verified local workers send offers. Review ratings, profiles, and prices.'], ['03', 'Your job is done', 'Choose your worker, get the work completed, and leave a review.']]
  return <section id="how-it-works" className="section how-section" ref={ref}><span className="how-decoration how-decoration-dot" /><span className="how-decoration how-decoration-ring" /><div className="how-layout"><div className="how-copy"><span className="section-kicker" data-reveal="true">Simple by design</span><h2 data-reveal="true">From problem to done.</h2><p data-reveal="true" style={{ '--reveal-delay': '100ms' }}>A trusted way to get home repairs moving, with secure payments protecting both sides.</p><div className="steps">{steps.map(([number, title, text], index) => <div className="step" data-reveal="true" style={{ '--reveal-delay': `${index === 2 ? 260 : 180 + index * 80}ms` }} key={number}><div className="step-number">{number}</div><div className="step-content"><h4>{title}</h4><p>{text}</p></div></div>)}</div></div><div className="how-image" data-reveal="zoom"><div className="how-image-heading"><span>Trusted local help</span><strong>Ready when you are</strong></div><div className="how-image-ring" /><div className="how-photo"><img src={worker2} alt="Seralgn member working" /></div><div className="worker-card"><div className="worker-card-label">Top rated worker</div><div className="worker-card-person"><div className="worker-avatar"><img src={worker1} alt="Tigist, Seralgn Plumber" /><CheckBadge /></div><div><strong>Tigist A.</strong><span>Master Electrician</span></div></div><div className="stars"><StarIcon /><StarIcon /><StarIcon /><StarIcon /><HalfStar /><span>4.5</span></div><b>ETB 400</b></div><div className="job-completed"><span><CalendarIcon /></span><div><strong>Job Completed</strong><small>Today · Bole, Addis Ababa</small></div></div></div></div></section>
}

export function Verification() {
  const ref = useReveal()
  return <section className="verification" ref={ref}><div className="section-heading"><h2 data-reveal="true">Every worker is triple-verified</h2><p data-reveal="true" style={{ '--reveal-delay': '100ms' }}>Workers enter your home. We take that responsibility seriously. No one joins without passing our rigorous 3-step verification process.</p></div><div className="verification-grid"><div className="protection-panel" data-reveal="true" style={{ '--reveal-delay': '150ms' }}><h3><CheckBadge /> 2-Step Verification</h3><ProtectionRow title="Phone OTP" text="Real Ethiopian number confirmed instantly" /><ProtectionRow title="National ID" text="Government-issued ID reviewed by admins" /></div><div className="protection-panel" data-reveal="true" style={{ '--reveal-delay': '250ms' }}><h3><CheckBadge /> Platform Protections</h3><ProtectionRow title="Flag system bans bad actors after 3 violations" text="1-year ban for 3 flags, permanent if repeated" /><ProtectionRow title="Chapa payments create verifiable proof records" text="Non-payers get flagged — 3 flags = banned" /><ProtectionRow title="Ratings & reviews after every completed job" /></div></div></section>
}

function ProtectionRow({ title, text }) { return <div className="protection-row"><span>✓</span><div><strong>{title}</strong>{text && <p>{text}</p>}</div></div> }

export function Testimonials() {
  const trackRef = useRef(null)
  const [active, setActive] = useState(0)
  const scrollTo = (index) => { const track = trackRef.current; if (!track) return; const card = track.children[index]; track.scrollTo({ left: card.offsetLeft - track.children[0].offsetLeft, behavior: 'smooth' }); setActive(index) }
  useEffect(() => { const track = trackRef.current; if (!track) return undefined; const onScroll = () => { const step = track.children[1]?.offsetLeft - track.children[0]?.offsetLeft || track.clientWidth; setActive(Math.min(Math.round(track.scrollLeft / step), testimonials.length - 1)) }; track.addEventListener('scroll', onScroll, { passive: true }); return () => track.removeEventListener('scroll', onScroll) }, [])
  return <section className="section testimonials"><div className="testimonials-heading"><div><h2>What Our Clients Say About Us</h2><p>Real feedback from real people who found their next opportunity with Seralgn.</p></div><div className="carousel-buttons"><button type="button" aria-label="Previous testimonial" onClick={() => scrollTo(Math.max(0, active - 1))}><ArrowIcon direction="left" /></button><button type="button" aria-label="Next testimonial" onClick={() => scrollTo(Math.min(testimonials.length - 1, active + 1))}><ArrowIcon /></button></div></div><div className="testimonial-track" ref={trackRef}>{testimonials.map(([name, role, image, text], index) => <article className={`testimonial-card ${index === 1 ? 'featured' : ''}`} key={name}><div className="person"><img src={image} alt={name} /><div><strong>{name}</strong><span>{role}</span></div></div><p>{text}</p></article>)}</div><div className="testimonial-dots">{testimonials.map((item, index) => <button type="button" aria-label={`Go to testimonial ${index + 1}`} className={active === index ? 'active' : ''} key={item[0]} onClick={() => scrollTo(index)} />)}</div></section>
}

export default TrustedBy
