#!/bin/sh

set -eu pipefail

echo "Deployed auto-installed version of Joomla on FrankenPHP successfully" &&
echo "Here are your Joomla credentials: username: ${JOOMLA_ADMIN_USERNAME}, password: ${JOOMLA_ADMIN_PASSWORD}" &&
echo "Here are you MySQL credentials: username: root, password: ${MYSQL_ROOT_PASSWORD}" &&
echo "PLEASE CHANGE IT ON FIRST LOGIN FOR MORE SECURITY. ANYONE, OR ANYTHING THAT HAS ACCESS TO THOSE LOGS CAN SEE YOUR CREDENTIALS!!!" &&
frankenphp fmt --overwrite /etc/caddy/Caddyfile &&
frankenphp validate --config /etc/caddy/Caddyfile &&
frankenphp run --config /etc/caddy/Caddyfile
