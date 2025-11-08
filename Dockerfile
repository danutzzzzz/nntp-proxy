# ---- Builder Stage ----
FROM rust:nightly-slim-bullseye AS builder

# Set working directory
WORKDIR /app

# Copy Cargo manifest first (for caching)
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src/ src/

# Build release binary
RUN cargo build --release

# ---- Runtime Stage ----
FROM debian:bookworm-slim

# Create a user for the app
RUN useradd --create-home --shell /bin/bash nntp-proxy

# Create configuration directory
RUN mkdir -p /etc/nntp-proxy

# Copy built binary from builder
COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy

# Copy default config
COPY docker/config.yaml /etc/nntp-proxy/config.yaml

# Fix permissions
RUN chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy \
    && chown nntp-proxy:nntp-proxy /usr/local/bin/nntp-proxy

# Switch to non-root user
USER nntp-proxy

# Expose the ports your app uses
EXPOSE 8119 8993

# Set default command
CMD ["/usr/local/bin/nntp-proxy", "--config", "/etc/nntp-proxy/config.yaml"]
