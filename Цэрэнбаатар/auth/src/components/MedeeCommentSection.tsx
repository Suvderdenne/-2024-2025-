'use client'

import { useEffect, useState } from 'react'

export default function MedeeCommentSection({ medeeId }: { medeeId: string }) {
  const [comments, setComments] = useState<any[]>([])
  const [name, setName] = useState('')
  const [content, setContent] = useState('')

  useEffect(() => {
    fetch(`/api/medee/comments?medeeId=${medeeId}`)
      .then(res => res.json())
      .then(setComments)
  }, [medeeId])

  const submitComment = async () => {
    if (!content.trim()) return
    const res = await fetch('/api/medee/comments', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ medeeId, name, content })
    })
    const result = await res.json()
    if (result.success) {
      setComments([{ name, content, createdAt: new Date().toISOString() }, ...comments])
      setContent('')
    }
  }

  return (
    <div className="mt-6">
      <h4 className="text-lg font-semibold mb-2">Сэтгэгдэл</h4>

      <div className="space-y-3 mb-4">
        {comments.map((c, i) => (
          <div key={i} className="bg-gray-100 p-3 rounded">
            <p className="text-sm text-gray-500">
              {c.name || 'Зочин'} - {new Date(c.createdAt).toLocaleString()}
            </p>
            <p>{c.content}</p>
          </div>
        ))}
      </div>

      <p className='font-bold'>Нэр:</p>
      <input
        className="input input-bordered w-full mb-2 border-accent"
        placeholder="Нэр (заавал биш)"
        value={name}
        onChange={(e) => setName(e.target.value)}
      />
      <p className='font-bold'>Сэтгэгдэл:</p>
      <textarea
        className="textarea textarea-bordered w-full mb-2"
        rows={3}
        placeholder="Сэтгэгдэл бичих..."
        value={content}
        onChange={(e) => setContent(e.target.value)}
      />
      <button className="btn btn-primary" onClick={submitComment}>Нэмэх</button>
    </div>
  )
}
