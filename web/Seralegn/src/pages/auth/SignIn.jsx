import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { login } from '../../services/authService'
import { useToast } from '../../context/ToastContext'

const schema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
})

export default function SignIn() {
  const [authError, setAuthError] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const navigate = useNavigate()
  const { showToast } = useToast()
  
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
    resolver: zodResolver(schema),
    defaultValues: {
      email: '',
      password: ''
    }
  })

  const onSubmit = async (data) => {
    setAuthError('')
    const result = await login(data.email, data.password)

    if (!result.success) {
      setAuthError(result.message || 'Invalid credentials')
      return
    }

    if (result.isAdmin && !result.isApproved) {
      showToast('Your admin request is still pending.', 'warning')
      navigate('/', { replace: true })
      return
    }

    // Redirect to admin dashboard
    navigate('/admin/dashboard', { replace: true })
  }

  return (
    <div className="bg-canvas text-slate-900 antialiased min-h-screen flex flex-col">
      <header className="w-full p-6 sticky top-0 bg-canvas z-50">
        <Link to="/" className="inline-flex items-center gap-2.5 group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand rounded-lg p-1 -m-1" aria-label="Seralgn home">
          <span className="w-10 h-10 rounded-2xl flex items-center justify-center shadow-md transition-transform duration-500 group-hover:rotate-[18deg] overflow-hidden">
            <img src="/logo.svg" alt="Seralgn logo" className="w-full h-full object-cover" />
          </span>
          <span className="font-display font-extrabold text-2xl text-slate-900">Seralgn</span>
        </Link>
      </header>

      <main className="flex-1 flex flex-col items-center justify-center p-6 pb-20">
        <div className="w-full max-w-md bg-white rounded-[2rem] shadow-soft p-8 sm:p-10 border border-slate-100 relative overflow-hidden" aria-labelledby="signin-title">
          <div className="absolute -top-12 -right-12 w-40 h-40 bg-brand/5 rounded-full pointer-events-none" />
          <div className="absolute bottom-10 -left-6 w-16 h-16 border-[6px] border-mint/20 rounded-full pointer-events-none" />
          
          <div className="relative z-10">
            <h1 id="signin-title" className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 text-center mb-2">Welcome Back</h1>
            <p className="text-slate-500 text-center mb-8">Sign in to your Seralgn account</p>

            <form className="space-y-6" onSubmit={handleSubmit(onSubmit)}>
              <div className="space-y-2">
                <label htmlFor="email" className="block text-sm font-bold text-slate-900">Email Address</label>
                <input 
                  type="email" 
                  id="email" 
                  placeholder="name@example.com" 
                  className={`w-full px-4 py-3.5 bg-slate-50 border rounded-xl focus:bg-white focus:ring-4 transition-all outline-none font-medium text-slate-900 placeholder:text-slate-400 ${errors.email ? 'border-red-500 focus:border-red-500 focus:ring-red-500/10' : 'border-slate-200 focus:border-brand focus:ring-brand/10'}`}
                  {...register('email')}
                />
                {errors.email && <p className="text-red-500 text-sm font-medium" role="alert">{errors.email.message}</p>}
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <label htmlFor="password" className="block text-sm font-bold text-slate-900">Password</label>
                  <Link to="/forgot-password" className="text-sm font-bold text-brand hover:text-brand-dark transition-colors">Forgot Password?</Link>
                </div>
                <div className="relative">
                  <input 
                    type={showPassword ? "text" : "password"}
                    id="password" 
                    placeholder="••••••••" 
                    className={`w-full px-4 py-3.5 bg-slate-50 border rounded-xl focus:bg-white focus:ring-4 transition-all outline-none font-medium text-slate-900 placeholder:text-slate-400 ${errors.password ? 'border-red-500 focus:border-red-500 focus:ring-red-500/10' : 'border-slate-200 focus:border-brand focus:ring-brand/10'}`}
                    {...register('password')}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 p-1.5 text-slate-400 hover:text-slate-600 focus:outline-none rounded-lg focus-visible:ring-2 focus-visible:ring-brand"
                    aria-label={showPassword ? "Hide password" : "Show password"}
                  >
                    {showPassword ? (
                      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.29 3.29m0 0a10.05 10.05 0 015.71-3.3m4.35 1.1A10.05 10.05 0 0121.543 12c-1.275 4.057-5.064 7-9.542 7" />
                      </svg>
                    ) : (
                      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </svg>
                    )}
                  </button>
                </div>
                {errors.password && <p className="text-red-500 text-sm font-medium" role="alert">{errors.password.message}</p>}
              </div>
              {authError && <p className="text-red-500 text-sm font-medium" role="alert">{authError}</p>}
              <button 
                type="submit" 
                disabled={isSubmitting}
                className="w-full flex items-center justify-center gap-2 bg-brand hover:bg-brand-dark disabled:bg-brand/70 text-white font-semibold py-4 rounded-xl shadow-md shadow-brand/20 hover:shadow-lg hover:shadow-brand/30 transition-all active:scale-[0.98] disabled:active:scale-100 disabled:cursor-not-allowed"
              >
                {isSubmitting ? (
                  <>
                    <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Signing In...
                  </>
                ) : 'Sign In'}
              </button>
            </form>

            <p className="mt-8 text-center text-sm text-slate-600 font-medium">
              Don't have an account? <Link to="/sign-up" className="text-brand hover:text-brand-dark font-bold hover:underline underline-offset-4 decoration-2 transition-colors">Sign up</Link>
            </p>
          </div>
        </div>
        <div className="mt-10 text-center text-sm text-slate-500 max-w-sm">
          By signing in, you agree to Seralgn's <a href="#terms" className="underline hover:text-slate-800">Terms of Service</a> and <a href="#privacy" className="underline hover:text-slate-800">Privacy Policy</a>.
        </div>
      </main>
    </div>
  )
}

