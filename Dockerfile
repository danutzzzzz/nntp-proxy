# Dockerfile for nntp-proxy
FROM python:3.12-slim

# Install system dependencies (if needed)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the latest version of nntp-proxy
RUN git clone https://github.com/mjc/nntp-proxy.git /app

WORKDIR /app

# Install Python dependencies (if any)
RUN pip install --no-cache-dir -r requirements.txt || true

# Expose default NNTP proxy port
EXPOSE 119.563

# Default command
CMD ["python", "nntp-proxy.py"]
