# ---- Builder Stage ----
FROM rustlang/rust:nightly AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./

RUN mkdir -p src && echo "fn main() {}" > src/main.rs
RUN cargo build --release || true

COPY . .

RUN cargo build --release

# ---- Runtime Stage ----
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy
COPY docker/config.yaml /etc/nntp-proxy/config.yaml
RUN chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy

EXPOSE 8119 8993

ENTRYPOINT ["/usr/local/bin/nntp-proxy"]
