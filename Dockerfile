FROM python:3.10-slim

# Install system dependencies including curl
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Default port (will be overridden by environment variable)
ENV METRICS_PORT=9090

# Make scripts executable
RUN chmod +x *.py test_collectors.sh

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:${METRICS_PORT}/metrics || exit 1

CMD ["python", "openwakeword_metrics.py"]
