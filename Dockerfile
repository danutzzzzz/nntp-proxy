# ---- Builder Stage ----
FROM rust:1.80-slim AS builder

WORKDIR /app

# Install git to clone repo
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --branch main https://github.com/username/nntp-proxy.git . 

# Build the project
RUN cargo build --release --bin nntp-proxy

# ---- Runtime Stage ----
FROM debian:bookworm-slim

# Create user and config folder
RUN useradd --create-home --shell /bin/bash nntp-proxy
RUN mkdir -p /etc/nntp-proxy

# Copy binary and config
COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy
COPY docker/config.yaml /etc/nntp-proxy/config.yaml

RUN chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy

EXPOSE 8119 8993

USER nntp-proxy
ENTRYPOINT ["/usr/local/bin/nntp-proxy"]
