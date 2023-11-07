FROM dunglas/frankenphp

# install the PHP extensions we need (https://downloads.joomla.org/technical-requirements)
RUN install-php-extensions \
    bcmath \
    exif \
    gd \
    intl \
    mysqli \
    zip \
    redis \
    gmp \
    imagick \
    ldap \
    pdo_mysql \
    opcache

COPY --from=joomla:5-php8.2-fpm /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d/
COPY --from=joomla:5-php8.2-fpm /entrypoint.sh /usr/local/bin/
COPY --from=joomla:5-php8.2-fpm /makedb.php /usr/local/bin/
COPY --from=joomla:5-php8.2-fpm --chown=root:root /usr/src/joomla /app/public

VOLUME /app/public

RUN sed -i \
    -e 's/\[ "$1" = '\''php-fpm'\'' \]/\[\[ "$1" == frankenphp* \]\]/g' \
    -e 's/php-fpm/frankenphp/g' \
    -e 's#/usr/src/joomla#/app/public#g' \
    -e 's#/makedb\.php#/usr/local/bin/makedb\.php#g' \
    /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
