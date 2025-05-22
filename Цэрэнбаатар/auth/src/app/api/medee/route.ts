import { NextRequest, NextResponse } from 'next/server'
import path from 'path'
import fs from 'fs/promises'
import { MongoClient } from 'mongodb'

const uploadDir = path.join(process.cwd(), 'public', 'uploads')

async function saveFile(file: File) {
  const bytes = await file.arrayBuffer()
  const buffer = Buffer.from(bytes)
  const filename = Date.now() + '-' + file.name

  await fs.mkdir(uploadDir, { recursive: true })
  const filepath = path.join(uploadDir, filename)
  await fs.writeFile(filepath, buffer)

  return `/uploads/${filename}`
}

// POST - Add new Medee
export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('image') as File

  if (!file) {
    return NextResponse.json({ error: 'Image is required' }, { status: 400 })
  }

  const imageUrl = await saveFile(file)

  const data = {
    garchig: formData.get('garchig'),
    imgUrl: imageUrl,
    tailbar: formData.get('tailbar'),
    ognoo: new Date(), // default date
  }

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('medee')

  const result = await collection.insertOne(data)
  client.close()

  return NextResponse.json({ success: true, imgUrl: imageUrl, insertedId: result.insertedId })
}

// GET - All Medee
export async function GET() {
  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('medee')

  const medee = await collection.find().sort({ ognoo: -1 }).toArray()
  client.close()

  const cleaned = medee.map((item) => ({
    ...item,
    _id: item._id.toString(),
  }))

  return NextResponse.json(cleaned)
}
