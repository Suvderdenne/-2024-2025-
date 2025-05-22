import { NextRequest, NextResponse } from 'next/server'
import { MongoClient, ObjectId } from 'mongodb'

const uri = process.env.MONGO!

async function getCollection() {
  const client = await MongoClient.connect(uri)
  const db = client.db()
  const collection = db.collection('uneKhansh')
  return { client, collection }
}

// ✅ PATCH — Засах
export async function PATCH(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const body = await req.json()

  const updateData = {
    baiguullaga: body.baiguullaga,
    projectNer: body.projectNer,
    bairshil: body.bairshil,
    ailToo: body.ailToo,
    ashiglaltOgnoo: body.ashiglaltOgnoo,
    uruuniSongolt: body.uruuniSongolt,
    uruuniHemjee: body.uruuniHemjee,
    une: body.une,
    updatedAt: new Date(),
  }

  const { client, collection } = await getCollection()

  await collection.updateOne(
    { _id: new ObjectId(id) },
    { $set: updateData }
  )

  client.close()
  return NextResponse.json({ success: true, message: 'Амжилттай засварлалаа' })
}

// ✅ DELETE — Устгах
export async function DELETE(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const { client, collection } = await getCollection()

  await collection.deleteOne({ _id: new ObjectId(id) })

  client.close()
  return NextResponse.json({ success: true, message: 'Амжилттай устгалаа' })
}
