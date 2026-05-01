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

# Install all workspace packages into the venv
# Create venv and use its pip directly
RUN uv venv .venv && \
    .venv/bin/uv pip install -e ./tools && \
    .venv/bin/uv pip install -e ./core

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

# Copy installed packages from builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/core /app/core
COPY --from=builder /app/tools /app/tools
COPY --from=builder /app/pyproject.toml /app/pyproject.toml

# Create exports directory if it doesn't exist (may be empty in fresh clones)
RUN mkdir -p /app/exports && chown hive:hive /app/exports

# Copy Hive CLI scripts
COPY --from=builder /app/hive /app/hive
COPY --from=builder /app/quickstart.sh /app/quickstart.sh
RUN chmod +x /app/hive /app/quickstart.sh

# Set environment variables
ENV PYTHONPATH=/app/core:/app/exports:/app/tools \
    VIRTUAL_ENV=/app/.venv \
    PATH=/app/.venv/bin:$PATH \
    HIVE_ENV=production \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Switch to non-root user
USER hive

# Create workspace directory
RUN mkdir -p /home/hive/.hive/workspace

# Health check endpoint (if agent runs HTTP server)
# For background workers, this will be disabled in Coolify config
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health 2>/dev/null || exit 0

# Default command - runs Hive framework
# Override in Coolify with your specific agent command
# Example: python -m framework.agents.cinestory_engine run
CMD ["python", "-m", "framework", "--help"]
