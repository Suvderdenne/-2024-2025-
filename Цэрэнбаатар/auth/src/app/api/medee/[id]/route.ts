import { NextRequest, NextResponse } from 'next/server'
import { MongoClient, ObjectId } from 'mongodb'
import path from 'path'
import fs from 'fs/promises'

const uri = process.env.MONGO!
const uploadDir = path.join(process.cwd(), 'public', 'uploads')

async function getCollection() {
  const client = await MongoClient.connect(uri)
  const db = client.db()
  const collection = db.collection('medee')
  return { client, collection }
}

async function saveFile(file: File) {
  const bytes = await file.arrayBuffer()
  const buffer = Buffer.from(bytes)
  const filename = Date.now() + '-' + file.name
  await fs.mkdir(uploadDir, { recursive: true })
  const filepath = path.join(uploadDir, filename)
  await fs.writeFile(filepath, buffer)
  return `/uploads/${filename}`
}

// ✅ GET
export async function GET(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const { client, collection } = await getCollection()
  const medee = await collection.findOne({ _id: new ObjectId(id) })
  client.close()

  if (!medee) {
    return NextResponse.json({ error: 'Мэдээ олдсонгүй' }, { status: 404 })
  }

  return NextResponse.json({ ...medee, _id: medee._id.toString() })
}

// ✅ DELETE
export async function DELETE(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const { client, collection } = await getCollection()
  await collection.deleteOne({ _id: new ObjectId(id) })
  client.close()
  return NextResponse.json({ message: 'Амжилттай устгалаа' })
}

// ✅ PATCH (Засварлах)
export async function PATCH(req: NextRequest, context: { params: { id: string } }) {
  const id = context.params.id
  const formData = await req.formData()
  const garchig = formData.get('garchig') as string
  const tailbar = formData.get('tailbar') as string
  const ognoo = formData.get('ognoo') as string
  const image = formData.get('image') as File | null

  const { client, collection } = await getCollection()

  const updateData: any = { garchig, tailbar, ognoo }

  if (image && image.name) {
    const imgUrl = await saveFile(image)
    updateData.imgUrl = imgUrl
  }

  await collection.updateOne({ _id: new ObjectId(id) }, { $set: updateData })

  client.close()
  return NextResponse.json({ message: 'Амжилттай шинэчиллээ' })
}
