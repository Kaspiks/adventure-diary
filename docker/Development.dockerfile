# Development Dockerfile for Adventure Diary
# Adapted for Ruby 3.2.3 / Rails 8.0
# Uses importmap-rails, so Node/Yarn are NOT required

FROM ruby:3.2.3-slim-bookworm

ARG UID=1000
ARG GID=1000

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

ENV APP_WORKDIR /app
ENV APP_USER_HOME /home/rails

# ----------------------------
# APT hardening for flaky/blocked networks
# - Force HTTPS to avoid blocked port 80
# - Add retries + timeouts
# ----------------------------
RUN set -eux; \
  sed -i 's|http://deb.debian.org|https://deb.debian.org|g; s|http://security.debian.org|https://security.debian.org|g' /etc/apt/sources.list.d/debian.sources 2>/dev/null || true; \
  sed -i 's|http://deb.debian.org|https://deb.debian.org|g; s|http://security.debian.org|https://security.debian.org|g' /etc/apt/sources.list 2>/dev/null || true; \
  printf 'Acquire::Retries "5";\nAcquire::https::Timeout "30";\nAcquire::http::Timeout "30";\n' > /etc/apt/apt.conf.d/80-retries

# Install all dependencies in a single layer to reduce network issues
RUN set -eux; \
  apt-get update -qq; \
  apt-get install -y --no-install-recommends --fix-missing \
    # Core build tools
    curl \
    gnupg2 \
    gcc \
    g++ \
    patch \
    make \
    git \
    # PostgreSQL client libraries
    libpq-dev \
    libpq5 \
    postgresql-client \
    # ImageMagick for image processing (optional)
    imagemagick \
    libmagickwand-dev; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user
RUN set -eux; \
  groupadd --gid "$GID" --system rails; \
  useradd --gid rails --uid "$UID" --home "$APP_USER_HOME" --no-log-init --system rails

RUN set -eux; \
  mkdir -p "$APP_USER_HOME" "$APP_WORKDIR"; \
  chown -R rails:rails "$APP_USER_HOME" "$APP_WORKDIR"

WORKDIR $APP_WORKDIR

# Install gems first (layer caching)
COPY --chown=rails:rails Gemfile Gemfile.lock $APP_WORKDIR/

RUN set -eux; \
  bundle install --jobs 4 --retry 5; \
  rm -rf "$GEM_HOME/cache"; \
  chown -R rails:rails "$GEM_HOME"

# Copy application code
COPY --chown=rails:rails . $APP_WORKDIR

# Copy entrypoint
COPY docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

USER rails

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000", "-P", "/tmp/server.pid"]