FROM ghcr.io/hotio/base@sha256:96350ff96c12387896f33a49396f33d5a07f07d23e9d8243c71c70ba322d551f

EXPOSE 8080 8443 2019

RUN apk add --no-cache nss-tools

ARG VERSION
RUN curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v${VERSION}/caddy_${VERSION}_linux_arm64.tar.gz" | tar xzf - -C "${APP_DIR}" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    ln -s "${APP_DIR}/caddy" "/usr/local/bin/caddy"

COPY root/ /
