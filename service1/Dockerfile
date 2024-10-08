FROM elixir:1.17.3-alpine as build

# install build dependencies
RUN apk add --update git build-base

WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# build project
COPY lib lib
RUN mix compile

# build release
RUN mix release

# prepare release image
FROM alpine:3.20.3 AS app

# install runtime dependencies
RUN apk add --update ncurses libstdc++ libgcc

EXPOSE 8199
ENV MIX_ENV=prod

WORKDIR /app

# copy release to app container
COPY --from=build /app/_build/prod/rel/service1 .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
CMD ["bin/service1", "start"]
