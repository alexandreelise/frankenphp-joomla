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
Your Joomla website is available on `https://localhost`.
Check `docker-compose.yml` to find DB credentials.
