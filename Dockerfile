# Aden Hive - Coolify Deployment
# Multi-stage build for agent execution environment

FROM python:3.12-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install --no-cache-dir uv

WORKDIR /app

# Copy workspace files
COPY . .

# Install all workspace packages directly (no venv needed in container)
# core must be installed first as tools depends on the 'framework' package (which is core)
RUN pip install -e ./core && \
    pip install -e ./tools

# Runtime stage
FROM python:3.12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -u 1000 hive && \
    mkdir -p /app/exports /app/core/.data /home/hive/.hive && \
    chown -R hive:hive /app /home/hive

WORKDIR /app

# Copy source and install packages in runtime stage
# NOTE: pip install in runtime, not just builder. The builder stage only
# copies source dirs (/app/core, /app/tools) — NOT the installed deps from
# site-packages. Installing here ensures Python finds pydantic etc. at runtime.
COPY --from=builder /app/core /app/core
COPY --from=builder /app/tools /app/tools
COPY --from=builder /app/pyproject.toml /app/pyproject.toml
COPY --from=builder /app/hive /app/hive
COPY --from=builder /app/quickstart.sh /app/quickstart.sh

RUN pip install --no-cache-dir -e /app/core && \
    pip install --no-cache-dir -e /app/tools

# Expose HTTP server port (Traefik routes to this)
EXPOSE 8000

# Set environment variables
ENV PYTHONPATH=/app/core:/app/exports:/app/tools \
    HIVE_ENV=production \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Switch to non-root user
USER hive

# Create workspace directory
RUN mkdir -p /home/hive/.hive/workspace

CMD ["hive", "serve", "--host", "0.0.0.0", "--port", "8000"]
