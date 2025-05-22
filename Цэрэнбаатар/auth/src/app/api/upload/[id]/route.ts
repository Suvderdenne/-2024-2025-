import { NextRequest, NextResponse } from 'next/server'
import { MongoClient, ObjectId } from 'mongodb'
import path from 'path'
import fs from 'fs/promises'

const uri = process.env.MONGO!

async function getCollection() {
  const client = await MongoClient.connect(uri)
  const db = client.db()
  const collection = db.collection('images')
  return { client, collection }
}

// ✅ DELETE - Remove image file and document
export async function DELETE(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const { client, collection } = await getCollection()

  const item = await collection.findOne({ _id: new ObjectId(id) })
  if (!item) {
    client.close()
    return NextResponse.json({ error: 'Image not found' }, { status: 404 })
  }

  const imagePath = path.join(process.cwd(), 'public', item.imageUrl)
  try {
    await fs.unlink(imagePath)
  } catch (e) {
    console.warn('⚠️ File delete error:', e)
  }

  await collection.deleteOne({ _id: new ObjectId(id) })
  client.close()

  return NextResponse.json({ success: true, message: 'Deleted' })
}

// ✅ PATCH - Edit name and phone
export async function PATCH(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const body = await req.json()

  const { client, collection } = await getCollection()

  const updateFields: any = {}
  if (body.name) updateFields.name = body.name
  if (body.phone) updateFields.phone = body.phone

  await collection.updateOne(
    { _id: new ObjectId(id) },
    { $set: { ...updateFields, updatedAt: new Date() } }
  )

  client.close()
  return NextResponse.json({ success: true, message: 'Updated successfully' })
}
