# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Keep Python output unbuffered so we can see logs in real-time
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install uv for package management
RUN pip install --no-cache-dir uv

# Set working directory
WORKDIR /app

# Copy the entire crew project structure
COPY crew/ ./

# Install dependencies using uv sync
RUN uv sync --frozen

# Set Python path so we can import the crew modules
ENV PYTHONPATH=/app/src

# Default command - but don't auto-run the crew
CMD ["bash", "-c", "echo '🚀 Crew container ready! Run: uv run python -c \"from crew.main import run; run()\"' && tail -f /dev/null"] 