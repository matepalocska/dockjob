#! /usr/bin/env bash

# NGINX mainline bookworm/arm64 kompatibilis verzió
export NGINX_VERSION=1.27.1
export NJS_VERSION=0.8.4
export PKG_RELEASE=1~bookworm

set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends gnupg ca-certificates curl && \
    \
    # NGINX hivatalos bookworm kulcsok (2FD21310B49F6B46 a helyes!)
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /etc/apt/keyrings/nginx-archive-keyring.gpg && \
    \
    echo "deb [signed-by=/etc/apt/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/mainline/debian/ bookworm nginx" > /etc/apt/sources.list.d/nginx.list && \
    \
    apt-get update && \
    \
    dpkgArch="$(dpkg --print-architecture)" \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}.${NJS_VERSION}-${PKG_RELEASE} \
    " \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        gettext-base \
                        $nginxPackages \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    \
    # Nginx log dir létrehozása
    mkdir -p /var/log/nginx && \
    chown -R www-www-data /var/log/nginx /var/cache/nginx /var/run && \
    \
    # Logok forward docker-hez
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
