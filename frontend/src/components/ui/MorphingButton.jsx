import React, { useState } from 'react';
import { motion } from 'framer-motion';

const MorphingButton = ({ 
  children, 
  onClick, 
  variant = 'primary', 
  className = '',
  icon: Icon,
  loadingText = 'Processing...',
  isLoading = false 
}) => {
  const [isHovered, setIsHovered] = useState(false);

  const variants = {
    primary: {
      base: 'bg-gradient-to-r from-blue-600 to-purple-600',
      hover: 'from-purple-600 to-pink-600',
      text: 'text-white'
    },
    secondary: {
      base: 'bg-gray-800 border-2 border-gray-600',
      hover: 'border-blue-500',
      text: 'text-gray-300'
    },
    danger: {
      base: 'bg-gradient-to-r from-red-600 to-pink-600',
      hover: 'from-pink-600 to-red-600',
      text: 'text-white'
    }
  };

  const currentVariant = variants[variant];

  return (
    <motion.button
      className={`
        relative overflow-hidden px-8 py-4 rounded-full font-semibold
        transition-all duration-300 transform-gpu
        ${currentVariant.text} ${className}
      `}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
      onHoverStart={() => setIsHovered(true)}
      onHoverEnd={() => setIsHovered(false)}
      onClick={onClick}
      disabled={isLoading}
    >
      {/* Base Background */}
      <div className={`absolute inset-0 ${currentVariant.base}`} />
      
      {/* Hover Background */}
      <motion.div
        className={`absolute inset-0 ${currentVariant.hover}`}
        initial={{ x: '-100%' }}
        animate={{ x: isHovered ? '0%' : '-100%' }}
        transition={{ duration: 0.3, ease: 'easeInOut' }}
      />

      {/* Shimmer Effect */}
      <motion.div
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-20"
        style={{ width: '100%', height: '100%' }}
        animate={{ x: ['-100%', '100%'] }}
        transition={{ 
          duration: 2, 
          repeat: Infinity, 
          repeatDelay: 3,
          ease: 'easeInOut' 
        }}
      />

      {/* Content */}
      <span className="relative z-10 flex items-center justify-center space-x-2">
        {isLoading ? (
          <>
            <motion.div
              className="w-5 h-5 border-2 border-current border-t-transparent rounded-full"
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
            />
            <span>{loadingText}</span>
          </>
        ) : (
          <>
            {Icon && (
              <motion.div
                animate={{ 
                  scale: isHovered ? 1.1 : 1,
                  rotate: isHovered ? 10 : 0 
                }}
                transition={{ duration: 0.2 }}
              >
                <Icon className="w-5 h-5" />
              </motion.div>
            )}
            <span>{children}</span>
          </>
        )}
      </span>

      {/* Pulse Effect on Click */}
      <motion.div
        className="absolute inset-0 bg-white rounded-full"
        initial={{ scale: 0, opacity: 0.5 }}
        animate={{ scale: 0, opacity: 0.5 }}
        whileTap={{ scale: 2, opacity: 0 }}
        transition={{ duration: 0.4 }}
      />
    </motion.button>
  );
};

export default MorphingButton;
