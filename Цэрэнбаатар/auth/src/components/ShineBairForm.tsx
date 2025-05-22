'use client'

import { useState } from 'react'

export default function ShineBairForm() {
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const [image, setImage] = useState<File | null>(null)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!image) return setMessage('Зураг заавал оруулна уу.')

    const form = e.currentTarget
    const formData = new FormData(form)
    formData.append('image', image)

    setLoading(true)
    setMessage('')

    try {
      const res = await fetch('/api/shinebair', {
        method: 'POST',
        body: formData,
      })

      const result = await res.json()
      if (res.ok) {
        setMessage('Амжилттай нэмэгдлээ!')
        form.reset()
        setImage(null)
      } else {
        setMessage(result.error || 'Алдаа гарлаа')
      }
    } catch (err) {
      setMessage('Сервертэй холбогдож чадсангүй')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="max-w-xl mx-auto p-6 bg-white shadow rounded space-y-4">
      <h2 className="text-lg font-bold">Шинэ байр нэмэх</h2>

      <div>
        <p>Гарчиг</p>
        <input name="title" type="text" placeholder="Гарчиг" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Үнэ</p>
        <input name="une" type="text" placeholder="Үнэ" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Компани</p>
        <input name="company" type="text" placeholder="Компани" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Утас</p>
        <input name="phone" type="text" placeholder="Утас" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Хугацаа</p>
        <input name="khugatsaa" type="text" placeholder="Хугацаа" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Ангилал</p>
        <input name="angilal" type="text" placeholder="Ангилал" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Хийц</p>
        <input name="khiits" type="text" placeholder="Хийц" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Төрөл</p>
        <input name="turul" type="text" placeholder="Төрөл" className="input input-bordered w-full" required />
      </div>

      <div>
        <p>Тайлбар</p>
        <textarea name="tailbar" placeholder="Тайлбар" className="textarea textarea-bordered w-full" required />
      </div>

      <div>
        <p>Зураг</p>
        <input
          type="file"
          accept="image/*"
          className="file-input file-input-bordered w-full"
          onChange={(e) => setImage(e.target.files?.[0] || null)}
          required
        />
      </div>

      <button type="submit" className="btn btn-primary w-full" disabled={loading}>
        {loading ? 'Хадгалж байна...' : 'Нэмэх'}
      </button>

      {message && <p className="text-center text-sm text-green-600">{message}</p>}
    </form>
  )
}
