# Joomla on FrankenPHP

Run the popular [Joomla CMS](https://joomla.org) on top of [FrankenPHP](https://frankenphp.dev),  
the modern app server for PHP.

## Getting Started

In your terminal (Linux and Unix or WSL2 on Windows) type:

1. Clone the repository

```shell
git clone https://github.com/alexandreelise/frankenphp-joomla &&  
cd frankenphp-joomla  
```

2. Run this command in your Terminal (Command-line)

```shell
docker compose up --remove-orphans --detach   
```

Your Joomla website is available on `https://10.210.21.42`

Check `docker container ps --filter name=frankenphp-joomla-*` to find the ephemeral port used. It prevents port clashing (open ports conflicts).

Check `.env` file to find your credentials.

## BUILD YOUR OWN

1. Clone the repository

```shell
git clone https://github.com/alexandreelise/frankenphp-joomla &&  
cd frankenphp-joomla  
```

2. Change values in .env file as you wish then

3. Build your own docker image


```shell
docker compose build --no-cache  
```
