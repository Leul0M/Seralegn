import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { login } from '../../utils/auth'

const schema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
})

export default function SignIn() {
  const [authError, setAuthError] = useState('')
  const navigate = useNavigate()
  
  const { register, handleSubmit, formState: { errors } } = useForm({
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

    // Redirect to admin dashboard
    navigate('/admin/dashboard')
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
                <label htmlFor="password" className="block text-sm font-bold text-slate-900">Password</label>
                <input 
                  type="password" 
                  id="password" 
                  placeholder="••••••••" 
                  className={`w-full px-4 py-3.5 bg-slate-50 border rounded-xl focus:bg-white focus:ring-4 transition-all outline-none font-medium text-slate-900 placeholder:text-slate-400 ${errors.password ? 'border-red-500 focus:border-red-500 focus:ring-red-500/10' : 'border-slate-200 focus:border-brand focus:ring-brand/10'}`}
                  {...register('password')}
                />
                {errors.password && <p className="text-red-500 text-sm font-medium" role="alert">{errors.password.message}</p>}
              </div>
              {authError && <p className="text-red-500 text-sm font-medium" role="alert">{authError}</p>}
              <button type="submit" className="w-full bg-brand hover:bg-brand-dark text-white font-semibold py-4 rounded-xl shadow-md shadow-brand/20 hover:shadow-lg hover:shadow-brand/30 transition-all active:scale-[0.98]">Sign In</button>
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

