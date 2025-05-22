'use client'

import { useEffect, useState } from 'react'

interface UploadedItem {
  _id: string
  name: string
  phone: string
  imageUrl: string
  originalname: string
  createdAt: string
}

export default function ImageManager() {
  const [data, setData] = useState<UploadedItem[]>([])
  const [loading, setLoading] = useState(true)
  const [editItem, setEditItem] = useState<UploadedItem | null>(null)

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await fetch('/api/upload')
      const result = await res.json()
      setData(result)
    } catch (err) {
      console.error('Fetch error:', err)
    } finally {
      setLoading(false)
    }
  }

  const deleteImage = async (id: string) => {
    if (!confirm('Та устгахдаа итгэлтэй байна уу?')) return
    try {
      const res = await fetch(`/api/upload/${id}`, { method: 'DELETE' })
      if (res.ok) {
        setData(data.filter((item) => item._id !== id))
      } else {
        alert('Устгаж чадсангүй!')
      }
    } catch (err) {
      console.error('Устгах алдаа:', err)
    }
  }

  const saveEdit = async () => {
    if (!editItem) return

    const res = await fetch(`/api/upload/${editItem._id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: editItem.name, phone: editItem.phone }),
    })

    if (res.ok) {
      setEditItem(null)
      fetchData()
    } else {
      alert('Засвар амжилтгүй!')
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  return (
    <div className="p-4">
      {loading ? (
        <p>Уншиж байна...</p>
      ) : data.length === 0 ? (
        <p className="text-gray-500">Мэдээлэл байхгүй байна.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full border border-gray-300 rounded-xl shadow-sm bg-white">
            <thead className="bg-gray-100">
              <tr className="text-left">
                <th className="p-2 border">Зураг</th>
                <th className="p-2 border">Нэр</th>
                <th className="p-2 border">Утас</th>
                <th className="p-2 border">Үйлдэл</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item) => (
                <tr key={item._id} className="hover:bg-gray-50">
                  <td className="p-2 border">
                    <img
                      src={item.imageUrl}
                      alt={item.originalname}
                      className="w-20 h-20 object-cover rounded"
                    />
                  </td>
                  <td className="p-2 border">{item.name}</td>
                  <td className="p-2 border">{item.phone}</td>
                  <td className="p-2 border space-x-2">
                    <button
                      className="text-blue-600 hover:underline"
                      onClick={() => setEditItem(item)}
                    >
                      Засах
                    </button>
                    <button
                      className="text-red-600 hover:underline"
                      onClick={() => deleteImage(item._id)}
                    >
                      Устгах
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Edit Dialog */}
      {editItem && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl w-[400px] space-y-4 shadow-lg">
            <h3 className="text-lg font-semibold">Засах</h3>
            <input
              className="w-full border p-2"
              value={editItem.name}
              onChange={(e) => setEditItem({ ...editItem, name: e.target.value })}
              placeholder="Нэр"
            />
            <input
              className="w-full border p-2"
              value={editItem.phone}
              onChange={(e) => setEditItem({ ...editItem, phone: e.target.value })}
              placeholder="Утас"
            />
            <div className="flex justify-end gap-2">
              <button
                className="bg-gray-300 px-4 py-2 rounded"
                onClick={() => setEditItem(null)}
              >
                Болих
              </button>
              <button
                className="bg-green-600 text-white px-4 py-2 rounded"
                onClick={saveEdit}
              >
                Хадгалах
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
