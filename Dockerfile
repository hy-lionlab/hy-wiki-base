# Ref: https://github.com/wikimedia/mediawiki-docker/blob/master/dev/Dockerfile
FROM php:7.2-fpm

ENV APCU_VERSION 5.1.18

# System dependencies
RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    git \
    sudo \
    ca-certificates \
    netcat \
    librsvg2-bin \
    imagemagick \
    zlib1g \
    zlib1g-dev \
    libpng-dev \
    # Required for SyntaxHighlighting
    python3 \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/cache/apt/archives/*;

# Install the PHP extensions
RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    build-essential \
    libicu-dev \
    ; \
    \
    docker-php-ext-install -j "$(nproc)" \
    intl \
    mbstring \
    mysqli \
    opcache \
    gd \
    ; \
    \
    # APCU Installation
    pecl install apcu-${APCU_VERSION}; \
    docker-php-ext-enable apcu; \
    # Clean
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Composer Install
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#
# Tini
#
# See https://github.com/krallin/tini for the further details
ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
