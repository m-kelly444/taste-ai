import React from 'react'

function App() {
  return (
    <div className="min-h-screen bg-gray-900 text-white flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4 bg-gradient-to-r from-blue-400 to-purple-600 bg-clip-text text-transparent">
          TASTE.AI
        </h1>
        <p className="text-xl text-gray-300">
          Aesthetic Intelligence Platform
        </p>
        <div className="mt-8 p-6 bg-gray-800 rounded-lg">
          <h2 className="text-2xl font-semibold mb-4">🎯 System Status</h2>
          <div className="space-y-2">
            <div className="flex justify-between">
              <span>Frontend:</span>
              <span className="text-green-400">✅ Online</span>
            </div>
            <div className="flex justify-between">
              <span>Backend:</span>
              <span className="text-green-400">✅ Connected</span>
            </div>
            <div className="flex justify-between">
              <span>ML Models:</span>
              <span className="text-green-400">✅ Loaded</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App
