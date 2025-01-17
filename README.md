# Home Assistant AI Service Exporters

Collection of Prometheus exporters for monitoring Home Assistant AI services. These exporters provide detailed metrics for:

- OpenWakeWord: Wake word detection service metrics
- Piper: Text-to-speech service metrics
- Whisper: Speech-to-text service metrics

## Metrics Provided

### OpenWakeWord Metrics
- Detection time histograms
- Memory usage
- CPU usage
- Detection counts

### Piper Metrics
- Text-to-speech conversion times
- Resource usage
- Synthesis counts

### Whisper Metrics
- Speech recognition timings
- Resource utilization
- Processing counts

## Requirements
- Python 3.x
- Docker (for containerized deployment)
- Prometheus server (for metrics collection)

## Installation

```bash
# Clone the repository
git clone git@github.com:Shazy1997/ha-ai-exporters.git

# Build and run with Docker
docker-compose -f docker-compose.test.yml up -d
```

## Configuration
Each exporter can be configured through environment variables:
- METRICS_PORT: Port for the metrics server (default: 9090-9092)

## Integration with Home Assistant
These exporters are designed to work with Home Assistant and its AI services. They should be deployed alongside:
- Home Assistant instance
- Prometheus server
- Grafana (for visualization)

## Development
To contribute or modify:
1. Clone the repository
2. Install requirements: `pip install -r requirements.txt`
3. Run individual exporters: `python <exporter_name>.py`

## Testing
Run the test script: `./test_collectors.sh`

