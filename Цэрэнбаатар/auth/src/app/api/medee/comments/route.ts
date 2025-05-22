import { NextRequest, NextResponse } from 'next/server'
import { MongoClient, ObjectId } from 'mongodb'

export async function POST(req: NextRequest) {
  const { medeeId, name, content } = await req.json()

  if (!medeeId || !content) {
    return NextResponse.json({ error: 'Invalid input' }, { status: 400 })
  }

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const result = await db.collection('medee_comments').insertOne({
    medeeId: new ObjectId(medeeId),
    name: name || 'Зочин',
    content,
    createdAt: new Date()
  })

  client.close()
  return NextResponse.json({ success: true, id: result.insertedId })
}

export async function GET(req: NextRequest) {
  const url = new URL(req.url)
  const medeeId = url.searchParams.get('medeeId')

  if (!medeeId) return NextResponse.json([])

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const comments = await db
    .collection('medee_comments')
    .find({ medeeId: new ObjectId(medeeId) })
    .sort({ createdAt: -1 })
    .toArray()

  client.close()
  return NextResponse.json(comments.map((c) => ({
    ...c,
    _id: c._id.toString(),
    medeeId: c.medeeId.toString(),
  })))
}
