'use client'

import type { FormEvent } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useEffect, useState } from 'react'
import { generatePin, loadStudents, saveStudents } from '../lib/student-storage'

type Student = {
  id: string
  name: string
  identification: string
  grade: string
  pin: string
}

const gradeOptions = ['Preescolar', 'Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto', 'Sexto']

export default function RegisterStudentPage() {
  const router = useRouter()
  const [name, setName] = useState('')
  const [identification, setIdentification] = useState('')
  const [grade, setGrade] = useState('')
  const [students, setStudents] = useState([])
  const [error, setError] = useState('')

  useEffect(() => {
    setStudents(loadStudents())
  }, [])

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    if (!name.trim() || !identification.trim() || !grade) {
      setError('Debes completar todos los campos antes de guardar.')
      return
    }

    const newStudent = {
      id: crypto.randomUUID(),
      name: name.trim(),
      identification: identification.trim(),
      grade,
      pin: generatePin(),
    }

    const updatedStudents = [newStudent, ...students]
    saveStudents(updatedStudents)
    router.push('/dashboard')
  }

  return (
    <main className="min-h-screen bg-[#f7efe6] px-4 py-10 text-[#5a3721]">
      <div className="mx-auto max-w-[540px] rounded-[34px] border border-[#ddc4a0] bg-[#fff8f0] p-8 shadow-[0_30px_80px_rgba(95,50,30,0.12)]">
        <div className="mb-8">
          <p className="text-sm uppercase tracking-[0.24em] text-[#8a4f1c]">Inscribir Estudiante</p>
          <h1 className="mt-3 text-3xl font-semibold">Registra un nuevo alumno al sistema</h1>
        </div>

        <form className="space-y-6" onSubmit={handleSubmit}>
          <label className="block text-sm font-medium text-[#6b4631]">
            Nombre Completo
            <input
              type="text"
              value={name}
              onChange={(event) => setName(event.target.value)}
              placeholder="Ej: Juan Carlos Kakuamo Torres"
              className="mt-2 w-full rounded-3xl border border-[#dac5ab] bg-[#f9efe0] px-4 py-3 text-sm text-[#4d3624] outline-none transition focus:border-[#8a4f1c] focus:ring-2 focus:ring-[#e3c4a0]/60"
            />
          </label>

          <label className="block text-sm font-medium text-[#6b4631]">
            Número de Identificación
            <input
              type="text"
              value={identification}
              onChange={(event) => setIdentification(event.target.value)}
              placeholder="1234567890"
              className="mt-2 w-full rounded-3xl border border-[#dac5ab] bg-[#f9efe0] px-4 py-3 text-sm text-[#4d3624] outline-none transition focus:border-[#8a4f1c] focus:ring-2 focus:ring-[#e3c4a0]/60"
            />
          </label>

          <label className="block text-sm font-medium text-[#6b4631]">
            Grado Escolar
            <select
              value={grade}
              onChange={(event) => setGrade(event.target.value)}
              className="mt-2 w-full rounded-3xl border border-[#dac5ab] bg-[#f9efe0] px-4 py-3 text-sm text-[#4d3624] outline-none transition focus:border-[#8a4f1c] focus:ring-2 focus:ring-[#e3c4a0]/60"
            >
              <option value="">Seleccionar grado...</option>
              {gradeOptions.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
          </label>

          {error ? <p className="text-sm text-[#ad3f18]">{error}</p> : null}

          <div className="rounded-[28px] border border-dashed border-[#d8b18e] bg-[#fff5e6] p-6 text-center text-[#7a5234]">
            <p className="text-sm uppercase tracking-[0.3em] text-[#8a4f1c]/90">PIN Generado Automáticamente</p>
            <p className="mt-4 text-3xl font-semibold tracking-[0.1em] text-[#8a4f1c]">K-????</p>
          </div>

          <button
            type="submit"
            className="w-full rounded-3xl bg-[#8a4f1c] px-5 py-4 text-sm font-semibold uppercase tracking-[0.12em] text-white transition hover:bg-[#754014]"
          >
            Guardar y Generar Código
          </button>
        </form>

        <p className="mt-6 text-sm text-[#8a6f58]">
          El PIN será generado automáticamente al guardar. Entrégalo al estudiante para su primer acceso.
        </p>

        <Link href="/dashboard" className="mt-6 inline-flex text-sm font-medium text-[#7a5234] underline decoration-dotted underline-offset-4">
          Volver al dashboard
        </Link>
      </div>
    </main>
  )
}
