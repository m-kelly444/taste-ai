#!/bin/bash
set -e

python3 -c "
import asyncio
import subprocess
import psutil
import GPUtil
import redis
import json
import time
from concurrent.futures import ThreadPoolExecutor
import signal
import sys

class MasterOrchestrator:
    def __init__(self):
        self.redis = redis.Redis()
        self.processes = {}
        self.system_metrics = {}
        self.performance_targets = {
            'gpu_utilization': 85.0,
            'memory_efficiency': 90.0,
            'throughput': 1000.0,
            'latency': 0.1
        }
        
    def check_system_resources(self):
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        
        gpu_stats = []
        for gpu in GPUtil.getGPUs():
            gpu_stats.append({
                'id': gpu.id,
                'load': gpu.load * 100,
                'memory_util': gpu.memoryUtil * 100,
                'memory_used': gpu.memoryUsed,
                'memory_total': gpu.memoryTotal,
                'temperature': gpu.temperature
            })
        
        self.system_metrics = {
            'cpu_percent': cpu_percent,
            'memory_percent': memory.percent,
            'memory_available': memory.available / (1024**3),
            'gpus': gpu_stats,
            'timestamp': time.time()
        }
        
        self.redis.set('system_metrics', json.dumps(self.system_metrics))
        
        return self.system_metrics
    
    def start_process(self, script_name, process_name):
        try:
            process = subprocess.Popen(['/bin/bash', script_name], 
                                     stdout=subprocess.PIPE, 
                                     stderr=subprocess.PIPE)
            self.processes[process_name] = {
                'process': process,
                'script': script_name,
                'start_time': time.time(),
                'status': 'running'
            }
            print(f'Started {process_name} (PID: {process.pid})')
            return True
        except Exception as e:
            print(f'Failed to start {process_name}: {e}')
            return False
    
    def monitor_process_health(self, process_name):
        if process_name not in self.processes:
            return False
        
        process_info = self.processes[process_name]
        process = process_info['process']
        
        if process.poll() is not None:
            self.processes[process_name]['status'] = 'dead'
            return False
        
        try:
            proc = psutil.Process(process.pid)
            cpu_percent = proc.cpu_percent()
            memory_info = proc.memory_info()
            
            health_data = {
                'cpu_percent': cpu_percent,
                'memory_mb': memory_info.rss / (1024**2),
                'status': 'healthy',
                'uptime': time.time() - process_info['start_time']
            }
            
            self.redis.set(f'process_health_{process_name}', json.dumps(health_data))
            return True
            
        except psutil.NoSuchProcess:
            self.processes[process_name]['status'] = 'dead'
            return False
    
    def restart_process(self, process_name):
        if process_name in self.processes:
            process_info = self.processes[process_name]
            
            try:
                process_info['process'].terminate()
                process_info['process'].wait(timeout=10)
            except:
                process_info['process'].kill()
            
            del self.processes[process_name]
        
        script_name = f'{process_name.split(\"_\")[0]}.sh'
        return self.start_process(script_name, process_name)
    
    def optimize_resource_allocation(self):
        metrics = self.check_system_resources()
        
        for gpu_stat in metrics['gpus']:
            gpu_id = gpu_stat['id']
            gpu_load = gpu_stat['load']
            memory_util = gpu_stat['memory_util']
            
            if gpu_load < 50 and memory_util < 60:
                self.redis.publish(f'gpu_{gpu_id}_underutilized', json.dumps(gpu_stat))
            elif gpu_load > 95 or memory_util > 95:
                self.redis.publish(f'gpu_{gpu_id}_overloaded', json.dumps(gpu_stat))
        
        if metrics['cpu_percent'] > 90:
            self.redis.publish('cpu_overload', json.dumps(metrics))
        
        if metrics['memory_percent'] > 85:
            self.redis.publish('memory_pressure', json.dumps(metrics))
    
    async def orchestrate_system(self):
        scripts_to_run = [
            ('01_gpu_system_init.sh', 'gpu_init'),
            ('02_parallel_model_training.sh', 'model_training'),
            ('03_gpu_inference_engine.sh', 'inference_engine'),
            ('04_distributed_data_processing.sh', 'data_processing'),
            ('05_real_time_optimization.sh', 'optimization'),
            ('06_smart_memory_management.sh', 'memory_management'),
            ('07_adaptive_architecture_evolution.sh', 'architecture_evolution'),
            ('08_multi_gpu_ensemble.sh', 'gpu_ensemble')
        ]
        
        for script, process_name in scripts_to_run:
            success = self.start_process(script, process_name)
            if success:
                await asyncio.sleep(5)
            else:
                print(f'Failed to start {process_name}, continuing...')
        
        while True:
            try:
                self.optimize_resource_allocation()
                
                for process_name in list(self.processes.keys()):
                    if not self.monitor_process_health(process_name):
                        print(f'{process_name} is unhealthy, restarting...')
                        self.restart_process(process_name)
                        await asyncio.sleep(10)
                
                overall_performance = self.calculate_system_performance()
                self.redis.set('overall_performance', str(overall_performance))
                
                if overall_performance < 0.7:
                    await self.adaptive_scaling()
                
                await asyncio.sleep(30)
                
            except Exception as e:
                print(f'Orchestration error: {e}')
                await asyncio.sleep(60)
    
    def calculate_system_performance(self):
        try:
            metrics = json.loads(self.redis.get('system_metrics') or '{}')
            
            if not metrics or 'gpus' not in metrics:
                return 0.5
            
            gpu_utilization = np.mean([gpu['load'] for gpu in metrics['gpus']])
            memory_efficiency = 100 - metrics['memory_percent']
            
            inference_results = 0
            for gpu_id in range(len(metrics['gpus'])):
                results = self.redis.llen(f'inference_results_gpu_{gpu_id}')
                inference_results += results
            
            throughput_score = min(inference_results / 1000.0, 1.0)
            
            performance = (
                (gpu_utilization / 100) * 0.4 +
                (memory_efficiency / 100) * 0.3 +
                throughput_score * 0.3
            )
            
            return performance
            
        except Exception as e:
            print(f'Performance calculation error: {e}')
            return 0.5
    
    async def adaptive_scaling(self):
        print('Performing adaptive scaling...')
        
        metrics = self.check_system_resources()
        
        underutilized_gpus = [gpu for gpu in metrics['gpus'] if gpu['load'] < 50]
        
        if len(underutilized_gpus) > 1:
            self.redis.publish('scale_up_inference', json.dumps({'gpus': len(underutilized_gpus)}))
        
        overloaded_gpus = [gpu for gpu in metrics['gpus'] if gpu['load'] > 95]
        
        if len(overloaded_gpus) > 0:
            self.redis.publish('redistribute_load', json.dumps({'overloaded_gpus': [gpu['id'] for gpu in overloaded_gpus]}))
        
        if metrics['memory_percent'] > 90:
            self.redis.publish('emergency_memory_cleanup', json.dumps(metrics))
    
    def signal_handler(self, signum, frame):
        print('Shutting down orchestrator...')
        
        for process_name, process_info in self.processes.items():
            try:
                process_info['process'].terminate()
                process_info['process'].wait(timeout=10)
            except:
                process_info['process'].kill()
        
        sys.exit(0)

async def main():
    orchestrator = MasterOrchestrator()
    
    signal.signal(signal.SIGINT, orchestrator.signal_handler)
    signal.signal(signal.SIGTERM, orchestrator.signal_handler)
    
    await orchestrator.orchestrate_system()

if __name__ == '__main__':
    asyncio.run(main())
" &

ORCHESTRATOR_PID=$!
echo "Master orchestrator started with PID: $ORCHESTRATOR_PID"

trap "kill $ORCHESTRATOR_PID" EXIT

while true; do
    PERFORMANCE=$(redis-cli GET overall_performance 2>/dev/null || echo "0")
    METRICS=$(redis-cli GET system_metrics 2>/dev/null)
    
    echo "System Performance: $PERFORMANCE"
    
    if [ ! -z "$METRICS" ]; then
        echo "$METRICS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'CPU: {data[\"cpu_percent\"]:.1f}%')
    print(f'Memory: {data[\"memory_percent\"]:.1f}%')
    print('GPUs:')
    for gpu in data['gpus']:
        print(f'  GPU {gpu[\"id\"]}: {gpu[\"load\"]:.1f}% load, {gpu[\"memory_util\"]:.1f}% memory, {gpu[\"temperature\"]}°C')
except:
    print('No system metrics available')
"
    fi
    
    ACTIVE_PROCESSES=$(ps aux | grep -E "(gpu_system_init|parallel_model_training|gpu_inference_engine|distributed_data_processing|real_time_optimization|smart_memory_management|adaptive_architecture_evolution|multi_gpu_ensemble)" | grep -v grep | wc -l)
    echo "Active processes: $ACTIVE_PROCESSES"
    
    echo "---"
    sleep 20
done