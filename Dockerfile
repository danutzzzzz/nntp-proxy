# ---- Build stage ----
FROM rust:1.85 AS builder

WORKDIR /app

# Copy upstream source (cloned by GitHub Actions into source-repo/)
COPY source-repo/ .

# Build release binary
RUN cargo build --release

# ---- Runtime stage ----
FROM debian:stable-slim

WORKDIR /app

# Copy compiled binary
COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy

EXPOSE 8119

CMD ["nntp-proxy"]
