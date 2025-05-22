'use client'

import { useEffect, useState } from 'react'

interface ShineBairItem {
  _id: string
  title: string
  imgUrl: string
  une: string
  company: string
  phone: string
  khugatsaa: string
  angilal: string
  khiits: string
  turul: string
  tailbar: string
  ognoo: string
}

export default function ShineBairManager() {
  const [items, setItems] = useState<ShineBairItem[]>([])
  const [loading, setLoading] = useState(true)
  const [editItem, setEditItem] = useState<ShineBairItem | null>(null)

  const fetchItems = async () => {
    setLoading(true)
    const res = await fetch('/api/shinebair')
    const data = await res.json()
    setItems(data)
    setLoading(false)
  }

  const deleteItem = async (id: string) => {
    if (!confirm('Та устгахдаа итгэлтэй байна уу?')) return
    await fetch(`/api/shinebair/${id}`, { method: 'DELETE' })
    fetchItems()
  }

  const saveEdit = async () => {
    if (!editItem) return
    const res = await fetch(`/api/shinebair/${editItem._id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(editItem),
    })
    if (res.ok) {
      setEditItem(null)
      fetchItems()
    }
  }

  useEffect(() => {
    fetchItems()
  }, [])

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <h2 className="text-2xl font-bold mb-4">🏢 Бүх байрны жагсаалт</h2>

      {loading ? (
        <p>Уншиж байна...</p>
      ) : (
        <div className="grid gap-6">
          {items.map((item) => (
            <div
              key={item._id}
              className="bg-white rounded-xl shadow p-4 flex flex-col md:flex-row gap-4"
            >
              <img
                src={item.imgUrl}
                alt={item.title}
                className="w-full md:w-48 h-48 object-cover rounded"
              />
              <div className="flex-1 space-y-1">
                <h3 className="text-xl font-semibold">{item.title}</h3>
                <p className="text-sm text-gray-700">
                  💰 <strong>{item.une}</strong> | 🏢 {item.company}
                </p>
                <p className="text-sm">📞 {item.phone} | 📅 {item.khugatsaa}</p>
                <p className="text-sm">
                  🏷️ {item.angilal} | 🧱 {item.khiits} | 🏠 {item.turul}
                </p>
                <div className="mt-2 text-sm text-gray-600 max-h-24 overflow-y-auto border-t pt-2">
                  {item.tailbar}
                </div>
              </div>
              <div className="flex md:flex-col gap-2 md:items-end justify-end">
                <button
                  onClick={() => setEditItem(item)}
                  className="text-blue-600 hover:underline"
                >
                  Засах
                </button>
                <button
                  onClick={() => deleteItem(item._id)}
                  className="text-red-600 hover:underline"
                >
                  Устгах
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Edit Modal */}
      {editItem && (
        <div className="fixed inset-0 bg-black/40 flex justify-center items-center z-50">
          <div className="bg-white p-6 rounded-lg w-[500px] space-y-3">
            <h3 className="text-lg font-bold">Засвар хийх</h3>

            {[
              ['title', 'Гарчиг'],
              ['une', 'Үнэ'],
              ['company', 'Компани'],
              ['phone', 'Утас'],
              ['khugatsaa', 'Хугацаа'],
              ['angilal', 'Ангилал'],
              ['khiits', 'Хийц'],
              ['turul', 'Төрөл'],
            ].map(([key, label]) => (
              <input
                key={key}
                className="input input-bordered w-full"
                placeholder={label}
                value={(editItem as any)[key]}
                onChange={(e) =>
                  setEditItem({ ...editItem, [key]: e.target.value })
                }
              />
            ))}

            <textarea
              className="textarea textarea-bordered w-full"
              value={editItem.tailbar}
              onChange={(e) =>
                setEditItem({ ...editItem, tailbar: e.target.value })
              }
              placeholder="Тайлбар"
            />

            <div className="flex justify-end gap-2">
              <button onClick={() => setEditItem(null)} className="btn">Болих</button>
              <button onClick={saveEdit} className="btn btn-primary">Хадгалах</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
