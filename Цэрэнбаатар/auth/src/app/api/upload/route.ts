import { NextRequest, NextResponse } from 'next/server'
import path from 'path'
import fs from 'fs/promises'
import { MongoClient } from 'mongodb'

// File saving function
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

// POST - Save uploaded file + metadata
export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('image') as File
  const name = formData.get('name') as string
  const phone = formData.get('phone') as string

  if (!file || !name || !phone) {
    return NextResponse.json({ error: 'Missing fields' }, { status: 400 })
  }

  const imageUrl = await saveFile(file)

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('images')

  const result = await collection.insertOne({
    originalname: file.name,
    imageUrl,
    name,
    phone,
    createdAt: new Date(),
  })

  client.close()

  return NextResponse.json({ success: true, imageUrl })
}

// ✅ GET - Return list of uploaded items
export async function GET(req: NextRequest) {
  try {
    const client = await MongoClient.connect(process.env.MONGO!)
    const db = client.db()
    const collection = db.collection('images')

    const items = await collection.find().sort({ createdAt: -1 }).toArray()
    client.close()

    return NextResponse.json(items)
  } catch (err) {
    console.error('Fetch error:', err)
    return NextResponse.json({ error: 'Server error' }, { status: 500 })
  }
}
