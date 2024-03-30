#!/bin/sh

set -eu pipefail

echo "Deployed auto-installed version of Joomla on FrankenPHP successfully" &&
frankenphp fmt --overwrite /etc/caddy/Caddyfile &&
frankenphp validate --config /etc/caddy/Caddyfile &&
frankenphp run --config /etc/caddy/Caddyfile
