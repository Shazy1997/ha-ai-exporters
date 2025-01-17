#!/usr/bin/env python3
from prometheus_client import start_http_server, Histogram, Counter, Gauge, Info
import time
import psutil
import os
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('openwakeword_metrics')

# Metrics definitions
DETECTION_TIME = Histogram(
    'openwakeword_detection_seconds',
    'Time taken for wake word detection',
    ['wake_word_model'],
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5]
)

MEMORY_USAGE = Gauge(
    'openwakeword_memory_bytes',
    'Memory usage by OpenWakeWord model',
    ['model_type']
)

CPU_USAGE = Gauge(
    'openwakeword_cpu_percent',
    'CPU usage by OpenWakeWord process',
    ['model_type']
)

DETECTION_COUNT = Counter(
    'openwakeword_detections_total',
    'Total number of wake word detection attempts',
    ['status', 'wake_word']
)

def collect_system_metrics():
    """Collect system-level metrics"""
    try:
        process = psutil.Process(os.getpid())
        mem_info = process.memory_info()
        MEMORY_USAGE.labels(model_type='default').set(mem_info.rss)
        cpu_percent = process.cpu_percent(interval=1.0)
        CPU_USAGE.labels(model_type='default').set(cpu_percent)
    except Exception as e:
        logger.error(f"Error collecting system metrics: {e}")

def monitor_metrics():
    """Main monitoring loop"""
    try:
        while True:
            collect_system_metrics()
            time.sleep(15)
    except Exception as e:
        logger.error(f"Error in monitoring loop: {e}")
        raise

if __name__ == '__main__':
    try:
        port = int(os.getenv('METRICS_PORT', 9092))
        start_http_server(port)
        logger.info(f"Started metrics server on port {port}")
        monitor_metrics()
    except Exception as e:
        logger.error(f"Failed to start metrics server: {e}")
        raise
