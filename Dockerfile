# ----------------------------------
# Sacred 2 Lobby Emulator Dockerfile
# Environment: Mono
# Minimum Panel Version: 1.3.1
# ----------------------------------
FROM        frolvlad/alpine-mono

MAINTAINER  Pipe of Destiny Clan, <pterodactyl@pipeofdestiny.com>

RUN         apk update \
            && apk add --no-cache openssl curl sqlite xmlstarlet \
            && adduser -D -h /home/container container

USER        container
ENV         HOME=/home/container USER=container
WORKDIR     /home/container

COPY        ./lobby.config.template /lobby.config.template
COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/ash", "/entrypoint.sh"]
