# Stage 1: Build stage
FROM python:3.9-slim-bullseye as builder

# Set build-time environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    DEBIAN_FRONTEND=noninteractive

# Create app directory for build
WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /build/wheels -r requirements.txt

# Stage 2: Runtime stage
FROM python:3.9-slim-bullseye

# Set runtime environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    METRICS_PORT=9090

# Create non-root user for security
RUN groupadd -r metrics && \
    useradd -r -g metrics -s /sbin/nologin metrics

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create and set up app directory
WORKDIR /app
COPY --from=builder /build/wheels /wheels
RUN pip install --no-cache-dir /wheels/* && \
    rm -rf /wheels

# Copy application code
COPY . .

# Set proper permissions
RUN chown -R metrics:metrics /app && \
    chmod -R 755 /app

# Switch to non-root user
USER metrics

# Expose metrics port
EXPOSE ${METRICS_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${METRICS_PORT}/metrics || exit 1

# Set default command
ENTRYPOINT ["python"]
CMD ["whisper_metrics.py"]
