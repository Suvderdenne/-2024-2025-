'use client'

import { useState } from 'react'

export default function UploadForm() {
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [image, setImage] = useState<File | null>(null)
  const [imageUrl, setImageUrl] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name || !phone || !image) {
      alert('Бүх талбарыг бөглөнө үү.')
      return
    }

    const formData = new FormData()
    formData.append('name', name)
    formData.append('phone', phone)
    formData.append('image', image)

    setLoading(true)

    try {
      const res = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
      })

      const data = await res.json()
      if (data.imageUrl) {
        setImageUrl(data.imageUrl)
      } else {
        alert('Амжилтгүй боллоо')
      }
    } catch (err) {
      console.error('Upload error:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-md mx-auto mt-10 p-4 border rounded shadow">
      <h2 className="text-xl font-semibold mb-4">Агент нэмэх</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <p className="text-sm text-gray-600 mb-1">Нэр</p>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full border p-2 rounded"
          />
        </div>
        <div>
          <p className="text-sm text-gray-600 mb-1">Утасны дугаар</p>
          <input
            type="text"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            className="w-full border p-2 rounded"
          />
        </div>
        <div>
          <p className="text-sm text-gray-600 mb-1">Зураг</p>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => setImage(e.target.files?.[0] || null)}
            className="w-full border p-2 rounded"
          />
        </div>
        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          disabled={loading}
        >
          {loading ? 'Хадгалж байна...' : 'Байршуулах'}
        </button>
      </form>

      {imageUrl && (
        <div className="mt-6">
          <p className="font-medium">Амжилттай:</p>
          <img src={imageUrl} alt="Uploaded" className="mt-2 max-w-full rounded border" />
        </div>
      )}
    </div>
  )
}
