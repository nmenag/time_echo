# syntax=docker/dockerfile:1
ARG RUBY_VERSION=4.0.1

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      postgresql-client \
      build-essential \
      git \
      libpq-dev \
      pkg-config \
      libyaml-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ENV BUNDLE_PATH="/usr/local/bundle"

EXPOSE 3000

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

ENTRYPOINT ["/rails/entrypoint.sh"]

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
