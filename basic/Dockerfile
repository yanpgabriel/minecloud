FROM openjdk:21-jdk

RUN apt update -y && apt install -y curl jq

LABEL SrDregon https://github.com/yanpgabriel

ENV VERSION=1.20.2


VOLUME "/server"
WORKDIR /server

EXPOSE 25565/TCP
EXPOSE 25565/UDP