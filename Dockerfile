# ---- Builder Stage ----
FROM rust:1.85.0-nightly-slim AS builder

# Install git to clone the repo
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the nntp-proxy repository
RUN git clone --branch main https://github.com/mjc/nntp-proxy.git .

# Build the release binary
RUN cargo build --release --bin nntp-proxy

# ---- Runtime Stage ----
FROM debian:bookworm-slim

# Create user and config folder
RUN useradd --create-home --shell /bin/bash nntp-proxy
RUN mkdir -p /etc/nntp-proxy

# Copy the binary from builder stage
COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy

# Copy configuration file (you must have this locally or in your Docker build context)
COPY docker/config.yaml /etc/nntp-proxy/config.yaml

# Set permissions
RUN chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy

# Expose ports
EXPOSE 8119 8993

# Switch to non-root user
USER nntp-proxy

# Default entrypoint
ENTRYPOINT ["/usr/local/bin/nntp-proxy", "--config", "/etc/nntp-proxy/config.yaml", "--port", "8119"]
