FROM rust:1.81.0-alpine as build
WORKDIR /usr/src/service2
COPY src/ ./src
COPY Cargo.toml Cargo.lock ./
RUN apk add --update musl-dev
RUN cargo build --release

FROM alpine:3.20.3 AS app
EXPOSE 8198
WORKDIR /app
#RUN apt-get update & apt-get install -y extra-runtime-dependencies & rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/src/service2/target/release/service2 ./bin/service2
CMD ["bin/service2"]
