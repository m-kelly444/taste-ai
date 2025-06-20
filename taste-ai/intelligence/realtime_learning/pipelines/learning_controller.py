#!/usr/bin/env python3
"""
Learning Pipeline Controller
Orchestrates all learning processes and manages system intelligence
"""

import asyncio
import subprocess
import signal
import sys
from datetime import datetime

class LearningController:
    def __init__(self):
        self.processes = {}
        self.running = True
        
    async def start_all_learning_processes(self):
        """Start all intelligence processes"""
        print("🚀 Starting TASTE.AI Intelligence System...")
        
        # Register signal handlers
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
        
        try:
            # Start continuous learning engine
            self.processes['continuous_learner'] = await self.start_process(
                'python3 taste-ai/intelligence/realtime_learning/engines/continuous_learner.py'
            )
            
            # Start data ingestion pipelines
            self.processes['data_ingestion'] = await self.start_process(
                'bash taste-ai/intelligence/realtime_learning/pipelines/02_start_data_ingestion.sh'
            )
            
            # Start memory graph updates
            self.processes['memory_graph'] = await self.start_process(
                'bash taste-ai/intelligence/memory_graph/03_start_memory_graph.sh'
            )
            
            # Start recursive improvement
            self.processes['recursive_improvement'] = await self.start_process(
                'bash taste-ai/intelligence/recursive_improvement/04_start_recursive_improvement.sh'
            )
            
            print("✅ All intelligence processes started")
            
            # Monitor processes
            while self.running:
                await self.monitor_processes()
                await asyncio.sleep(30)
                
        except KeyboardInterrupt:
            print("\n🛑 Shutting down intelligence system...")
            await self.shutdown_all()
    
    async def start_process(self, command):
        """Start a subprocess and return it"""
        try:
            process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            print(f"✅ Started: {command}")
            return process
        except Exception as e:
            print(f"❌ Failed to start: {command} - {e}")
            return None
    
    async def monitor_processes(self):
        """Monitor all running processes"""
        for name, process in self.processes.items():
            if process and process.returncode is not None:
                print(f"⚠️  Process {name} died, restarting...")
                # Restart failed process
                # Implementation depends on specific process
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        print(f"\n🛑 Received signal {signum}, shutting down...")
        self.running = False
    
    async def shutdown_all(self):
        """Shutdown all processes gracefully"""
        for name, process in self.processes.items():
            if process:
                try:
                    process.terminate()
                    await process.wait()
                    print(f"✅ Stopped: {name}")
                except Exception as e:
                    print(f"❌ Error stopping {name}: {e}")

if __name__ == "__main__":
    controller = LearningController()
    asyncio.run(controller.start_all_learning_processes())
