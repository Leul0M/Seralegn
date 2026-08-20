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

  return (
    <div className="bg-canvas text-slate-900 antialiased min-h-screen flex flex-col">
      <header className="w-full p-6 sticky top-0 bg-canvas z-50">
        <a href="/" className="inline-flex items-center gap-2.5 group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand rounded-lg p-1 -m-1" aria-label="Seralgn home">
          <span className="w-10 h-10 rounded-2xl flex items-center justify-center shadow-md transition-transform duration-500 group-hover:rotate-[18deg] overflow-hidden">
            <img src="/assets/logo.svg" alt="Seralgn logo" className="w-full h-full object-cover" />
          </span>
          <span className="font-display font-extrabold text-2xl text-slate-900">Seralgn</span>
        </a>
      </header>

      <main className="flex-1 flex flex-col items-center justify-center p-6 pb-20">
        <div className="w-full max-w-md bg-white rounded-[2rem] shadow-soft p-8 sm:p-10 border border-slate-100 relative overflow-hidden" aria-labelledby="signup-title">
          <div className="absolute -top-12 -right-12 w-40 h-40 bg-brand/5 rounded-full pointer-events-none" />
          <div className="absolute bottom-10 -left-6 w-16 h-16 border-[6px] border-mint/20 rounded-full pointer-events-none" />
          
          <div className="relative z-10">
            <h1 id="signup-title" className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 text-center mb-2">Admin Portal</h1>
            <p className="text-slate-500 text-center mb-8">Register a new admin account</p>

            {submitted ? (
              <div className="bg-mint-light text-brand p-6 rounded-2xl text-center" role="status">
                <strong className="block font-bold text-lg mb-2">Account created successfully.</strong>
                <span className="block text-sm mb-6">Your admin account is ready to use.</span>
                <a href="/" className="w-full block bg-brand hover:bg-brand-dark text-white font-semibold py-4 rounded-xl shadow-md transition-all active:scale-[0.98]">Return to Seralgn</a>
              </div>
            ) : (
              <form className="space-y-6" onSubmit={handleSubmit}>
                <div className="space-y-2">
                  <label htmlFor="name" className="block text-sm font-bold text-slate-900">Full Name</label>
                  <input type="text" id="name" name="name" value={form.name} onChange={updateField} placeholder="E.g. Abebe Kebede" required className="w-full px-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:border-brand focus:ring-4 focus:ring-brand/10 transition-all outline-none font-medium text-slate-900 placeholder:text-slate-400" />
                </div>
                <div className="space-y-2">
                  <label htmlFor="email" className="block text-sm font-bold text-slate-900">Email Address</label>
                  <input type="email" id="email" name="email" value={form.email} onChange={updateField} placeholder="admin@seralgn.com" required className="w-full px-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:border-brand focus:ring-4 focus:ring-brand/10 transition-all outline-none font-medium text-slate-900 placeholder:text-slate-400" />
                </div>
                <div className="space-y-2">
                  <label htmlFor="password" className="block text-sm font-bold text-slate-900">Password</label>
                  <input type="password" id="password" name="password" value={form.password} onChange={updateField} placeholder="••••••••" minLength="8" required className="w-full px-4 py-3.5 bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:border-brand focus:ring-4 focus:ring-brand/10 transition-all outline-none font-medium text-slate-900 placeholder:text-slate-400" />
                </div>
                {error && <p className="text-red-500 text-sm font-medium" role="alert">{error}</p>}
                <button type="submit" className="w-full bg-brand hover:bg-brand-dark text-white font-semibold py-4 rounded-xl shadow-md shadow-brand/20 hover:shadow-lg hover:shadow-brand/30 transition-all active:scale-[0.98]">Sign Up</button>
              </form>
            )}

            {!submitted && (
              <p className="mt-8 text-center text-sm text-slate-600 font-medium">
                Already have an account? <a href="/sign-in" className="text-brand hover:text-brand-dark font-bold hover:underline underline-offset-4 decoration-2 transition-colors">Sign in</a>
              </p>
            )}
          </div>
        </div>
        <div className="mt-10 text-center text-sm text-slate-500 max-w-sm">
          By signing up, you agree to Seralgn's <a href="#terms" className="underline hover:text-slate-800">Terms of Service</a> and <a href="#privacy" className="underline hover:text-slate-800">Privacy Policy</a>.
        </div>
      </main>
    </div>
  )
}

