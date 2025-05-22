'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function AddUneKhanshPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  const [form, setForm] = useState({
    baiguullaga: '',
    projectNer: '',
    bairshil: '',
    ailToo: '',
    ashiglaltOgnoo: '',
    uruuniSongolt: '',
    uruuniHemjee: '',
    une: '',
  })

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setForm((prev) => ({ ...prev, [name]: value }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    const formData = new FormData()
    Object.entries(form).forEach(([key, value]) => formData.append(key, value))

    const res = await fetch('/api/unekhansh', {
      method: 'POST',
      body: formData,
    })

    if (res.ok) {
      alert('Амжилттай нэмэгдлээ!')
      router.push('/unekhansh')
    } else {
      alert('Алдаа гарлаа.')
    }

    setLoading(false)
  }

  return (
    <div className="max-w-3xl mx-auto mt-10 bg-white p-6 shadow rounded">
      <h1 className="text-xl font-bold mb-4">Нэмэх</h1>
      <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4">
        <div>
          <p className="text-sm text-gray-500 mb-1">Байгууллагын нэр</p>
          <input name="baiguullaga" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Төслийн нэр</p>
          <input name="projectNer" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Байршил</p>
          <input name="bairshil" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Айлын тоо</p>
          <input name="ailToo" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Ашиглалтанд орох хугацаа</p>
          <input name="ashiglaltOgnoo" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Өрөөний сонголт</p>
          <input name="uruuniSongolt" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Хэмжээ (м.кв)</p>
          <input name="uruuniHemjee" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>
        <div>
          <p className="text-sm text-gray-500 mb-1">Үнэ</p>
          <input name="une" onChange={handleChange} required className="border p-2 rounded w-full" />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="col-span-2 bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
        >
          {loading ? 'Хадгалж байна...' : 'Хадгалах'}
        </button>
      </form>

    </div>
  )
}
