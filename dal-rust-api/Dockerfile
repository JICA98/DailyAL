FROM rust:1.71.1 as builder

WORKDIR /builder

COPY . .

RUN cargo build -p dal-rust-api --release

FROM gcr.io/distroless/cc

COPY --from=builder /builder/target/release/dal-rust-api /

EXPOSE 8000

CMD ["./dal-rust-api"]