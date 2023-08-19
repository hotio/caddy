ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}
EXPOSE 8080 8443
VOLUME ["${CONFIG_DIR}"]

ENV CUSTOM_BUILD=""

RUN apk add --no-cache nss-tools fail2ban cronie logrotate

ARG VERSION
RUN curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v${VERSION}/caddy_${VERSION}_linux_amd64.tar.gz" | tar xzf - -C "${APP_DIR}" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    ln -s "${APP_DIR}/caddy" "/usr/local/bin/caddy" && \
    cp -R /etc/fail2ban "${APP_DIR}/" && \
    rm -rf /etc/fail2ban && \
    ln -s "${CONFIG_DIR}/fail2ban" "/etc/fail2ban"

COPY root/ /
RUN chmod -R +x /etc/cont-init.d/ /etc/services.d/
