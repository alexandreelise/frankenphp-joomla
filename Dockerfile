# syntax=docker/dockerfile:1
FROM dunglas/frankenphp as common

# install the PHP extensions we need (https://downloads.joomla.org/technical-requirements)
RUN install-php-extensions \
    bcmath \
    exif \
    gd \
    intl \
    zip \
    redis \
    gmp \
    imagick \
    ldap \
    pgsql \
    pdo_pgsql \
    apcu \
    bz2 \
    opcache

LABEL org.opencontainers.image.title="Joomla on FrankenPHP"
LABEL org.opencontainers.image.description="Unofficial hardened example of Joomla on FrankenPHP with Postgres"
LABEL org.opencontainers.image.url=https://github.com/alexandreelise/frankenphp-joomla
LABEL org.opencontainers.image.source=https://github.com/alexandreelise/frankenphp-joomla
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.vendor="Mr Alexandre J-S William ELISÉ"


FROM common AS builder

RUN mkdir -p /usr/src/joomla

COPY --from=joomla:5-php8.2-fpm /usr/local/etc/php/conf.d/*        /usr/local/etc/php/conf.d/
COPY --from=joomla:5-php8.2-fpm /entrypoint.sh                     /usr/local/bin/
COPY --from=joomla:5-php8.2-fpm /makedb.php                        /usr/local/bin/
COPY --from=joomla:5-php8.2-fpm --chown=root:root /usr/src/joomla  /usr/src/joomla
COPY ./zzz-custom.ini                                              /usr/local/etc/php/conf.d/zzz-custom.ini
COPY ./install-japp.sh                                             /install-japp.sh

VOLUME /app/public

RUN sed -i \
    -e 's/\[ "$1" = '\''php-fpm'\'' \]/\[\[ "$1" == frankenphp* \]\]/g' \
    -e 's/php-fpm/frankenphp/g' \
    -e 's#/makedb\.php#/usr/local/bin/makedb\.php#g' \
    /usr/local/bin/entrypoint.sh

FROM common AS runner

RUN mkdir -p /app/public  \
    && rm /app/public/index.php

# Specific php extensions loading
COPY --from=builder /usr/local/etc/php/conf.d/docker-fpm.ini                  /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini         /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-bcmath.ini       /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-bz2.ini          /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-exif.ini         /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-gd.ini           /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-gmp.ini          /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-imagick.ini      /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-intl.ini         /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-ldap.ini         /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini      /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-pgsql.ini        /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-pdo_pgsql.ini    /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-redis.ini        /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini       /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-zip.ini          /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/error-logging.ini               /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/etc/php/conf.d/opcache-recommended.ini         /usr/local/etc/php/conf.d/

# Hardened custom config
COPY --from=builder /usr/local/etc/php/conf.d/zzz-custom.ini                  /usr/local/etc/php/conf.d/


COPY --from=builder /usr/local/bin/entrypoint.sh       /usr/local/bin/
COPY --from=builder /usr/local/bin/makedb.php          /usr/local/bin/
COPY --from=builder /usr/src/joomla                    /usr/src/joomla
COPY --from=builder /install-japp.sh                   /install-japp.sh
COPY --from=common /usr/local/bin/frankenphp           /usr/local/bin/frankenphp
COPY ./Caddyfile                                       /etc/caddy/Caddyfile

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

VOLUME /app/public

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/install-japp.sh"]
HEALTHCHECK CMD curl -f http://localhost:2019/metrics || exit
