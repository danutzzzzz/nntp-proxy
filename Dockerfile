# ---- Builder Stage ----
FROM rust:nightly-slim AS builder

# Set working directory
WORKDIR /app

# Copy manifest first for caching
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src/ src/

# Build the release binary
RUN cargo build --release

# ---- Runtime Stage ----
FROM debian:bookworm-slim

# Install minimal dependencies (ca-certificates for TLS)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Create user and config directory
RUN useradd --create-home --shell /bin/bash nntp-proxy && \
    mkdir -p /etc/nntp-proxy && \
    chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy

# Copy the built binary
COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy

# Copy default config
COPY docker/config.yaml /etc/nntp-proxy/config.yaml

# Ensure permissions
RUN chown -R nntp-proxy:nntp-proxy /usr/local/bin/nntp-proxy \
    /etc/nntp-proxy/config.yaml

# Switch to non-root user
USER nntp-proxy

# Expose ports (proxy port + optional NNTPS)
EXPOSE 8119 563

# Default entrypoint
ENTRYPOINT ["/usr/local/bin/nntp-proxy", "--config", "/etc/nntp-proxy/config.yaml"]
