import { NextRequest, NextResponse } from 'next/server'
import { MongoClient } from 'mongodb'

// ✅ POST
export async function POST(req: NextRequest) {
  const formData = await req.formData()

  const data = {
    baiguullaga: formData.get('baiguullaga'),
    projectNer: formData.get('projectNer'),
    bairshil: formData.get('bairshil'),
    ailToo: formData.get('ailToo'),
    ashiglaltOgnoo: formData.get('ashiglaltOgnoo'),
    uruuniSongolt: formData.get('uruuniSongolt'),
    uruuniHemjee: formData.get('uruuniHemjee'),
    une: formData.get('une'),
    createdAt: new Date(),
  }

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('uneKhansh')

  const result = await collection.insertOne(data)
  client.close()

  return NextResponse.json({ success: true, insertedId: result.insertedId })
}

// ✅ GET
export async function GET() {
  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('uneKhansh')

  const list = await collection.find().sort({ createdAt: -1 }).toArray()
  client.close()

  const cleaned = list.map((item) => ({
    ...item,
    _id: item._id.toString(),
  }))

  return NextResponse.json(cleaned)
}
