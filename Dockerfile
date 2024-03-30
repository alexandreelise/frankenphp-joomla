# syntax=docker/dockerfile:1
ARG BASE_FRANKENPHP_IMAGE
ARG BASE_JOOMLA_IMAGE
ARG USER=www-data

FROM ${BASE_FRANKENPHP_IMAGE} as common

# install the PHP extensions we need (https://downloads.joomla.org/technical-requirements)
RUN --mount=type=cache,target=/usr/local/etc/php/conf.d/ \
    install-php-extensions \
    bcmath \
    bz2 \
    gd \
    intl \
    pgsql \
    pdo_pgsql \
    opcache \
    zip

# Intermediate dependencies
FROM $BASE_JOOMLA_IMAGE AS joomla_dependencies

FROM common AS builder
RUN --mount=type=cache,target=/usr/local/etc/php/conf.d/ \
    --mount=type=cache,target=/usr/local/bin \
    --mount=type=cache,target=/usr/src/joomla \
    mkdir -p /usr/src/joomla

COPY --from=joomla_dependencies /usr/local/etc/php/conf.d/*        /usr/local/etc/php/conf.d/
COPY --from=joomla_dependencies --chmod=770 /entrypoint.sh         /usr/local/bin/entrypoint.sh
COPY --from=joomla_dependencies /makedb.php                        /usr/local/bin/makedb.php
COPY --from=joomla_dependencies /usr/src/joomla                    /usr/src/joomla
COPY ./zzz-custom.ini                                              /usr/local/etc/php/conf.d/zzz-custom.ini
COPY --chmod=770               ./install-japp.sh                   /usr/local/bin/install-japp.sh

VOLUME /usr/src/joomla
VOLUME /app/public

RUN sed -i \
    -e 's#set \-e#set \-e \&\& cd /usr/src/joomla#' \
    -e 's#/makedb\.php#/usr/local/bin/makedb\.php#g' \
    -e 's# \=\= php\-fpm# \=\= \"\/usr\/local\/bin\/install\-japp\.sh\"#' \
    -e 's#\-\-db\-encryption\=0#-\-db\-encryption\=0 -\-public\-folder\=\"\$\{JOOMLA_PUBLIC_FOLDER\:\-\/app\/public\}\"#' \
    /usr/local/bin/entrypoint.sh

FROM common AS runner

ARG USER

# Specific php extensions loading
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-fpm.ini                  /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-bcmath.ini       /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-bz2.ini          /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-gd.ini           /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-intl.ini         /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-pgsql.ini       /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-pdo_pgsql.ini       /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini      /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/docker-php-ext-zip.ini          /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/error-logging.ini               /usr/local/etc/php/conf.d/
COPY --from=builder  --chown=${USER}:${USER} /usr/local/etc/php/conf.d/opcache-recommended.ini         /usr/local/etc/php/conf.d/

COPY --from=builder --chown=${USER}:${USER} /usr/local/etc/php/conf.d/zzz-custom.ini                  /usr/local/etc/php/conf.d/
COPY --from=builder --chown=${USER}:${USER} /usr/local/bin/entrypoint.sh       /usr/local/bin/entrypoint.sh
COPY --from=builder --chown=${USER}:${USER} /usr/local/bin/makedb.php          /usr/local/bin/makedb.php
COPY --from=builder --chown=${USER}:${USER} /usr/src/joomla                    /usr/src/joomla
COPY --from=builder --chown=${USER}:${USER} /usr/local/bin/install-japp.sh                   /usr/local/bin/install-japp.sh
COPY --from=common  --chown=${USER}:${USER} /usr/local/bin/frankenphp          /usr/local/bin/frankenphp
COPY --chown=${USER}:${USER}  ./Caddyfile                                      /etc/caddy/Caddyfile

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp && \
    usermod --shell /bin/bash ${USER} && \
    mkdir -p /app/public && \
    rm -rf /app/public/* && \
    rm -rf /app/public/index.php && \
    chown -Rc ${USER}:${USER} /etc/caddy /data/caddy /config/caddy /app/public && \
    chmod 775 /app/public

EXPOSE 80/tcp
EXPOSE 443/tcp
EXPOSE 443/udp
EXPOSE 2019/tcp

VOLUME /usr/src/joomla
VOLUME /app/public

USER ${USER}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "/usr/local/bin/install-japp.sh" ]

WORKDIR /app/public

HEALTHCHECK CMD curl -f http://localhost:2019/metrics || exit
