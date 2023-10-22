FROM openjdk:21-jdk

RUN apt update -y && apt install -y curl jq

LABEL SrDregon https://github.com/yanpgabriel

ENV VERSION=latest

COPY ../getpaperserver.sh /usr/local/bin

RUN chmod +x /usr/local/bin/getpaperserver.sh

RUN useradd --create-home --shell /bin/bash minecraft \
 && mkdir -p /opt/papermc /var/opt/papermc \
 && chown -R minecraft /var/opt/papermc/

USER minecraft

WORKDIR /var/opt/papermc
VOLUME /var/opt/papermc

EXPOSE 25565/TCP
EXPOSE 25565/UDP