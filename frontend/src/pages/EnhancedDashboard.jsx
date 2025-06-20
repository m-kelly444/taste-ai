import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import LandingHero from '../components/enhanced/LandingHero';
import GlassCard from '../components/ui/GlassCard';
import MorphingButton from '../components/ui/MorphingButton';
import AestheticScorer from '../components/AestheticScorer';
import { trendsAPI } from '../utils/api';
import { useScrollAnimation } from '../hooks/useScrollAnimation';

const EnhancedDashboard = () => {
  const [showHero, setShowHero] = useState(true);
  const [trends, setTrends] = useState([]);
  const [contentRef, isContentVisible] = useScrollAnimation(0.1);

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

  const handleEnterApp = () => {
    setShowHero(false);
  };

  if (showHero) {
    return (
      <div>
        <LandingHero />
        <div className="fixed bottom-8 right-8 z-50">
          <MorphingButton
            onClick={handleEnterApp}
            variant="primary"
            className="cyber-glow"
          >
            Enter Dashboard
          </MorphingButton>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-purple-900 relative overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0 matrix-rain opacity-20" />
      
      {/* Floating Particles */}
      <div className="particles">
        {Array.from({ length: 20 }).map((_, i) => (
          <div
            key={i}
            className="particle"
            style={{
              left: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 10}s`,
              width: `${Math.random() * 4 + 2}px`,
              height: `${Math.random() * 4 + 2}px`,
            }}
          />
        ))}
      </div>

      <div className="relative z-10 p-6" ref={contentRef}>
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={isContentVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 50 }}
          transition={{ duration: 0.8 }}
          className="max-w-7xl mx-auto"
        >
          {/* Header */}
          <div className="mb-12 text-center">
            <h1 className="text-6xl font-bold mb-4 holographic-text">
              Welcome back, Chris
            </h1>
            <p className="text-xl text-gray-300">
              Your aesthetic intelligence command center
            </p>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-12">
            {[
              { label: "Total Analyses", value: "2,847", change: "+12%", icon: "🎯" },
              { label: "Avg Score", value: "78.4%", change: "+5%", icon: "⭐" },
              { label: "Trends Detected", value: "23", change: "+18%", icon: "📈" },
              { label: "Success Rate", value: "89.2%", change: "+3%", icon: "✓" }
            ].map((stat, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 30 }}
                animate={isContentVisible ? { opacity: 1, y: 0 } : { opacity: 0, y: 30 }}
                transition={{ delay: index * 0.1, duration: 0.6 }}
              >
                <GlassCard hover glow className="text-center transform-3d">
                  <div className="text-4xl mb-2">{stat.icon}</div>
                  <div className="text-3xl font-bold text-white mb-1">
                    {stat.value}
                  </div>
                  <div className="text-gray-400 text-sm mb-2">
                    {stat.label}
                  </div>
                  <div className="text-green-400 text-sm">
                    {stat.change}
                  </div>
                </GlassCard>
              </motion.div>
            ))}
          </div>

          {/* Main Content Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Aesthetic Scorer */}
            <div className="lg:col-span-2">
              <GlassCard animation="scale" className="h-full">
                <AestheticScorer />
              </GlassCard>
            </div>

            {/* Sidebar */}
            <div className="space-y-6">
              {/* Trends */}
              <GlassCard animation="slide" glow>
                <h3 className="text-xl font-bold text-white mb-4 flex items-center">
                  <span className="mr-2">🔥</span>
                  Trending Now
                </h3>
                <div className="space-y-3">
                  {trends.slice(0, 3).map((trend, index) => (
                    <motion.div
                      key={index}
                      className="p-3 bg-white/5 rounded-lg border border-white/10"
                      whileHover={{ scale: 1.02 }}
                    >
                      <div className="flex justify-between items-center">
                        <span className="text-white font-medium">
                          {trend.name}
                        </span>
                        <span className="text-blue-400">
                          {(trend.score * 100).toFixed(0)}%
                        </span>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </GlassCard>

              {/* Quick Actions */}
              <GlassCard animation="fade">
                <h3 className="text-xl font-bold text-white mb-4">
                  ⚡ Quick Actions
                </h3>
                <div className="space-y-3">
                  <MorphingButton variant="primary" className="w-full">
                    📊 Portfolio Analysis
                  </MorphingButton>
                  <MorphingButton variant="secondary" className="w-full">
                    🔍 Deep Trend Scan
                  </MorphingButton>
                  <MorphingButton variant="secondary" className="w-full">
                    📈 Generate Report
                  </MorphingButton>
                </div>
              </GlassCard>

              {/* AI Insights */}
              <GlassCard animation="scale" className="cyber-glow">
                <h3 className="text-xl font-bold text-white mb-4">
                  🤖 AI Insights
                </h3>
                <div className="space-y-3">
                  <div className="p-3 bg-blue-500/20 rounded-lg border border-blue-500/30">
                    <p className="text-blue-300 text-sm">
                      <strong>Quiet luxury</strong> trend showing 94% correlation 
                      with your aesthetic preferences
                    </p>
                  </div>
                  <div className="p-3 bg-green-500/20 rounded-lg border border-green-500/30">
                    <p className="text-green-300 text-sm">
                      Optimal investment window detected for 
                      <strong> sustainable materials</strong>
                    </p>
                  </div>
                </div>
              </GlassCard>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default EnhancedDashboard;
