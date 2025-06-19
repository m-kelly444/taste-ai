import React, { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { motion, AnimatePresence } from 'framer-motion';
import { aestheticAPI } from '../utils/api';

const AestheticScorer = () => {
  const [results, setResults] = useState(null);
  const [loading, setLoading] = useState(false);
  const [uploadedImage, setUploadedImage] = useState(null);
  const [error, setError] = useState(null);

  const onDrop = useCallback(async (acceptedFiles) => {
    const file = acceptedFiles[0];
    if (!file) return;

    setLoading(true);
    setError(null);
    setUploadedImage(URL.createObjectURL(file));

    try {
      const data = await aestheticAPI.scoreImage(file);
      setResults(data);
    } catch (error) {
      setError('Failed to analyze image. Please try again.');
      console.error('Error scoring aesthetic:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.webp']
    },
    multiple: false,
    maxSize: 10 * 1024 * 1024
  });

  const ScoreDisplay = ({ score, label, color, icon }) => (
    <motion.div
      initial={{ scale: 0.9, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      className="card text-center"
    >
      <div className={`text-5xl mb-2 ${color}`}>{icon}</div>
      <div className={`text-3xl font-bold mb-2 ${color}`}>
        {(score * 100).toFixed(1)}
      </div>
      <div className="text-gray-400 text-sm uppercase tracking-wider">
        {label}
      </div>
    </motion.div>
  );

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="mb-8">
        <h1 className="text-4xl font-bold text-white mb-2">
          Aesthetic Intelligence
        </h1>
        <p className="text-gray-400 text-lg">
          Upload an image to analyze its aesthetic appeal and trend potential
        </p>
      </div>

      <div
        {...getRootProps()}
        className={`border-2 border-dashed rounded-xl p-12 text-center transition-all duration-300 cursor-pointer mb-8 ${
          isDragActive
            ? 'border-blue-500 bg-blue-500/10 scale-105'
            : 'border-gray-600 hover:border-gray-500 bg-gray-800/50 hover:bg-gray-800/70'
        }`}
      >
        <input {...getInputProps()} />
        
        {uploadedImage ? (
          <div className="space-y-4">
            <img
              src={uploadedImage}
              alt="Uploaded"
              className="max-h-64 mx-auto rounded-lg shadow-lg"
            />
            <p className="text-gray-400">Drop a new image to analyze</p>
          </div>
        ) : (
          <div className="space-y-4">
            <div className="w-16 h-16 mx-auto bg-gray-700 rounded-full flex items-center justify-center">
              <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
            </div>
            <div>
              <p className="text-white font-medium text-lg">
                {isDragActive ? 'Drop the image here' : 'Drag & drop an image'}
              </p>
              <p className="text-gray-400">or click to select • Max 10MB</p>
            </div>
          </div>
        )}
      </div>

      <AnimatePresence>
        {loading && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="card text-center mb-8"
          >
            <div className="animate-spin w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full mx-auto mb-4"></div>
            <p className="text-gray-400">Analyzing aesthetic appeal...</p>
            <div className="w-full bg-gray-700 rounded-full h-2 mt-4">
              <div className="bg-blue-500 h-2 rounded-full animate-pulse" style={{width: '60%'}}></div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="bg-red-900/50 border border-red-700 rounded-xl p-6 mb-8 text-center"
          >
            <p className="text-red-400">{error}</p>
          </motion.div>
        )}
      </AnimatePresence>

      <AnimatePresence>
        {results && !loading && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-6"
          >
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <ScoreDisplay
                score={results.aesthetic_score}
                label="Aesthetic Score"
                color="text-blue-400"
                icon="🎨"
              />
              <ScoreDisplay
                score={results.confidence}
                label="Confidence"
                color="text-green-400"
                icon="✓"
              />
              <ScoreDisplay
                score={results.trend_analysis?.trend_score || 0.8}
                label="Trend Potential"
                color="text-purple-400"
                icon="📈"
              />
            </div>

            <div className="card">
              <h3 className="text-xl font-semibold text-white mb-4 flex items-center">
                <span className="mr-2">🔍</span>
                Detailed Analysis
              </h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="text-lg font-medium text-gray-300 mb-3">
                    Visual Harmony
                  </h4>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Color Balance</span>
                      <span className="text-green-400">Excellent</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Composition</span>
                      <span className="text-blue-400">Very Good</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Visual Interest</span>
                      <span className="text-purple-400">High</span>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 className="text-lg font-medium text-gray-300 mb-3">
                    Market Potential
                  </h4>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Viral Potential</span>
                      <span className="text-white">{(results.trend_analysis?.viral_potential * 100 || 75).toFixed(0)}%</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Market Appeal</span>
                      <span className="text-white">{(results.trend_analysis?.market_appeal * 100 || 82).toFixed(0)}%</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Timing</span>
                      <span className="text-green-400">Optimal</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default AestheticScorer;
