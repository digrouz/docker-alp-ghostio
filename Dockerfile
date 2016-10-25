# vim:set ft=dockerfile:
FROM alpine:latest
MAINTAINER DI GREGORIO Nicolas <nicolas.digregorio@gmail.com>

### Environment variables
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' 

### Install Application
RUN apk --no-cache upgrade && \
    apk add --no-cache --virtual=build-deps \
      unzip \
      curl && \
    apk add --no-cache --virtual=run-deps \
      nodejs-lts \
      su-exec && \
	curl -L https://ghost.org/zip/ghost-latest.zip -o /tmp/ghost.zip && \
	mkdir /ghost && \
	unzip -uo /tmp/ghost.zip -d /ghost && \
	cd /ghost && \
	npm install --production && \
    apk del --no-cache --purge \
      build-deps  && \
    rm -rf /tmp/* \
           /var/cache/apk/*  \
           /var/tmp/*

### Volume
#VOLUME ["/ghost"]

### Expose ports
EXPOSE 2368

### Running User: not used, managed by docker-entrypoint.sh
#USER ghost

### Start Mezzanine
#COPY ./docker-entrypoint.sh /
#ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ghost"]
