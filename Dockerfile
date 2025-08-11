FROM python:3.11-slim

# Install system dependencies including build tools
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    g++ \
    make \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY *.py ./
COPY entrypoint.sh ./

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Create submit_history directory
RUN mkdir -p submit_history

# Create non-root user
RUN useradd -m -u 1000 meowcoin && chown -R meowcoin:meowcoin /app
USER meowcoin

# Expose default stratum port
EXPOSE 54321

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:54321 || exit 1

# Use entrypoint script
ENTRYPOINT ["./entrypoint.sh"] 