FROM amazoncorretto:21-alpine

RUN apk add --no-cache curl jq micro lsof libpcap libwebp libcap libstdc++

LABEL nickname=SrDregon github=https://github.com/yanpgabriel

ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} minecraft
RUN adduser -Ss /bin/false -u ${UID} -G minecraft -h /minecraft minecraft

RUN mkdir /scripts

COPY ../scripts/*.sh /scripts

RUN chmod 777 -R /scripts

USER minecraft

VOLUME /minecraft

WORKDIR /minecraft

EXPOSE 25565/TCP
EXPOSE 25565/UDP

ENV VERSION=latest
ENV BUILD=latest

ENTRYPOINT /scripts/entrypoint.sh
