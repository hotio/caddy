FROM ghcr.io/hotio/base@sha256:d8582ff9dab61d63a2b07d3442b9f991a895d76a9890ab7380e6871dfeedf17c

EXPOSE 8080 8443 2019

RUN apk add --no-cache nss-tools

ARG VERSION
RUN curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v${VERSION}/caddy_${VERSION}_linux_armv7.tar.gz" | tar xzf - -C "${APP_DIR}" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    ln -s "${APP_DIR}/caddy" "/usr/local/bin/caddy"

COPY root/ /
