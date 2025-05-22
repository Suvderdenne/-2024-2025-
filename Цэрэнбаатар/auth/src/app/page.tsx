'use client'

import { useEffect, useState } from 'react'
import CommentSection from '@/components/CommentSection'
import MedeeCommentSection from '@/components/MedeeCommentSection'

interface ShineBair {
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

interface OntslokhZar {
  _id: string
  imageUrl: string
  title: string
  tailbar: string
  phone: string
  bairshil: string
  mkb: string
  mkbune: string
  niitune: string
  dawkhar: string
  uruu: string
}

interface Medee {
  _id: string
  garchig: string
  imgUrl: string
  tailbar: string
  ognoo: string
}

export default function Home() {
  const [items, setItems] = useState<ShineBair[]>([])
  const [selected, setSelected] = useState<ShineBair | null>(null)
  const [featured, setFeatured] = useState<OntslokhZar[]>([])
  const [highlight, setHighlight] = useState<OntslokhZar | null>(null)
  const [medeenud, setMedeenuud] = useState<Medee[]>([])
  const [selectedMedee, setSelectedMedee] = useState<Medee | null>(null)

  useEffect(() => {
    fetch('/api/shinebair').then(res => res.json()).then(setItems)
    fetch('/api/bair').then(res => res.json()).then(data => setFeatured(data.slice(0, 6)))
    fetch('/api/medee').then(res => res.json()).then(data => setMedeenuud(data.slice(0, 6)))
  }, [])

  return (
    <div className="max-w-7xl mx-auto px-4 py-10 space-y-12">
      {/* Шинэ орон сууц */}
      <section>
        <h1 className="text-3xl font-bold text-center mb-6">🏢 Шинэ орон сууцууд</h1>

        <div className="carousel rounded-box w-full h-[400px] overflow-hidden mb-4">
          {items.slice(0, 4).map((item, index) => (
            <div key={item._id} id={`item${index}`} className="carousel-item w-full relative">
              <img src={item.imgUrl} className="object-cover w-full h-full rounded-xl shadow" />
              <button
                onClick={() => setSelected(item)}
                className="absolute bottom-4 right-4 bg-white/90 hover:bg-white text-gray-800 font-semibold px-4 py-2 rounded shadow"
              >
                Дэлгэрэнгүй
              </button>
            </div>
          ))}
        </div>

        <div className="flex justify-center gap-2">
          {items.slice(0, 4).map((_, index) => (
            <a key={index} href={`#item${index}`} className="btn btn-xs btn-outline">
              {index + 1}
            </a>
          ))}
        </div>
      </section>

      {/* Онцлох зарууд */}
      <section>
        <h1 className="text-3xl font-bold text-center mb-6">✨ Онцлох зарууд</h1>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {featured.map((item) => (
            <div key={item._id} className="card bg-base-100 shadow-xl hover:shadow-2xl transition-all duration-300">
              <figure>
                <img src={item.imageUrl} alt={item.title} className="w-full h-60 object-cover" />
              </figure>
              <div className="card-body">
                <h2 className="card-title">{item.title}</h2>
                <p className="text-sm">{item.bairshil}</p>
                <p className="text-sm font-medium text-primary">{item.niitune}₮ — {item.mkb}м²</p>
                <div className="card-actions justify-end">
                  <button className="btn btn-primary btn-sm" onClick={() => setHighlight(item)}>Дэлгэрэнгүй</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Онцлох мэдээнүүд */}
      <section>
        <h1 className="text-3xl font-bold text-center mb-6">📰 Онцлох мэдээнүүд</h1>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {medeenud.map((item) => (
            <div key={item._id} className="card bg-base-100 shadow-xl hover:shadow-2xl transition-all">
              <figure>
                <img src={item.imgUrl} alt={item.garchig} className="w-full h-60 object-cover" />
              </figure>
              <div className="card-body">
                <h2 className="card-title">{item.garchig}</h2>
                <div className="card-actions justify-end">
                  <button className="btn btn-primary btn-sm" onClick={() => setSelectedMedee(item)}>Дэлгэрэнгүй</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Модал: Шинэ орон сууц */}
      {selected && (
        <dialog open className="modal">
          <div className="modal-box max-w-xl">
            <h3 className="text-lg font-bold">{selected.title}</h3>
            <img src={selected.imgUrl} className="w-full rounded my-2 object-contain max-h-[400px]" />
            <div className="text-sm space-y-1">
              <p><strong>Үнэ:</strong> {selected.une}</p>
              <p><strong>Компани:</strong> {selected.company}</p>
              <p><strong>Утас:</strong> {selected.phone}</p>
              <p><strong>Хугацаа:</strong> {selected.khugatsaa}</p>
              <p><strong>Төрөл:</strong> {selected.turul}</p>
              <p><strong>Ангилал:</strong> {selected.angilal}</p>
              <p><strong>Хийц:</strong> {selected.khiits}</p>
              <p className="pt-2 whitespace-pre-line">{selected.tailbar}</p>
            </div>
            <div className="modal-action">
              <button className="btn" onClick={() => setSelected(null)}>Хаах</button>
            </div>
          </div>
        </dialog>
      )}

      {/* Модал: Онцлох зар */}
      {highlight && (
        <dialog open className="modal">
          <div className="modal-box max-w-2xl">
            <h3 className="text-lg font-bold">{highlight.title}</h3>
            <img src={highlight.imageUrl} className="w-full rounded my-2 object-contain max-h-[400px]" />
            <div className="text-sm space-y-1">
              <p><strong>Байршил:</strong> {highlight.bairshil}</p>
              <p><strong>Нийт үнэ:</strong> {highlight.niitune}₮</p>
              <p><strong>1м² үнэ:</strong> {highlight.mkbune}₮</p>
              <p><strong>Мкв хэмжээ:</strong> {highlight.mkb}м²</p>
              <p><strong>Өрөө:</strong> {highlight.uruu}</p>
              <p><strong>Давхар:</strong> {highlight.dawkhar}</p>
              <p><strong>Утас:</strong> {highlight.phone}</p>
              <p className="pt-2 whitespace-pre-line">{highlight.tailbar}</p>
            </div>
            <div className="mt-4">
              <h4 className="font-semibold mb-2">Сэтгэгдэл</h4>
              <CommentSection bairId={highlight._id} />
            </div>
            <div className="modal-action">
              <button className="btn" onClick={() => setHighlight(null)}>Хаах</button>
            </div>
          </div>
        </dialog>
      )}

      {/* Модал: Мэдээ */}
      {selectedMedee && (
        <dialog open className="modal">
          <div className="modal-box max-w-2xl">
            <h3 className="text-lg font-bold">{selectedMedee.garchig}</h3>
            <img src={selectedMedee.imgUrl} className="w-full rounded my-2 object-contain max-h-[400px]" />
            <p className="text-sm whitespace-pre-line">{selectedMedee.tailbar}</p>
            <div className="mt-4">
              <MedeeCommentSection medeeId={selectedMedee._id} />
            </div>
            <div className="modal-action">
              <button className="btn" onClick={() => setSelectedMedee(null)}>Хаах</button>
            </div>
          </div>
        </dialog>
      )}
    </div>
  )
}
