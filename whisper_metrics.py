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
logger = logging.getLogger('whisper_metrics')

# Metrics definitions
TRANSCRIPTION_TIME = Histogram(
    'whisper_transcription_seconds',
    'Time taken for speech transcription',
    ['model_size', 'language'],
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 30.0]
)

MEMORY_USAGE = Gauge(
    'whisper_memory_bytes',
    'Memory usage by Whisper model',
    ['model_size']
)

REQUEST_COUNT = Counter(
    'whisper_requests_total',
    'Total number of transcription requests',
    ['status', 'model_size']
)

def collect_system_metrics():
    """Collect system-level metrics for the Whisper process"""
    try:
        process = psutil.Process(os.getpid())
        mem_info = process.memory_info()
        MEMORY_USAGE.labels(model_size='base').set(mem_info.rss)
        logger.debug(f"Updated memory metrics: {mem_info.rss} bytes")
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
        port = int(os.getenv('METRICS_PORT', 9090))
        start_http_server(port)
        logger.info(f"Started metrics server on port {port}")
        monitor_metrics()
    except Exception as e:
        logger.error(f"Failed to start metrics server: {e}")
        raise
