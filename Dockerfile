FROM --platform=linux/arm64/v8 debian:trixie-slim AS builder

ARG SS_VERSION="1.21.0"
ARG SS_URL="https://github.com/shadowsocks/shadowsocks-rust/releases/download/v${SS_VERSION}/"
ARG SS_FILENAME="shadowsocks-v${SS_VERSION}.aarch64-unknown-linux-gnu.tar.xz"

ARG V2RAY_PLUGIN_VERSION="1.3.2"
ARG V2RAY_PLUGIN_URL="https://github.com/shadowsocks/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VERSION}/"
ARG V2RAY_PLUGIN_FILENAME="v2ray-plugin-linux-arm64-v${V2RAY_PLUGIN_VERSION}.tar.gz"

RUN set -eux
RUN apt-get update -qyy
RUN apt-get install -qyy --no-install-recommends --no-install-suggests \
            ca-certificates \
            wget \
            xz-utils
RUN rm -rf /var/lib/apt/lists/* /var/log/*
RUN wget -O shadowsocks.tar.xz ${SS_URL}${SS_FILENAME}
RUN tar -xzvf v2ray_plugin.tar.gz -C /usr/local/bin/
RUN mv /usr/local/bin/v2ray-plugin* /usr/local/bin/v2ray-plugin
RUN rm -rf shadowsocks.tar.xz v2ray_plugin.tar.gz

######

FROM --platform=linux/arm64/v8 debian:trixie-slim

ENV SERVER_ADDR="0.0.0.0"
ENV SERVER_PORT="8388"
ENV PASSWORD=
ENV METHOD="aes-256-gcm"
ENV TIMEOUT="300"
ENV DNS=
ENV NETWORK=
ENV OBFS=
ENV PLUGIN=
ENV PLUGIN_OPTS=

COPY --from=builder /usr/local/bin/* /usr/local/bin/

RUN set -eux \
    && apt-get update -qyy \
    && apt-get install -qyy --no-install-recommends --no-install-suggests \
        ca-certificates \
        rng-tools \
    && rm -rf /var/lib/apt/lists/* /var/log/*

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE ${SERVER_PORT}/tcp
EXPOSE ${SERVER_PORT}/udp
