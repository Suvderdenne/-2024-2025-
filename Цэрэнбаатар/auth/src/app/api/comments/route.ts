import { NextRequest, NextResponse } from 'next/server'
import { MongoClient, ObjectId } from 'mongodb'

export async function POST(req: NextRequest) {
  const body = await req.json()
  const { bairId, name, content } = body

  if (!bairId || !content) {
    return NextResponse.json({ error: 'Invalid input' }, { status: 400 })
  }

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const result = await db.collection('comments').insertOne({
    bairId: new ObjectId(bairId),
    name: name || 'Зочин',
    content,
    createdAt: new Date()
  })

  client.close()
  return NextResponse.json({ success: true, id: result.insertedId })
}

export async function GET(req: NextRequest) {
  const url = new URL(req.url)
  const bairId = url.searchParams.get('bairId')

  if (!bairId) return NextResponse.json([])

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const comments = await db
    .collection('comments')
    .find({ bairId: new ObjectId(bairId) })
    .sort({ createdAt: -1 })
    .toArray()

  client.close()
  return NextResponse.json(comments.map(c => ({
    ...c,
    _id: c._id.toString(),
    bairId: c.bairId.toString()
  })))
}
