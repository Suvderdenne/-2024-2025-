'use client'

import Link from 'next/link'
import { useEffect, useState } from 'react'

export interface UneKhansh {
  _id: string
  baiguullaga: string
  projectNer: string
  bairshil: string
  ailToo: string
  ashiglaltOgnoo: string
  uruuniSongolt: string
  uruuniHemjee: string
  une: string
}

export default function UneKhanshTable() {
  const [data, setData] = useState<UneKhansh[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/unekhansh')
      .then((res) => res.json())
      .then((resData) => setData(resData.reverse())) // Шинэ датаг эхэнд гаргана
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <p className="p-4">Ачааллаж байна...</p>

  return (
    <div className="p-6 max-w-full overflow-x-auto">
      <table className="min-w-[1000px] w-full border border-gray-200 shadow text-sm text-left">
        <thead className="bg-gray-100 text-gray-700">
          <tr>
            <th className="p-2">#</th>
            <th className="p-2">Байгууллага</th>
            <th className="p-2">Төслийн нэр</th>
            <th className="p-2">Байршил</th>
            <th className="p-2">Айлын тоо</th>
            <th className="p-2">Ашиглалтанд орох</th>
            <th className="p-2">Өрөө</th>
            <th className="p-2">Хэмжээ (м²)</th>
            <th className="p-2">Үнэ</th>
          </tr>
        </thead>
        <tbody>
          {data.map((item, index) => (
            <tr key={item._id} className="border-t hover:bg-gray-50">
              <td className="p-2 text-center">{index + 1}</td>
              <td className="p-2">{item.baiguullaga}</td>
              <td className="p-2">{item.projectNer}</td>
              <td className="p-2">{item.bairshil}</td>
              <td className="p-2 text-center">{item.ailToo}</td>
              <td className="p-2">{item.ashiglaltOgnoo}</td>
              <td className="p-2">{item.uruuniSongolt}</td>
              <td className="p-2 text-center">{item.uruuniHemjee}</td>
              <td className="p-2 font-semibold text-green-600">{item.une}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
