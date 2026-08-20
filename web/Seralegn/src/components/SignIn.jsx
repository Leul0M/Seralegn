import { useState } from 'react'

export default function SignIn() {
  const [form, setForm] = useState({ email: '', password: '' })
  const [error, setError] = useState('')
  const [submitted, setSubmitted] = useState(false)

  const updateField = (event) => {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
    setError('')
  }

  const handleSubmit = (event) => {
    event.preventDefault()
    const account = JSON.parse(localStorage.getItem('seralgn-admin') || 'null')

    if (!account || account.email !== form.email) {
      setError('No admin account was found with that email address.')
      return
    }

    setSubmitted(true)
  }

  return <div className="auth-page">
    <header className="auth-header">
      <a href="/" className="auth-brand" aria-label="Seralgn home">
        <span className="auth-brand-logo"><img src="/logo.svg" alt="Seralgn logo" /></span>
        <span>Seralgn</span>
      </a>
    </header>

    <main className="auth-main auth-main-signin">
      <section className="auth-card" aria-labelledby="signin-title">
        <div className="auth-decoration auth-decoration-one" />
        <div className="auth-decoration auth-decoration-two" />
        <div className="auth-card-content">
          <h1 id="signin-title">Admin Portal</h1>
          <p className="auth-subtitle">Sign in to manage the platform</p>

          {submitted ? <div className="auth-success" role="status">
            <strong>Signed in successfully.</strong>
            <span>Welcome back to the Seralgn admin portal.</span>
            <a href="/" className="auth-submit">Return to Seralgn</a>
          </div> : <form className="auth-form auth-form-signin" onSubmit={handleSubmit}>
            <label className="auth-field">
              <span>Email Address</span>
              <input type="email" name="email" value={form.email} onChange={updateField} placeholder="admin@seralgn.com" required />
            </label>
            <label className="auth-field">
              <span>Password</span>
              <input type="password" name="password" value={form.password} onChange={updateField} placeholder="••••••••" required />
            </label>
            {error && <p className="auth-error" role="alert">{error}</p>}
            <button className="auth-submit" type="submit">Sign In</button>
          </form>}

          {!submitted && <p className="auth-switch">Don't have an account? <a href="/sign-up.html">Sign up</a></p>}
        </div>
      </section>
      <p className="auth-terms">By signing in, you agree to Seralgn's <a href="#terms">Terms of Service</a> and <a href="#privacy">Privacy Policy</a>.</p>
    </main>
  </div>
}
