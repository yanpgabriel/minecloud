FROM openjdk:21-jdk

# RUN apt update -y && apt install -y curl jq

LABEL SrDregon https://github.com/yanpgabriel

ENV VERSION=latest

RUN useradd --create-home --shell /bin/bash minecraft

WORKDIR /home/minecraft/data

RUN mkdir -p /home/minecraft/data

COPY ../getpaperserver.sh .
COPY ../start.sh .

RUN chown -R minecraft .
RUN chmod +x *.sh

USER minecraft

VOLUME /home/minecraft/data

EXPOSE 25565/TCP
EXPOSE 25565/UDP

CMD ./start.sh
