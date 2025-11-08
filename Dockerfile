# ---- Builder Stage ----
FROM rust:1.80-slim AS builder

# Set working directory
WORKDIR /app

# Copy Cargo files
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src/ src/

# Build release binary
RUN cargo build --release

# ---- Runtime Stage ----
FROM debian:bookworm-slim

# Create non-root user
RUN useradd --create-home --shell /bin/bash nntp-proxy

# Create config directory
RUN mkdir -p /etc/nntp-proxy

# Copy binary from builder
COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy

# Copy config file
COPY docker/config.yaml /etc/nntp-proxy/config.yaml

# Fix ownership
RUN chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy

# Expose ports
EXPOSE 8119 8993

# Run as non-root
USER nntp-proxy

# Default command
CMD ["/usr/local/bin/nntp-proxy", "--config", "/etc/nntp-proxy/config.yaml"]
