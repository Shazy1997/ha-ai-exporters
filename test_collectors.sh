#!/bin/bash

echo "Building and testing AI metrics collectors..."

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Function to check if service is healthy
check_health() {
    local service=$1
    local port=$2
    local max_attempts=10
    local attempt=1

    echo "Checking health of $service on port $port..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:$port/metrics" > /dev/null; then
            echo "✓ $service is healthy"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: $service not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo "✗ $service failed health check"
    return 1
}

# Build and start services
echo "Starting services..."
cd ..

echo "Building services with docker compose..."
docker compose -f docker-compose.test.yml build --no-cache || {
    echo "Error: Build failed"
    exit 1
}

echo "Starting services with docker compose..."
docker compose -f docker-compose.test.yml up -d || {
    echo "Error: Failed to start services"
    exit 1
}

# Wait for services to be healthy
sleep 5
check_health "whisper_metrics" 9090
check_health "piper_metrics" 9091
check_health "openwakeword_metrics" 9092

# Test metric endpoints
echo -e "\nTesting metric endpoints..."
for port in 9090 9091 9092; do
    echo -e "\nMetrics from port $port:"
    curl -s "http://localhost:$port/metrics" | grep -E "^[a-z]+_" | head -n 5
done

echo -e "\nTest complete. Services are running and collecting metrics."
echo "Use 'docker compose -f docker-compose.test.yml logs -f' to view logs"
