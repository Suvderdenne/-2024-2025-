import { NextRequest, NextResponse } from 'next/server'
import path from 'path'
import fs from 'fs/promises'
import { MongoClient, ObjectId } from 'mongodb'

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

export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('image') as File

  if (!file) {
    return NextResponse.json({ error: 'Image is required' }, { status: 400 })
  }

  const imageUrl = await saveFile(file)

  const data = {
    imageUrl,
    title: formData.get('title'),
    duureg: formData.get('duureg'),
    khoroo: formData.get('khoroo'),
    nukhtsul: formData.get('nukhtsul'),
    turul: formData.get('turul'),
    mkb: formData.get('mkb'),
    mkbune: formData.get('mkbune'),
    niitune: formData.get('niitune'),
    niitelsenognoo: formData.get('niitelsenognoo'),
    bairshil: formData.get('bairshil'),
    phone: formData.get('phone'),
    dawkhar: formData.get('dawkhar'),
    uruu: formData.get('uruu'),
    tailbar: formData.get('tailbar'),
    createdAt: new Date(),
  }

  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('bairuud')

  const result = await collection.insertOne(data)
  client.close()

  return NextResponse.json({ success: true, imageUrl, insertedId: result.insertedId })
}

export async function GET() {
  const client = await MongoClient.connect(process.env.MONGO!)
  const db = client.db()
  const collection = db.collection('bairuud')

  const bairuud = await collection.find().sort({ createdAt: -1 }).toArray()
  client.close()

  // Convert _id to string for React key
  const cleaned = bairuud.map((item) => ({
    ...item,
    _id: item._id.toString(),
  }))

  return NextResponse.json(cleaned)
}
