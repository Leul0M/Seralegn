import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { sendPasswordResetEmail } from '../../services/authService'
import { useToast } from '../../context/ToastContext'

const schema = z.object({
  email: z.string().email('Please enter a valid email address'),
})

export default function ForgotPassword() {
  const [authError, setAuthError] = useState('')
  const [isSuccess, setIsSuccess] = useState(false)
  const { showToast } = useToast()
  
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm({
    resolver: zodResolver(schema),
    defaultValues: {
      email: ''
    }
  })

  const onSubmit = async (data) => {
    setAuthError('')
    const result = await sendPasswordResetEmail(data.email)

    if (!result.success) {
      setAuthError(result.message || 'Failed to send reset email')
      return
    }

    setIsSuccess(true)
    showToast('Password reset link sent to your email', 'success')
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
        <div className="w-full max-w-md bg-white rounded-[2rem] shadow-soft p-8 sm:p-10 border border-slate-100 relative overflow-hidden" aria-labelledby="forgot-title">
          <div className="absolute -top-12 -right-12 w-40 h-40 bg-brand/5 rounded-full pointer-events-none" />
          <div className="absolute bottom-10 -left-6 w-16 h-16 border-[6px] border-mint/20 rounded-full pointer-events-none" />
          
          <div className="relative z-10">
            <h1 id="forgot-title" className="font-display font-extrabold text-3xl sm:text-4xl text-slate-900 text-center mb-2">Reset Password</h1>
            <p className="text-slate-500 text-center mb-8">Enter your email and we'll send you a link to reset your password.</p>

            {isSuccess ? (
              <div className="bg-green-50 text-green-700 p-6 rounded-2xl border border-green-100 text-center space-y-4">
                <div className="w-12 h-12 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto">
                  <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                </div>
                <div>
                  <h3 className="font-bold text-lg mb-1">Check your email</h3>
                  <p className="text-sm opacity-90">We've sent a password reset link to your email address.</p>
                </div>
                <Link to="/sign-in" className="block w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-3 rounded-xl transition-colors">
                  Return to Sign In
                </Link>
              </div>
            ) : (
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
                      Sending...
                    </>
                  ) : 'Send Reset Link'}
                </button>
              </form>
            )}

            <p className="mt-8 text-center text-sm text-slate-600 font-medium">
              Remember your password? <Link to="/sign-in" className="text-brand hover:text-brand-dark font-bold hover:underline underline-offset-4 decoration-2 transition-colors">Sign in</Link>
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}
