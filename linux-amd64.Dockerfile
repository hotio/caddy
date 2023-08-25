ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

FROM golang:alpine as builder
ARG VERSION
RUN apk add --no-cache curl jq
RUN mkdir /caddy && \
    xcaddy_version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/caddyserver/xcaddy/releases/latest" | jq -r .tag_name | sed s/v//g) && \
    wget -O - "https://github.com/caddyserver/xcaddy/releases/download/v${xcaddy_version}/xcaddy_${xcaddy_version}_linux_arm64.tar.gz" | tar xzf - -C "/bin" && \
    cd /caddy && \
    xcaddy build v${VERSION} --output /caddy/caddy \
        --with github.com/caddy-dns/cloudflare && \
    chmod 755 "/caddy/caddy"


FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}
EXPOSE 8080 8443
VOLUME ["${CONFIG_DIR}"]

ENV CUSTOM_BUILD=""

RUN apk add --no-cache nss-tools fail2ban cronie logrotate

ARG VERSION
COPY --from=builder /caddy/caddy "${APP_DIR}/caddy"
RUN chmod -R u=rwX,go=rX "${APP_DIR}" && \
    ln -s "${APP_DIR}/caddy" "/usr/local/bin/caddy" && \
    cp -R /etc/fail2ban "${APP_DIR}/" && \
    rm -rf /etc/fail2ban && \
    ln -s "${CONFIG_DIR}/fail2ban" "/etc/fail2ban"

COPY root/ /
RUN chmod -R +x /etc/cont-init.d/ /etc/services.d/
