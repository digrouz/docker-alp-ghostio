# docker-alp-ghostio
Installs ghost.io into an Alpine Linux container

![ghost](https://ghost.org/logo.svg)

## Description

Ghost is a fully open source, hackable platform for building and running a modern online publication.

https://ghost.org/developers/

## Usage
    docker create --name=ghost  \
      -v /etc/localtime:/etc/localtime:ro \
      -v <path to config.js>/config.js:/ghost/config.js \
      -v <path to content>:/ghost/content \
      -e DOCKUID=<UID default:10010> \
      -e DOCKGID=<GID default:10010> \
      -p 2368:2368 digrouz/docker-alp-ghostio

## Environment Variables

When you start the `ghost` image, you can adjust the configuration of the `ghost` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10010`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10010`.

## Notes

* The docker entrypoint will upgrade operating system at each startup.

