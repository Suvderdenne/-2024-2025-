import { NextRequest, NextResponse } from 'next/server'
import { MongoClient, ObjectId } from 'mongodb'
import path from 'path'
import fs from 'fs/promises'

const uri = process.env.MONGO!
const uploadDir = path.join(process.cwd(), 'public')

async function getCollection() {
  const client = await MongoClient.connect(uri)
  const db = client.db()
  const collection = db.collection('shinebair')
  return { client, collection }
}

// ✅ DELETE - remove document and image file
export async function DELETE(
  req: NextRequest,
  context: { params: { id?: string } }
) {
  const id = context.params?.id
  if (!id) {
    return NextResponse.json({ error: 'Missing ID' }, { status: 400 })
  }

  const { client, collection } = await getCollection()
  const doc = await collection.findOne({ _id: new ObjectId(id) })

  if (!doc) {
    client.close()
    return NextResponse.json({ error: 'Item not found' }, { status: 404 })
  }

  // Delete file from /public if imgUrl exists
  if (doc.imgUrl) {
    const filePath = path.join(uploadDir, doc.imgUrl)
    try {
      await fs.unlink(filePath)
    } catch (e) {
      console.warn('⚠️ Image deletion failed or not found:', e)
    }
  }

  await collection.deleteOne({ _id: new ObjectId(id) })
  client.close()

  return NextResponse.json({ success: true, message: 'Deleted' })
}

// ✅ PATCH - update shinebair fields
export async function PATCH(
  req: NextRequest,
  context: { params: { id?: string } }
) {
  const id = context.params?.id
  if (!id) {
    return NextResponse.json({ error: 'Missing ID' }, { status: 400 })
  }

  const updateData = await req.json()
  const allowedFields = [
    'title',
    'une',
    'company',
    'phone',
    'khugatsaa',
    'angilal',
    'khiits',
    'turul',
    'tailbar',
  ]

  const updateFields: any = {}
  for (const field of allowedFields) {
    if (updateData[field] !== undefined) {
      updateFields[field] = updateData[field]
    }
  }
  updateFields.updatedAt = new Date()

  const { client, collection } = await getCollection()
  await collection.updateOne(
    { _id: new ObjectId(id) },
    { $set: updateFields }
  )
  client.close()

  return NextResponse.json({ success: true, message: 'Updated' })
}
