'use client'

import { useState } from 'react'

export default function BairUploader() {
  const today = new Date().toISOString().split('T')[0]

  const [form, setForm] = useState({
    title: '', duureg: '', khoroo: '', nukhtsul: '', turul: '',
    mkb: '', mkbune: '', niitune: '', niitelsenognoo: today, bairshil: '',
    phone: '', dawkhar: '', uruu: '', tailbar: ''
  })

  const [image, setImage] = useState<File | null>(null)
  const [uploaded, setUploaded] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const khorooOptionsMap: Record<string, string[]> = {
    'Баянзүрх': Array.from({ length: 43 }, (_, i) => `${i + 1}-р хороо`),
    'Сүхбаатар': Array.from({ length: 20 }, (_, i) => `${i + 1}-р хороо`),
    'Чингэлтэй': Array.from({ length: 24 }, (_, i) => `${i + 1}-р хороо`),
    'Баянгол': Array.from({ length: 23 }, (_, i) => `${i + 1}-р хороо`),
    'Хан-Уул': Array.from({ length: 25 }, (_, i) => `${i + 1}-р хороо`),
    'Сонгинохайрхан': Array.from({ length: 43 }, (_, i) => `${i + 1}-р хороо`),
    'Багануур': Array.from({ length: 5 }, (_, i) => `${i + 1}-р хороо`),
    'Налайх': Array.from({ length: 7 }, (_, i) => `${i + 1}-р хороо`),
  }

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target

    if (name === 'duureg') {
      setForm((prev) => ({ ...prev, duureg: value, khoroo: '' }))
      return
    }

    let updatedForm = { ...form, [name]: value }

    if (name === 'mkb' || name === 'mkbune') {
      const mkb = parseFloat(name === 'mkb' ? value : form.mkb)
      const mkbune = parseFloat(name === 'mkbune' ? value : form.mkbune)
      const niitune = mkb * mkbune
      updatedForm.niitune = niitune ? niitune.toString() : ''
    }

    setForm(updatedForm)
  }

  const handleUpload = async () => {
    setError(null)
    if (!image) {
      setError('Зураг заавал оруулна уу')
      return
    }

    setLoading(true)
    const formData = new FormData()
    Object.entries(form).forEach(([key, value]) => formData.append(key, value))
    formData.append('image', image)

    try {
      const res = await fetch('/api/bair', {
        method: 'POST',
        body: formData,
      })
      const data = await res.json()
      if (data.success) {
        setUploaded(data.imageUrl)
      } else {
        setError(data.message || 'Хуулж чадсангүй')
      }
    } catch (err) {
      setError('Алдаа гарлаа.')
    } finally {
      setLoading(false)
    }
  }

  const fields = [
    { name: 'title', label: 'Гарчиг' },
    { name: 'duureg', label: 'Дүүрэг', type: 'select', options: Object.keys(khorooOptionsMap) },
    { name: 'khoroo', label: 'Хороо', type: 'select', options: khorooOptionsMap[form.duureg] || [] },
    { name: 'nukhtsul', label: 'Нөхцөл байдал', type: 'select', options: ['Бэлэн', 'Зээл'] },
    { name: 'turul', label: 'Төрөл', type: 'select', options: ['Хуучин', 'Шинэ'] },
    { name: 'dawkhar', label: 'Давхар', type: 'select', options: ['1', '2', '3', '4', '5+'] },
    { name: 'uruu', label: 'Өрөөний тоо', type: 'select', options: ['1', '2', '3', '4', '5+'] },
    { name: 'mkb', label: 'Талбай (м²)' },
    { name: 'mkbune', label: 'Талбай үнэ (м²)' },
    { name: 'niitune', label: 'Нийт үнэ', readOnly: true },
    { name: 'niitelsenognoo', label: 'Нийтэлсэн огноо', type: 'date', readOnly: true },
    { name: 'bairshil', label: 'Байршил' },
    { name: 'phone', label: 'Утасны дугаар' },
  ]

  return (
    <div className="max-w-xl mx-auto p-6 bg-gray-50 rounded-xl shadow-md space-y-4">
      <h2 className="text-2xl font-bold mb-4">ЗАР НЭМЭХ</h2>

      {error && <p className="text-red-500">{error}</p>}

      {fields.map((field) => (
        <div key={field.name} className="space-y-1">
          <p className="text-sm text-gray-600">{field.label}</p>

          {field.type === 'select' ? (
            <select
              name={field.name}
              onChange={handleChange}
              value={form[field.name as keyof typeof form]}
              disabled={field.name === 'khoroo' && !form.duureg}
              className="w-full p-2 border rounded bg-white"
            >
              <option value="">Сонгох</option>
              {field.options?.map((option) => (
                <option key={option} value={option}>{option}</option>
              ))}
            </select>
          ) : field.type === 'date' ? (
            <input
              type="date"
              name={field.name}
              value={form[field.name as keyof typeof form]}
              readOnly
              className="w-full p-2 border rounded bg-white text-gray-700 cursor-not-allowed"
            />
          ) : (
            <input
              type="text"
              name={field.name}
              value={form[field.name as keyof typeof form]}
              onChange={handleChange}
              readOnly={field.readOnly}
              className={`w-full p-2 border rounded ${field.readOnly ? 'bg-white text-gray-500' : 'bg-white'}`}
            />
          )}
        </div>
      ))}

      <div className="space-y-1">
        <p className="text-sm text-gray-600">Дэлгэрэнгүй тайлбар</p>
        <textarea
          name="tailbar"
          onChange={handleChange}
          className="w-full p-2 border rounded bg-white"
        />
      </div>

      <div className="space-y-1">
        <p className="text-sm text-gray-600">Зураг оруулах</p>
        <input
          type="file"
          accept="image/*"
          onChange={(e) => setImage(e.target.files?.[0] || null)}
          className="w-full"
        />
      </div>

      <button
        onClick={handleUpload}
        disabled={loading}
        className="w-full bg-blue-600 text-white py-2 px-4 rounded hover:bg-blue-700"
      >
        {loading ? 'Хуулж байна...' : 'Хуулах'}
      </button>

      {uploaded && (
        <div className="mt-4">
          <p className="font-semibold">Оруулсан зураг:</p>
          <img src={uploaded} alt="Uploaded" className="w-48 mt-2 border rounded" />
        </div>
      )}
    </div>
  )
}
