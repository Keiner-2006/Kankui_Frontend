'use client'

import Link from 'next/link'
import { useEffect, useMemo, useState } from 'react'
import { initialStudents, loadStudents, saveStudents } from '../lib/student-storage'

type Student = {
  id: string
  name: string
  grade: string
  identification: string
  pin: string
}

export default function DashboardPage() {
  const [students, setStudents] = useState<Student[]>(initialStudents)
  const [query, setQuery] = useState('')

  useEffect(() => {
    setStudents(loadStudents())
  }, [])

  useEffect(() => {
    saveStudents(students)
  }, [students])

  const filteredStudents = useMemo(
    () =>
      students.filter((student) => {
        const search = query.trim().toLowerCase()
        return (
          student.name.toLowerCase().includes(search) ||
          student.identification.includes(search) ||
          student.pin.toLowerCase().includes(search)
        )
      }),
    [query, students]
  )

  function handleExport() {
    const csvRows = [
      ['Nombre', 'ID interno', 'Identificación', 'Grado', 'PIN'],
      ...students.map((student) => [student.name, student.id, student.identification, student.grade, student.pin]),
    ]

    const csv = csvRows.map((row) => row.map((value) => `"${value}"`).join(',')).join('\n')
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = 'estudiantes.csv'
    link.click()
    URL.revokeObjectURL(url)
  }

  return (
    <main className="min-h-screen bg-[#f7efe6] px-4 py-10 text-[#5a3721]">
      <div className="mx-auto max-w-5xl space-y-6">
        <section className="rounded-[32px] bg-[#7d4d1c] p-8 text-white shadow-[0_30px_80px_rgba(95,50,30,0.18)]">
          <div className="flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-sm opacity-90">I.E. Indígena Atánquez</p>
              <h1 className="mt-3 text-3xl font-semibold">Panel de Administración</h1>
            </div>
            <div className="flex items-center gap-3 rounded-3xl bg-[#f1d4b1]/30 px-4 py-3 text-sm text-[#3a1f0e] shadow-inner">
              <span className="font-semibold">{students.length} Estudiantes Registrados</span>
              <button
                type="button"
                onClick={handleExport}
                className="rounded-full bg-[#f2e5d3] px-4 py-2 text-sm font-semibold text-[#5d3d25] transition hover:bg-[#f8efdf]"
              >
                Exportar
              </button>
            </div>
          </div>

          <div className="mt-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="relative w-full max-w-xl">
              <span className="pointer-events-none absolute inset-y-0 left-4 grid place-items-center text-[#7b5c43]">🔎</span>
              <input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Buscar estudiante..."
                className="w-full rounded-full border border-[#dec4a4] bg-[#fff7ee] py-4 pl-12 pr-4 text-sm text-[#4d3624] outline-none transition focus:border-[#8a4f1c] focus:ring-2 focus:ring-[#e2c2a0]/60"
              />
            </div>
            <Link href="/register" className="inline-flex items-center justify-center rounded-full bg-[#f1d4b1] px-5 py-4 text-sm font-semibold text-[#5a3721] shadow-lg transition hover:bg-[#f6e3cf]">
              + Agregar Estudiante
            </Link>
          </div>
        </section>

        <section className="grid gap-4">
          {filteredStudents.map((student) => (
            <article key={student.id} className="rounded-[28px] border border-[#e4d3bd] bg-white/95 p-6 shadow-[0_16px_40px_rgba(92,52,27,0.08)]">
              <div className="flex items-center gap-4">
                <div className="flex h-14 w-14 items-center justify-center rounded-3xl bg-[#f5d7b0] text-xl font-semibold text-[#7a4b24] shadow-inner">
                  {student.name.split(' ').map((part) => part[0]).slice(0, 2).join('')}
                </div>
                <div>
                  <h2 className="text-lg font-semibold text-[#4d3624]">{student.name}</h2>
                  <p className="text-sm text-[#8a6f58]">ID: {student.identification}</p>
                </div>
                <div className="ml-auto rounded-3xl border border-[#d5c0a4] bg-[#eef5e7] px-4 py-2 text-sm font-semibold text-[#3d5a33]">
                  PIN {student.pin}
                </div>
              </div>
              <div className="mt-4 flex flex-wrap gap-3 text-sm text-[#7b5f46]">
                <span className="rounded-full bg-[#f8ede0] px-3 py-2">Grado: {student.grade}</span>
                <span className="rounded-full bg-[#f8ede0] px-3 py-2">ID interno: {student.id}</span>
              </div>
            </article>
          ))}

          {filteredStudents.length === 0 ? (
            <div className="rounded-[28px] border border-[#dec4a0] bg-[#fff7ee] p-8 text-center text-[#8a6f58]">
              No se encontró ningún estudiante con esa búsqueda.
            </div>
          ) : null}
        </section>
      </div>

      <Link href="/register" className="fixed bottom-6 right-6 inline-flex h-14 w-14 items-center justify-center rounded-full bg-[#8a4f1c] text-3xl text-white shadow-[0_16px_32px_rgba(89,51,22,0.24)] transition hover:bg-[#754014]">
        +
      </Link>
    </main>
  )
}
