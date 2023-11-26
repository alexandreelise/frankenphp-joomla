#!/bin/sh

set -eu

APP_USER="${APP_USER:-"App User $(php -r 'echo bin2hex(random_bytes(4));')"}"
APP_USERNAME="${APP_USERNAME:-"japp-user-$(php -r 'echo bin2hex(random_bytes(4));')"}"
APP_PASSWORD="${APP_PASSWORD:-"$(php -r 'echo bin2hex(random_bytes(16));')"}"
DB_PREFIX="$(php -r 'echo bin2hex(random_bytes(2));')"

# Try to sync password between frankenphp-joomla service and postgres service
export POSTGRES_PASSWORD

# Auto-install Joomla via command-line the hardened way
[ -d /usr/src/joomla/installation ] && cd /usr/src/joomla/installation &&
  echo "[START AUTO INSTALL JOOMLA]: $(date)" && php joomla.php install \
  -n \
  --ansi \
  --site-name="Joomla on FrankenPHP" \
  --admin-user="${APP_USER}" \
  --admin-username="${APP_USERNAME}" \
  --admin-password="${APP_PASSWORD}" \
  --admin-email='admin@example.org' \
  --db-type='pgsql' \
  --db-host="${JOOMLA_DB_HOST:-localhost}" \
  --db-user="postgres" \
  --db-pass="${POSTGRES_PASSWORD}" \
  --db-name="${JOOMLA_DB_NAME:-joomla_db}" \
  --db-prefix="p${DB_PREFIX:-japp}_" &&
  cd /usr/src/joomla &&
  php /usr/src/joomla/cli/joomla.php site:create-public-folder --public-folder=/app/public &&
  echo "[END AUTO INSTALL JOOMLA] $(date)" &&
  echo "Deployed hardened version of Joomla on FrankenPHP successfully" &&
  echo "Here are your Joomla credentials: username: ${APP_USERNAME}, password: ${APP_PASSWORD}" &&
  echo "Here are your DB credentials: username: postgres, password: ${POSTGRES_PASSWORD}" &&
  echo "PLEASE CHANGE IT ON FIRST LOGIN FOR MORE SECURITY. ANYONE, OR ANYTHING THAT HAS ACCESS TO THOSE LOGS CAN SEE YOUR CREDENTIALS!!!" &&
  /usr/local/bin/frankenphp fmt --overwrite /etc/caddy/Caddyfile &&
  /usr/local/bin/frankenphp validate --config /etc/caddy/Caddyfile &&
  /usr/local/bin/frankenphp run --config /etc/caddy/Caddyfile
