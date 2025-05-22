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

export default function Agentcard() {
  const [data, setData] = useState<UploadedItem[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await fetch('/api/upload')
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

  if (loading) return <div className="p-6 text-center">Уншиж байна...</div>

  return (
    <div className="p-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {data.map((item) => (
        <div key={item._id} className="card bg-base-100 w-56 shadow-md">
          <figure>
            <img
              src={item.imageUrl}
              alt={item.originalname}
              className="w-56 h-full object-cover"
            />
          </figure>
          <div className="card-body bg-slate-200">
            <h2 className="card-title">{item.name}</h2>
            <p>📞 {item.phone}</p>
          </div>
        </div>
      ))}
    </div>
  )
}
