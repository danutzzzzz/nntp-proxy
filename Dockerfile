# ---- Builder Stage ----
FROM rustlang/rust:nightly AS builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY src/ src/
RUN cargo build --release

# ---- Runtime Stage ----
FROM debian:bookworm-slim

RUN useradd --create-home --shell /bin/bash nntp-proxy && \
    mkdir -p /etc/nntp-proxy

COPY --from=builder /app/target/release/nntp-proxy /usr/local/bin/nntp-proxy
COPY docker/config.yaml /etc/nntp-proxy/config.yaml

RUN chown -R nntp-proxy:nntp-proxy /etc/nntp-proxy /usr/local/bin/nntp-proxy

USER nntp-proxy

EXPOSE 8119 8993

ENTRYPOINT ["/usr/local/bin/nntp-proxy", "--config", "/etc/nntp-proxy/config.yaml"]
