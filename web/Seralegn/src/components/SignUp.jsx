import { useState } from 'react'

const initialForm = { name: '', email: '', password: '' }

export default function SignUp() {
  const [form, setForm] = useState(initialForm)
  const [error, setError] = useState('')
  const [submitted, setSubmitted] = useState(false)

  const updateField = (event) => {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
    setError('')
  }

  const handleSubmit = (event) => {
    event.preventDefault()
    if (form.password.length < 8) {
      setError('Password must be at least 8 characters.')
      return
    }

    localStorage.setItem('seralgn-admin', JSON.stringify({ name: form.name, email: form.email }))
    setSubmitted(true)
  }

  return <div className="auth-page">
    <header className="auth-header">
      <a href="/" className="auth-brand" aria-label="Seralgn home">
        <span className="auth-brand-logo"><img src="/logo.svg" alt="Seralgn logo" /></span>
        <span>Seralgn</span>
      </a>
    </header>

    <main className="auth-main">
      <section className="auth-card" aria-labelledby="signup-title">
        <div className="auth-decoration auth-decoration-one" />
        <div className="auth-decoration auth-decoration-two" />
        <div className="auth-card-content">
          <h1 id="signup-title">Admin Portal</h1>
          <p className="auth-subtitle">Register a new admin account</p>

          {submitted ? <div className="auth-success" role="status">
            <strong>Account created successfully.</strong>
            <span>Your admin account is ready to use.</span>
            <a href="/" className="auth-submit">Return to Seralgn</a>
          </div> : <form className="auth-form" onSubmit={handleSubmit}>
            <label className="auth-field">
              <span>Full Name</span>
              <input type="text" name="name" value={form.name} onChange={updateField} placeholder="E.g. Abebe Kebede" required />
            </label>
            <label className="auth-field">
              <span>Email Address</span>
              <input type="email" name="email" value={form.email} onChange={updateField} placeholder="admin@seralgn.com" required />
            </label>
            <label className="auth-field">
              <span>Password</span>
              <input type="password" name="password" value={form.password} onChange={updateField} placeholder="••••••••" minLength="8" required />
            </label>
            {error && <p className="auth-error" role="alert">{error}</p>}
            <button className="auth-submit" type="submit">Sign Up</button>
          </form>}

          {!submitted && <p className="auth-switch">Already have an account? <a href="/sign-in.html">Sign in</a></p>}
        </div>
      </section>
      <p className="auth-terms">By signing up, you agree to Seralgn's <a href="#terms">Terms of Service</a> and <a href="#privacy">Privacy Policy</a>.</p>
    </main>
  </div>
}
