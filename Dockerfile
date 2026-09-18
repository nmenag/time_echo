# syntax=docker/dockerfile:1
ARG RUBY_VERSION=4.0.1

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages and build tools for pg/native gems
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

# Node.js and npm for frontend assets compilation
COPY --from=docker.io/library/node:20-slim /usr/local/bin /usr/local/bin
COPY --from=docker.io/library/node:20-slim /usr/local/lib/node_modules /usr/local/lib/node_modules

ENV BUNDLE_PATH="/usr/local/bundle"

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install Node dependencies
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts
# Copy application code
COPY . .

# Build Tailwind CSS
RUN npm run build:css

# Precompile Rails assets
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

EXPOSE 3000

ENTRYPOINT ["/rails/entrypoint.sh"]

CMD ["sh", "-c", "bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
