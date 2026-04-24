'use client'

import type { FormEvent } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useState } from 'react'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!email.trim() || !password.trim()) {
      setError('Por favor ingresa correo institucional y contraseña.')
      return
    }

    setError('')
    router.push('/dashboard')
  }

  return (
    <main className="min-h-screen bg-[#f7efe6] px-4 py-10 text-[#5a3721]">
      <div className="mx-auto max-w-[450px] rounded-[34px] border border-[#ddc4a0] bg-[#fff8f0] p-8 shadow-[0_30px_80px_rgba(95,50,30,0.12)]">
        <div className="mb-10 text-center">
          <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-[#8a4f1c] text-2xl text-white shadow-inner">
            <span>✦</span>
          </div>
          <p className="text-sm uppercase tracking-[0.24em] text-[#8a4f1c]">Portal Docente</p>
          <h1 className="mt-3 text-3xl font-semibold">Acceso al panel administrativo</h1>
        </div>

        <form className="space-y-5" onSubmit={handleSubmit}>
          <label className="block text-sm font-medium text-[#6b4631]">
            Correo Institucional
            <input
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="profesor@ieatanquez.edu.co"
              className="mt-2 w-full rounded-3xl border border-[#dac5ab] bg-[#f9efe0] px-4 py-3 text-sm text-[#4d3624] outline-none transition focus:border-[#8a4f1c] focus:ring-2 focus:ring-[#e3c4a0]/60"
            />
          </label>

          <label className="block text-sm font-medium text-[#6b4631]">
            Contraseña
            <input
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="********"
              className="mt-2 w-full rounded-3xl border border-[#dac5ab] bg-[#f9efe0] px-4 py-3 text-sm text-[#4d3624] outline-none transition focus:border-[#8a4f1c] focus:ring-2 focus:ring-[#e3c4a0]/60"
            />
          </label>

          {error ? <p className="text-sm text-[#ad3f18]">{error}</p> : null}

          <button
            type="submit"
            className="w-full rounded-3xl bg-[#8a4f1c] px-5 py-4 text-sm font-semibold uppercase tracking-[0.12em] text-white transition hover:bg-[#754014]"
          >
            Acceder al Panel Administrativo
          </button>

          <div className="flex items-center justify-between text-sm text-[#7c5a42]">
            <Link href="#" className="underline decoration-dotted underline-offset-2">
              ¿Olvidaste tu contraseña?
            </Link>
          </div>
        </form>

        <p className="mt-8 text-center text-xs text-[#8b6a51]">
          Acceso exclusivo para docentes autorizados
        </p>
      </div>
    </main>
  )
}
