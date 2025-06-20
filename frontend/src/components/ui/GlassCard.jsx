import React from 'react';
import { motion } from 'framer-motion';

const GlassCard = ({ 
  children, 
  className = '', 
  hover = true, 
  glow = false,
  animation = 'slide' 
}) => {
  const animations = {
    slide: {
      initial: { opacity: 0, y: 50 },
      animate: { opacity: 1, y: 0 },
      transition: { duration: 0.6, ease: 'easeOut' }
    },
    fade: {
      initial: { opacity: 0 },
      animate: { opacity: 1 },
      transition: { duration: 0.8 }
    },
    scale: {
      initial: { opacity: 0, scale: 0.8 },
      animate: { opacity: 1, scale: 1 },
      transition: { duration: 0.5, ease: 'easeOut' }
    }
  };

  const currentAnimation = animations[animation];

  return (
    <motion.div
      className={`
        relative backdrop-blur-xl bg-white/10 
        border border-white/20 rounded-2xl p-6
        shadow-xl shadow-black/20
        ${hover ? 'hover:bg-white/15 hover:border-white/30' : ''}
        ${glow ? 'hover:shadow-2xl hover:shadow-blue-500/20' : ''}
        transition-all duration-500
        ${className}
      `}
      initial={currentAnimation.initial}
      animate={currentAnimation.animate}
      transition={currentAnimation.transition}
      whileHover={hover ? { 
        y: -5,
        transition: { duration: 0.2 }
      } : {}}
    >
      {/* Gradient Overlay */}
      <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent rounded-2xl pointer-events-none" />
      
      {/* Content */}
      <div className="relative z-10">
        {children}
      </div>

      {/* Animated Border */}
      <motion.div
        className="absolute inset-0 rounded-2xl pointer-events-none"
        style={{
          background: 'linear-gradient(45deg, transparent, rgba(59, 130, 246, 0.5), transparent)',
          backgroundSize: '200% 200%'
        }}
        animate={{
          backgroundPosition: ['0% 0%', '100% 100%', '0% 0%']
        }}
        transition={{
          duration: 3,
          repeat: Infinity,
          ease: 'linear'
        }}
      />
    </motion.div>
  );
};

export default GlassCard;
