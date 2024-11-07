FROM rust:1.81.0-alpine AS build
WORKDIR /usr/src/service2
COPY src/ ./src
COPY Cargo.toml Cargo.lock ./
RUN apk add --update musl-dev
RUN cargo build --release

FROM alpine:3.20.3 AS app
# required for ps -ax to work on alpine
RUN apk add --update procps
EXPOSE 80
WORKDIR /app
COPY --from=build /usr/src/service2/target/release/service2 ./bin/service2
CMD ["bin/service2"]
