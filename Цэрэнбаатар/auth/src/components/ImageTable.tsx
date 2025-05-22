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

export default function ImageTable() {
  const [data, setData] = useState<UploadedItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await fetch('/api/upload') // Same endpoint for GET
        const result = await res.json()
        setData(result)
      } catch (err) {
        console.error('Error fetching data:', err)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) return <div>Уншиж байна...</div>

  return (
    <div className="p-4">
      <div className="overflow-x-auto">
        <table className="min-w-full border">
          <thead>
            <tr className="bg-gray-100 text-left">
              <th className="border p-2">Зураг</th>
              <th className="border p-2">Нэр</th>
              <th className="border p-2">Утасны дугаар</th>
              
            </tr>
          </thead>
          <tbody>
            {data.map((item) => (
              <tr key={item._id}>
                <td className="border p-2">
                  <img src={item.imageUrl} alt={item.originalname} className="w-20 h-20 object-cover rounded" />
                </td>
                <td className="border p-2">{item.name}</td>
                <td className="border p-2">{item.phone}</td>
                
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
