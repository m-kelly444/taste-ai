import React, { useState } from 'react';

const Dashboard = () => {
  const [message, setMessage] = useState('Welcome to TASTE.AI');

  const testAPI = async () => {
    try {
      const response = await fetch('/api/v1/trends/current');
      const data = await response.json();
      setMessage(`API Working! Found ${data.trends?.length || 0} trends`);
    } catch (error) {
      setMessage('API Error: ' + error.message);
    }
  };

  return (
    <div className="min-h-screen bg-gray-900 p-6">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-white mb-4">
          TASTE.AI Dashboard
        </h1>
        <p className="text-gray-400 mb-8">
          Aesthetic Intelligence Platform
        </p>
        
        <div className="bg-gray-800 rounded-lg p-6 mb-6">
          <h2 className="text-xl font-semibold text-white mb-4">Status</h2>
          <p className="text-green-400">{message}</p>
          <button 
            onClick={testAPI}
            className="mt-4 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded"
          >
            Test API Connection
          </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-gray-800 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-white mb-2">
              Aesthetic Analysis
            </h3>
            <p className="text-gray-400">
              Upload images for AI-powered aesthetic scoring
            </p>
          </div>
          
          <div className="bg-gray-800 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-white mb-2">
              Trend Prediction
            </h3>
            <p className="text-gray-400">
              Analyze market trends and predict future directions
            </p>
          </div>
          
          <div className="bg-gray-800 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-white mb-2">
              Burch Insights
            </h3>
            <p className="text-gray-400">
              Specialized analysis for Chris Burch's aesthetic preferences
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
