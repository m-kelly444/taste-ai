import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import AestheticScorer from '../components/AestheticScorer';
import { trendsAPI } from '../utils/api';

const Dashboard = () => {
  const [trends, setTrends] = useState([]);
  const [stats, setStats] = useState({
    totalAnalyses: 1247,
    avgScore: 0.78,
    trendsDetected: 23,
    successRate: 0.89
  });

  useEffect(() => {
    const fetchTrends = async () => {
      try {
        const data = await trendsAPI.getCurrentTrends();
        setTrends(data.trends || []);
      } catch (error) {
        console.error('Failed to fetch trends:', error);
      }
    };

    fetchTrends();
  }, []);

  const StatCard = ({ title, value, change, icon, color }) => (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="card"
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="text-gray-400 text-sm">{title}</p>
          <p className="text-2xl font-bold text-white">{value}</p>
          {change && (
            <p className={`text-sm ${change > 0 ? 'text-green-400' : 'text-red-400'}`}>
              {change > 0 ? '↗' : '↘'} {Math.abs(change)}%
            </p>
          )}
        </div>
        <div className={`text-3xl ${color}`}>
          {icon}
        </div>
      </div>
    </motion.div>
  );

  const TrendCard = ({ trend, index }) => (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: index * 0.1 }}
      className="card"
    >
      <div className="flex items-center justify-between mb-3">
        <h4 className="font-semibold text-white">{trend.name}</h4>
        <span className={`px-2 py-1 rounded text-xs ${
          trend.momentum === 'rising' ? 'bg-green-900 text-green-300' :
          trend.momentum === 'stable' ? 'bg-blue-900 text-blue-300' :
          'bg-red-900 text-red-300'
        }`}>
          {trend.momentum}
        </span>
      </div>
      
      <div className="space-y-2">
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Score</span>
          <span className="text-white">{(trend.score * 100).toFixed(0)}%</span>
        </div>
        <div className="w-full bg-gray-700 rounded-full h-2">
          <div 
            className="bg-gradient-to-r from-blue-500 to-purple-500 h-2 rounded-full transition-all duration-500"
            style={{ width: `${trend.score * 100}%` }}
          ></div>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Category</span>
          <span className="text-white capitalize">{trend.category}</span>
        </div>
        <div className="flex justify-between text-sm">
          <span className="text-gray-400">Peak Est.</span>
          <span className="text-white">{trend.peak_estimate}</span>
        </div>
      </div>
    </motion.div>
  );

  return (
    <div className="min-h-screen bg-gray-900 p-6">
      <div className="max-w-7xl mx-auto">
        <div className="mb-8">
          <motion.h1 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl font-bold text-white mb-2"
          >
            Welcome back, Chris
          </motion.h1>
          <motion.p 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-gray-400 text-lg"
          >
            Your aesthetic intelligence dashboard
          </motion.p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            title="Total Analyses"
            value={stats.totalAnalyses.toLocaleString()}
            change={12}
            icon="🎯"
            color="text-blue-400"
          />
          <StatCard
            title="Avg Aesthetic Score"
            value={(stats.avgScore * 100).toFixed(1) + '%'}
            change={5}
            icon="⭐"
            color="text-yellow-400"
          />
          <StatCard
            title="Trends Detected"
            value={stats.trendsDetected}
            change={18}
            icon="📈"
            color="text-green-400"
          />
          <StatCard
            title="Success Rate"
            value={(stats.successRate * 100).toFixed(1) + '%'}
            change={3}
            icon="✓"
            color="text-purple-400"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2">
            <AestheticScorer />
          </div>

          <div className="space-y-6">
            <div>
              <h2 className="text-2xl font-bold text-white mb-4 flex items-center">
                <span className="mr-2">🔥</span>
                Current Trends
              </h2>
              <div className="space-y-4">
                {trends.map((trend, index) => (
                  <TrendCard key={trend.name} trend={trend} index={index} />
                ))}
              </div>
            </div>

            <div className="card">
              <h3 className="text-xl font-semibold text-white mb-4 flex items-center">
                <span className="mr-2">💡</span>
                Quick Insights
              </h3>
              <div className="space-y-3">
                <div className="p-3 bg-blue-900/30 rounded-lg border border-blue-800">
                  <p className="text-blue-300 text-sm">
                    <strong>Minimalist luxury</strong> is gaining momentum. Consider investing in brands with clean aesthetics.
                  </p>
                </div>
                <div className="p-3 bg-green-900/30 rounded-lg border border-green-800">
                  <p className="text-green-300 text-sm">
                    <strong>Earth tones</strong> showing stable performance. Perfect for Q2 launches.
                  </p>
                </div>
                <div className="p-3 bg-purple-900/30 rounded-lg border border-purple-800">
                  <p className="text-purple-300 text-sm">
                    <strong>Oversized silhouettes</strong> declining. Exit positions before Q3.
                  </p>
                </div>
              </div>
            </div>

            <div className="card">
              <h3 className="text-xl font-semibold text-white mb-4 flex items-center">
                <span className="mr-2">⚡</span>
                Quick Actions
              </h3>
              <div className="space-y-3">
                <button className="w-full btn-primary text-left">
                  <span className="mr-2">📊</span>
                  Analyze Portfolio Performance
                </button>
                <button className="w-full btn-secondary text-left">
                  <span className="mr-2">🔍</span>
                  Deep Trend Analysis
                </button>
                <button className="w-full btn-secondary text-left">
                  <span className="mr-2">📈</span>
                  Generate Report
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
