# Joomla on FrankenPHP

Run the popular [Joomla CMS](https://joomla.org) on top of [FrankenPHP](https://frankenphp.dev),
the modern app server for PHP.

## Getting Started

```
git clone https://github.com/alexandreelise/frankenphp-joomla
cd frankenphp-joomla
docker compose pull --include-deps
docker compose up
```

Your Joomla website is available on `https://localhost:{random_ephemeral_port}`.

In this case `{random_ephemeral_port}` is the first random port that is available that does not conflict with other
services. `e.g. 51042`

Check `docker compose ps` to find the ephemeral port used. It prevents port clashing (open ports conflicts).

Check `docker-compose.yml` to find DB credentials.
