FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG APP_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

ENV SNAPPDF_CHROMIUM_PATH=/usr/bin/chromium-browser

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    composer \
    curl \
    git \
    jq \
    nodejs \
    npm && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache  \
    chromium \
    mariadb-client \
    php7 \
    php7-bcmath \
    php7-curl \
    php7-dom \
    php7-gd \
    php7-mysqli \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_sqlite \
    php7-tokenizer \
    php7-xmlreader \
    php7-zip && \
  echo "**** install invoiceninja ****" && \
  mkdir -p /app/invoiceninja && \
  if [ -z ${APP_VERSION} ]; then \
    APP_VERSION=$(curl -s https://api.github.com/repos/invoiceninja/invoiceninja/releases | jq -rc 'limit(1;.[] | select( .target_commitish | match("v5-stable"))) .tag_name'); \
  fi && \
  curl -o \
    /tmp/invoiceninja.tar.gz -L \
    "https://github.com/invoiceninja/invoiceninja/archive/${APP_VERSION}.tar.gz" && \
  tar xf \
  /tmp/invoiceninja.tar.gz -C \
    /app/invoiceninja/ --strip-components=1 && \
  cd /app/invoiceninja && \
  npm install --production && \
  npm run production && \
  echo "**** install composer dependencies ****" && \
  composer install \
    -d /app/invoiceninja \
    --no-dev \
    --no-suggest \
    --no-interaction && \
  echo "**** removing unused chrome download ****" && \
  rm -rf /app/invoiceninja/vendor/beganovich/snappdf/versions && \
  echo "**** setting permissions ****" && \
  chown -R abc:abc /app/invoiceninja && \
  echo "**** overlay-fs workaround ****" && \
  mv /app /app-tmp && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /app/invoiceninja/node_modules

# add local files
COPY root/ /
