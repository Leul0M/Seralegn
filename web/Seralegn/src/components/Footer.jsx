const columns = [
  ['Home', ['Discover Jobs', 'Browse Companies', 'Career Advice']],
  ['Company', ['About Us', 'Our Partners', 'Careers']],
  ['Features', ['Job Alerts', 'Resume Builder', 'Salary Guide', 'Help Center']],
]

export default function Footer() {
  return <footer className="footer"><div className="footer-grid page-width"><div><a href="#hero" className="footer-brand">Seralgn</a><p>ሰራለኝ — Ethiopia's trusted platform connecting homeowners with verified local workers across Addis Ababa.</p></div>{columns.map(([title, links]) => <div key={title}><h3>{title}</h3>{links.map((link) => <a href="#hero" key={link}>{link}</a>)}</div>)}<div><h3>Contact Us</h3><a href="mailto:hello@seralgn.com">hello@Seralgn.com</a><a href="tel:+251112345678">+251 11 234 5678</a><span>Addis Ababa, Ethiopia</span></div></div><div className="footer-bottom page-width"><span>© 2026 Seralgn. All rights reserved.</span><span>Privacy Policy · Terms of Service</span></div></footer>
}
