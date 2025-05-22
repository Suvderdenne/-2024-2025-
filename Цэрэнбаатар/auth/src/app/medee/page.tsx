'use client'

import MedeeCommentSection from '@/components/MedeeCommentSection'
import { useEffect, useState } from 'react'

type MedeeItem = {
  _id: string
  garchig: string
  imgUrl: string
  tailbar: string
  ognoo: string
}

export default function MedeeList() {
  const [medee, setMedee] = useState<MedeeItem[]>([])
  const [selected, setSelected] = useState<MedeeItem | null>(null)
  const [searchQuery, setSearchQuery] = useState('')

  useEffect(() => {
    const fetchData = async () => {
      const res = await fetch('/api/medee')
      const data = await res.json()
      setMedee(data)
    }

    fetchData()
  }, [])

  const filteredMedee = medee.filter((item) => {
    const query = searchQuery.toLowerCase()
    return (
      item.garchig.toLowerCase().includes(query) ||
      item.tailbar.toLowerCase().includes(query)
    )
  })

  return (
    <div className="max-w-7xl mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Мэдээ</h1>

      {/* 🔍 Хайлт */}
      <div className="mb-6 relative">
        <input
          type="text"
          className="w-full pl-12 pr-4 py-3 border border-black rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-accents"
          placeholder="Мэдээний гарчиг эсвэл агуулгаар хайх..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        <span className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 pointer-events-none">
          🔍
        </span>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredMedee.map((item) => (
          <div
            key={item._id}
            className="card bg-base-100 shadow-sm w-full cursor-pointer"
            onClick={() => setSelected(item)}
          >
            <figure className="px-10 pt-10">
              <img
                src={item.imgUrl}
                alt={item.garchig}
                className="rounded-xl h-48 object-cover"
              />
            </figure>
            <div className="card-body items-center text-center">
              <h2 className="card-title">{item.garchig}</h2>
              <p className="text-sm text-gray-500">
                {new Date(item.ognoo).toLocaleDateString()}
              </p>
              <div className="card-actions mt-2">
                <button className="btn btn-primary">Дэлгэрэнгүй</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Modal */}
      {selected && (
        <dialog
          id="medee_modal"
          className="modal modal-open"
          onClick={() => setSelected(null)}
        >
          <div
            className="modal-box w-[700px] max-w-full"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="font-bold text-lg mb-3">{selected.garchig}</h3>
            <img
              src={selected.imgUrl}
              alt="Image"
              className="w-full h-52 object-cover rounded mb-3"
            />
            <p className="text-sm text-gray-500 mb-2">
              Огноо: {new Date(selected.ognoo).toLocaleDateString()}
            </p>
            <p className="whitespace-pre-line text-gray-700">{selected.tailbar}</p>

            <MedeeCommentSection medeeId={selected._id} />

            <div className="modal-action">
              <button className="btn" onClick={() => setSelected(null)}>
                Хаах
              </button>
            </div>
          </div>
        </dialog>
      )}
    </div>
  )
}
