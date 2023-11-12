# Joomla on FrankenPHP

Run the popular [Joomla CMS](https://joomla.org) on top of [FrankenPHP](https://frankenphp.dev),
the modern app server for PHP.

## TL;DR (Summary)

> This branch explains how to auto-install Joomla on FrankenPHP with Postgres as Database.

## Getting Started

```
git clone https://github.com/alexandreelise/frankenphp-joomla
cd frankenphp-joomla
docker compose pull --include-deps
POSTGRES_PASSWORD="$(docker run --rm dunglas/frankenphp php -r 'echo bin2hex(random_bytes(12));')" docker compose up --build
```

Your Joomla website is available on `https://localhost:{random_ephemeral_port}`.

In this case `{random_ephemeral_port}` is the first random port that is available that does not conflict with other
services. `e.g. 51042`

Check `docker compose ps` to find the ephemeral port used. It prevents port clashing (open ports conflicts).

Check `docker compose logs webapp` to find your credentials.
