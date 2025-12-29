ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

FROM golang:alpine AS builder
ARG VERSION
RUN apk add --no-cache curl jq
RUN xcaddy_version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/caddyserver/xcaddy/releases/latest" | jq -r .tag_name | sed s/v//g) && \
    wget -O - "https://github.com/caddyserver/xcaddy/releases/download/v${xcaddy_version}/xcaddy_${xcaddy_version}_linux_amd64.tar.gz" | tar xzf - -C "/bin" && \
    xcaddy build v${VERSION} --output /caddy-bin \
        --with github.com/mholt/caddy-ratelimit \
        --with github.com/caddy-dns/cloudflare && \
    chmod 755 "/caddy-bin"


FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}
EXPOSE 8080 8443
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} CUSTOM_BUILD="" WEBUI_PORTS="8080/tcp,8443/tcp"
COPY --from=builder /caddy-bin "${APP_DIR}/caddy"
COPY root/ /
RUN find /etc/s6-overlay/s6-rc.d -name "run*" -execdir chmod +x {} +
