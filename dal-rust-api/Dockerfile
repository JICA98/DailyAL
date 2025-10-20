FROM rust:1.90.0 as builder

WORKDIR /builder

# Install MUSL toolchain for fully static linking and supporting tools
RUN apt-get update \
	&& apt-get install -y --no-install-recommends musl-tools pkg-config make clang \
	&& rm -rf /var/lib/apt/lists/*

# Add MUSL target
RUN rustup target add x86_64-unknown-linux-musl

# Copy source
COPY . .

# Ensure vendored OpenSSL links statically and build for MUSL target
ENV OPENSSL_STATIC=1
RUN cargo build -p dal-rust-api --release --target x86_64-unknown-linux-musl

# Minimal runtime with no glibc dependency; include certs for HTTPS
FROM gcr.io/distroless/static-debian12

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /builder/target/x86_64-unknown-linux-musl/release/dal-rust-api /dal-rust-api

EXPOSE 8001

USER nonroot:nonroot
CMD ["/dal-rust-api"]