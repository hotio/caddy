FROM cr.hotio.dev/hotio/base@sha256:32f7802fe9903727645618677d0109a2da34a6d2efbc494f3afae50fdb7b2dd2

EXPOSE 8080 8443 2019

ENV CUSTOM_BUILD=""

RUN apk add --no-cache nss-tools fail2ban

ARG VERSION
RUN curl -fsSL "https://github.com/caddyserver/caddy/releases/download/v${VERSION}/caddy_${VERSION}_linux_arm64.tar.gz" | tar xzf - -C "${APP_DIR}" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    ln -s "${APP_DIR}/caddy" "/usr/local/bin/caddy" && \
    cp -R /etc/fail2ban "${APP_DIR}/" && \
    rm -rf /etc/fail2ban && \
    ln -s "${CONFIG_DIR}/fail2ban" "/etc/fail2ban"

COPY root/ /
RUN chmod -R +x /etc/cont-init.d/ /etc/services.d/
