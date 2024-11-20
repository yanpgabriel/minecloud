FROM amazoncorretto:21-alpine

RUN apk add --no-cache curl jq micro lsof libpcap libwebp libcap libstdc++

LABEL nickname=SrDregon github=https://github.com/yanpgabriel

RUN addgroup -g 1000 minecraft
RUN adduser -Ss /bin/false -u 1000 -G minecraft -h /minecraft minecraft

RUN mkdir /scripts

COPY ../scripts/*.sh /scripts

RUN chmod 605 -R /scripts

USER minecraft

VOLUME /minecraft

WORKDIR /minecraft

EXPOSE 25565/TCP
EXPOSE 25565/UDP

ENV VERSION=latest
ENV BUILD=latest

ENTRYPOINT /scripts/entrypoint.sh
