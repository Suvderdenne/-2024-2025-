'use client'

import { useState } from 'react'

export default function AddMedeePage() {
  const [garchig, setGarchig] = useState('')
  const [tailbar, setTailbar] = useState('')
  const [image, setImage] = useState<File | null>(null)
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!garchig || !tailbar || !image) {
      alert('Бүх талбарыг бөглөнө үү.')
      return
    }

    setLoading(true)
    const formData = new FormData()
    formData.append('garchig', garchig)
    formData.append('tailbar', tailbar)
    formData.append('image', image)

    try {
      const res = await fetch('/api/medee', {
        method: 'POST',
        body: formData,
      })

      if (res.ok) {
        setSuccess(true)
        setGarchig('')
        setTailbar('')
        setImage(null)
      } else {
        const error = await res.json()
        alert(error?.error || 'Алдаа гарлаа')
      }
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-xl mx-auto mt-10 p-4 bg-white shadow rounded">
      <h1 className="text-xl font-bold mb-4">Мэдээ нэмэх</h1>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block font-medium">Гарчиг</label>
          <input
            type="text"
            value={garchig}
            onChange={(e) => setGarchig(e.target.value)}
            className="w-full border px-3 py-2 rounded"
          />
        </div>

        <div>
          <label className="block font-medium">Тайлбар</label>
          <textarea
            value={tailbar}
            onChange={(e) => setTailbar(e.target.value)}
            className="w-full border px-3 py-2 rounded"
            rows={4}
          ></textarea>
        </div>

        <div>
          <label className="block font-medium">Зураг</label>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => {
              if (e.target.files && e.target.files.length > 0) {
                setImage(e.target.files[0])
              }
            }}
            className="block"
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          {loading ? 'Илгээж байна...' : 'Нэмэх'}
        </button>

        {success && <p className="text-green-600 mt-2">Амжилттай хадгаллаа!</p>}
      </form>
    </div>
  )
}
