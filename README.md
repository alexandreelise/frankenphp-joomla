# Joomla on FrankenPHP

Run the popular [Joomla CMS](https://joomla.org) on top of [FrankenPHP](https://frankenphp.dev),
the modern app server for PHP.

## Getting Started

In your terminal (Linux and Unix or WSL2 on Windows) type: 

```

git clone https://github.com/alexandreelise/frankenphp-joomla &&
cd frankenphp-joomla &&
docker compose pull &&
docker compose build --no-cache &&
docker compose up --remove-orphans --detach &&
docker compose logs --follow webapp 

```

Your Joomla website is available on `https://10.210.21.42:{random_ephemeral_port}`.

In this case `{random_ephemeral_port}` is the first random port that is available that does not conflict with other
services. `e.g. 51042`

Check `docker container ps --filter name=frankenphp-joomla-*` to find the ephemeral port used. It prevents port clashing (open ports conflicts).

Check `.env` file to find your credentials.
