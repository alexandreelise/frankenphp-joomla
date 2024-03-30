#!/bin/sh

set -eu pipefail

echo "Deployed auto-installed version of Joomla on FrankenPHP successfully" &&
cp -r /usr/src/joomla/. /app/public/. &&
frankenphp fmt --overwrite /etc/caddy/Caddyfile &&
frankenphp validate --config /etc/caddy/Caddyfile &&
frankenphp run --config /etc/caddy/Caddyfile
