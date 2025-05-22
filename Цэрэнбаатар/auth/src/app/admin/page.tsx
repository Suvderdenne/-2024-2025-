'use client'

import { useState } from 'react'
import Link from 'next/link'
import ImageTable from '@/components/ImageTable'
import ShineBairManager from '@/components/ShineBairManager'
import UneKhanshTable from '@/components/UneKhanshTable'
import MedeeManager from '@/components/MedeeManager'
import KhanshManager from '@/components/KhanshManager'
import ImageManager from '@/components/ImageManager'

export default function AdminPanel() {
  const [active, setActive] = useState<string | null>(null)
  const [pinInput, setPinInput] = useState('')
  const [verifiedTabs, setVerifiedTabs] = useState<string[]>([])
  const [pendingTab, setPendingTab] = useState<string | null>(null)

  const navItems = [
    { name: 'Мэдээ' },
    { name: 'Үнэ ханш' },
    { name: 'Агентууд' },
    { name: 'Шинэ байр' },
  ]

  const verifyPin = () => {
    if (pinInput === '1234' && pendingTab) {
      setVerifiedTabs([...verifiedTabs, pendingTab])
      setActive(pendingTab)
      setPendingTab(null)
      setPinInput('')
    } else {
      alert('Буруу PIN код!')
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 text-gray-800">
      {/* Header */}
      <header className="bg-white shadow px-6 py-4 flex justify-between items-center">
        <h1 className="text-2xl font-bold">🔒 Secure Admin</h1>
        <div className="flex items-center gap-6">
          {navItems.map(({ name }) => (
            <button
              key={name}
              onClick={() => {
                if (verifiedTabs.includes(name)) {
                  setActive(name)
                } else {
                  setPendingTab(name)
                }
              }}
              className={`flex items-center gap-2 px-3 py-1 rounded hover:bg-gray-100 ${
                active === name ? 'text-green-600 font-semibold' : 'text-gray-600'
              }`}
            >
              {name}
            </button>
          ))}
        </div>
      </header>

      {/* PIN Dialog */}
      {pendingTab && (
        <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-lg w-full max-w-md">
            <h2 className="text-lg font-bold mb-4">PIN оруулна уу</h2>
            <input
              type="password"
              className="w-full border px-3 py-2 rounded mb-4"
              placeholder="1234"
              value={pinInput}
              onChange={(e) => setPinInput(e.target.value)}
            />
            <div className="flex justify-end gap-2">
              <button
                className="bg-gray-200 px-4 py-2 rounded"
                onClick={() => {
                  setPendingTab(null)
                  setPinInput('')
                }}
              >
                Болих
              </button>
              <button
                className="bg-blue-600 text-white px-4 py-2 rounded"
                onClick={verifyPin}
              >
                Батлах
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Main content */}
      <main className="p-6">
        <h2 className="text-xl font-semibold mb-4 text-center">
          {active || 'ЭНЭХҮҮ ХУУДСАНД АДМИН ЭРХТЭЙ ХҮМҮҮС ХАНДАХ ЭРХТЭЙГ АНХААРНА УУ!!!'}
        </h2>

        {active === 'Мэдээ' && (
          <div className="bg-white p-4 rounded-xl shadow">
            <MedeeManager />
          </div>
        )}

        {active === 'Үнэ ханш' && (
          <div className="bg-white p-4 rounded-xl shadow">
            <Link href="/add-unekhansh">
              <button className="bg-blue-600 text-white px-4 py-2 rounded mb-6 hover:bg-blue-700">
                ➕ Нэмэх
              </button>
            </Link>
            <KhanshManager />
          </div>
        )}

        {active === 'Агентууд' && (
          <div className="bg-white p-4 rounded-xl shadow">
            <Link href="/upload">
              <button className="bg-blue-600 text-white px-4 py-2 rounded mb-6 hover:bg-blue-700">
                ➕ Нэмэх
              </button>
            </Link>
            <ImageManager />
          </div>
        )}

        {active === 'Шинэ байр' && (
          <div className="bg-white p-4 rounded-xl shadow">
            <Link href="/addBair">
              <button className="bg-blue-600 text-white px-4 py-2 rounded mb-6 hover:bg-blue-700">
                ➕ Нэмэх
              </button>
            </Link>
            <ShineBairManager />
          </div>
        )}
      </main>
    </div>
  )
}
