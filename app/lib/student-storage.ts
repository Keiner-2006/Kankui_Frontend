type Student = {
  id: string
  name: string
  identification: string
  grade: string
  pin: string
}

const STORAGE_KEY = 'kankui-students'

export const initialStudents: Student[] = [
  {
    id: 'S-1001',
    name: 'Juan Kakuamo',
    identification: '1045231789',
    grade: 'Quinto',
    pin: 'K-4281',
  },
  {
    id: 'S-1002',
    name: 'María Izquierdo',
    identification: '1043567821',
    grade: 'Cuarto',
    pin: 'K-3947',
  },
  {
    id: 'S-1003',
    name: 'Carlos Ríos',
    identification: '1044890234',
    grade: 'Sexto',
    pin: 'K-5612',
  },
  {
    id: 'S-1004',
    name: 'Ana Torres',
    identification: '1042341567',
    grade: 'Tercero',
    pin: 'K-2834',
  },
  {
    id: 'S-1005',
    name: 'Luis Villafaña',
    identification: '1045678923',
    grade: 'Primero',
    pin: 'K-7195',
  },
]

export function loadStudents(): Student[] {
  if (typeof window === 'undefined') {
    return initialStudents
  }

  const raw = window.localStorage.getItem(STORAGE_KEY)
  return raw ? JSON.parse(raw) : initialStudents
}

export function saveStudents(students: Student[]) {
  if (typeof window === 'undefined') {
    return
  }

  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(students))
}

export function generatePin() {
  return `K-${Math.floor(1000 + Math.random() * 9000)}`
}
