'use client'
import Link from 'next/link'
import { useEffect, useState } from 'react'

export default function MedeeManager() {
  const [medee, setMedee] = useState<any[]>([])
  const [loadingMedee, setLoadingMedee] = useState(false)
  const [editItem, setEditItem] = useState<any | null>(null)
  const [editImage, setEditImage] = useState<File | null>(null)

  const fetchMedee = async () => {
    setLoadingMedee(true)
    try {
      const res = await fetch('/api/medee')
      const data = await res.json()
      setMedee(data)
    } catch (err) {
      console.error('Fetch error:', err)
    } finally {
      setLoadingMedee(false)
    }
  }

  const deleteMedee = async (id: string) => {
    if (!confirm('Та устгахдаа итгэлтэй байна уу?')) return
    try {
      const res = await fetch(`/api/medee/${id}`, { method: 'DELETE' })
      if (res.ok) {
        setMedee(medee.filter(m => m._id !== id))
      } else {
        alert('Устгаж чадсангүй!')
      }
    } catch {
      alert('Сүлжээний алдаа!')
    }
  }

  const updateMedee = async () => {
    if (!editItem) return
    const form = new FormData()
    form.append('garchig', editItem.garchig)
    form.append('tailbar', editItem.tailbar)
    form.append('ognoo', editItem.ognoo)
    if (editImage) form.append('image', editImage)

    const res = await fetch(`/api/medee/${editItem._id}`, {
      method: 'PATCH',
      body: form,
    })

    if (res.ok) {
      setEditItem(null)
      setEditImage(null)
      fetchMedee()
    } else {
      alert('Засвар амжилтгүй!')
    }
  }

  useEffect(() => {
    fetchMedee()
  }, [])

  return (
    <div>
      <Link href="/Addmedee">
        <button className="bg-blue-600 text-white px-4 py-2 rounded mb-6 hover:bg-blue-700">➕ Нэмэх</button>
      </Link>

      {loadingMedee ? (
        <p>Уншиж байна...</p>
      ) : medee.length === 0 ? (
        <p className="text-gray-500">Одоогоор мэдээ алга байна.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white border border-gray-200 shadow rounded-xl">
            <thead className="bg-gray-100">
              <tr>
                <th className="py-3 px-4 border-b text-left">Зураг</th>
                <th className="py-3 px-4 border-b text-left">Гарчиг</th>
                <th className="py-3 px-4 border-b text-left">Тайлбар</th>
                <th className="py-3 px-4 border-b text-left">Огноо</th>
                <th className="py-3 px-4 border-b text-left">Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {medee.map((item) => (
                <tr key={item._id} className="hover:bg-gray-50">
                  <td className="py-3 px-4 border-b">
                    <img src={item.imgUrl} alt="Зураг" className="w-16 h-16 object-cover rounded" />
                  </td>
                  <td className="py-3 px-4 border-b font-medium">{item.garchig}</td>
                  <td className="py-3 px-4 border-b text-sm text-gray-600 line-clamp-2">{item.tailbar}</td>
                  <td className="py-3 px-4 border-b text-xs text-gray-500">{new Date(item.ognoo).toLocaleDateString('mn-MN')}</td>
                  <td className="py-3 px-4 border-b text-sm space-x-2">
                    <button className="text-blue-600 hover:underline" onClick={() => setEditItem(item)}>Засах</button>
                    <button className="text-red-600 hover:underline" onClick={() => deleteMedee(item._id)}>Устгах</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {editItem && (
        <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center">
          <div className="bg-white p-6 rounded-lg w-[400px] space-y-4">
            <h2 className="text-xl font-bold">Мэдээ засах</h2>
            <input
              className="w-full border p-2"
              value={editItem.garchig}
              onChange={(e) => setEditItem({ ...editItem, garchig: e.target.value })}
              placeholder="Гарчиг"
            />
            <textarea
              className="w-full border p-2"
              value={editItem.tailbar}
              onChange={(e) => setEditItem({ ...editItem, tailbar: e.target.value })}
              placeholder="Тайлбар"
            />
            <input
              type="date"
              className="w-full border p-2"
              value={editItem.ognoo?.slice(0, 10)}
              onChange={(e) => setEditItem({ ...editItem, ognoo: e.target.value })}
            />
            <input
              type="file"
              onChange={(e) => setEditImage(e.target.files?.[0] || null)}
            />
            <div className="flex justify-between">
              <button onClick={updateMedee} className="bg-green-600 text-white px-4 py-2 rounded">Хадгалах</button>
              <button onClick={() => setEditItem(null)} className="bg-gray-300 px-4 py-2 rounded">Болих</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
