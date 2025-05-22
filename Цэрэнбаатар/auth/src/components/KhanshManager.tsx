'use client'
import { useEffect, useState } from 'react'

export default function KhanshManager() {
  const [items, setItems] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [editItem, setEditItem] = useState<any | null>(null)

  const fetchData = async () => {
    setLoading(true)
    try {
      const res = await fetch('/api/unekhansh')
      const data = await res.json()
      setItems(data)
    } catch (err) {
      console.error('Алдаа:', err)
    } finally {
      setLoading(false)
    }
  }

  const deleteItem = async (id: string) => {
    if (!confirm('Устгах уу?')) return
    try {
      const res = await fetch(`/api/unekhansh/${id}`, { method: 'DELETE' })
      if (res.ok) {
        fetchData()
      } else {
        alert('Устгаж чадсангүй')
      }
    } catch {
      alert('Алдаа гарлаа')
    }
  }

  const saveChanges = async () => {
    if (!editItem) return

    const res = await fetch(`/api/unekhansh/${editItem._id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(editItem),
    })

    if (res.ok) {
      setEditItem(null)
      fetchData()
    } else {
      alert('Засвар амжилтгүй')
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  return (
    <div>
      {loading ? (
        <p>Уншиж байна...</p>
      ) : items.length === 0 ? (
        <p>Одоогоор үнэ ханш алга байна.</p>
      ) : (
        <table className="min-w-full border bg-white rounded-xl shadow">
          <thead className="bg-gray-100 text-sm">
            <tr>
              <th className="p-2 border">Байгууллага</th>
              <th className="p-2 border">Төслийн нэр</th>
              <th className="p-2 border">Байршил</th>
              <th className="p-2 border">Нэгж үнэ</th>
              <th className="p-2 border">Ашиглалтанд орох</th>
              <th className="p-2 border">Үйлдэл</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => (
              <tr key={item._id} className="hover:bg-gray-50 text-sm">
                <td className="border p-2">{item.baiguullaga}</td>
                <td className="border p-2">{item.projectNer}</td>
                <td className="border p-2">{item.bairshil}</td>
                <td className="border p-2">{item.une}</td>
                <td className="border p-2">{item.ashiglaltOgnoo}</td>
                <td className="border p-2">
                  <button className="text-blue-600 mr-2" onClick={() => setEditItem(item)}>Засах</button>
                  <button className="text-red-600" onClick={() => deleteItem(item._id)}>Устгах</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}

      {/* Засах modal */}
      {editItem && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg w-[400px] space-y-4 max-h-[90vh] overflow-y-auto">
            <h2 className="text-lg font-bold">Засах</h2>
            <input
              className="w-full border p-2"
              value={editItem.baiguullaga}
              onChange={(e) => setEditItem({ ...editItem, baiguullaga: e.target.value })}
              placeholder="Байгууллага"
            />
            <input
              className="w-full border p-2"
              value={editItem.projectNer}
              onChange={(e) => setEditItem({ ...editItem, projectNer: e.target.value })}
              placeholder="Төслийн нэр"
            />
            <input
              className="w-full border p-2"
              value={editItem.bairshil}
              onChange={(e) => setEditItem({ ...editItem, bairshil: e.target.value })}
              placeholder="Байршил"
            />
            <input
              className="w-full border p-2"
              value={editItem.ailToo}
              onChange={(e) => setEditItem({ ...editItem, ailToo: e.target.value })}
              placeholder="Айлын тоо"
            />
            <input
              className="w-full border p-2"
              value={editItem.uruuniSongolt}
              onChange={(e) => setEditItem({ ...editItem, uruuniSongolt: e.target.value })}
              placeholder="Өрөөний сонголт"
            />
            <input
              className="w-full border p-2"
              value={editItem.uruuniHemjee}
              onChange={(e) => setEditItem({ ...editItem, uruuniHemjee: e.target.value })}
              placeholder="Өрөөний хэмжээ"
            />
            <input
              className="w-full border p-2"
              value={editItem.une}
              onChange={(e) => setEditItem({ ...editItem, une: e.target.value })}
              placeholder="Үнэ"
            />
            <input
              type="date"
              className="w-full border p-2"
              value={editItem.ashiglaltOgnoo?.slice(0, 10)}
              onChange={(e) => setEditItem({ ...editItem, ashiglaltOgnoo: e.target.value })}
            />
            <div className="flex justify-between pt-2">
              <button onClick={saveChanges} className="bg-green-600 text-white px-4 py-2 rounded">Хадгалах</button>
              <button onClick={() => setEditItem(null)} className="bg-gray-300 px-4 py-2 rounded">Болих</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
