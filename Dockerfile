# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Build arguments for versioning and metadata
ARG VERSION="unknown"
ARG BUILD_DATE="unknown"
ARG GIT_COMMIT="unknown"

# Labels for image metadata (OCI standard)
LABEL org.opencontainers.image.title="concierge-crewai"
LABEL org.opencontainers.image.description="A dockerized CrewAI application for AI-powered concierge services"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${GIT_COMMIT}"
LABEL org.opencontainers.image.vendor="Concierge CrewAI"
LABEL org.opencontainers.image.source="https://github.com/your-org/concierge-crewai"

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH=/app/src
ENV APP_VERSION="${VERSION}"

# Install system dependencies and uv
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir uv

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy crew project files
COPY crew/ ./

# Install Python dependencies using uv sync
RUN uv sync --frozen --no-dev

# Create output directory and set permissions
RUN mkdir -p /app/output && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# Default command - interactive mode for manual execution
CMD ["bash", "-c", "echo '🚀 Concierge CrewAI v${APP_VERSION} ready!' && echo 'Run: uv run python -c \"from crew.main import run; run()\"' && tail -f /dev/null"] 