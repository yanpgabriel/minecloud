FROM amazoncorretto:25-alpine

RUN apk add --no-cache tzdata curl jq micro lsof libpcap libwebp libcap libstdc++ bash
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN apk del tzdata

LABEL nickname=SrDregon github=https://github.com/yanpgabriel

ARG UID=1000
ARG GID=1000

RUN addgroup -g ${GID} minecraft
RUN adduser -Ss /bin/false -u ${UID} -G minecraft -h /minecraft minecraft

RUN mkdir /scripts

COPY ../scripts/*.sh /scripts

RUN chmod 755 -R /scripts

USER minecraft

VOLUME /minecraft

WORKDIR /minecraft

EXPOSE 25565/TCP
EXPOSE 25565/UDP

ENV VERSION=latest
ENV BUILD=latest

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
  CMD bash -c 'exec 3<>/dev/tcp/127.0.0.1/25565' || exit 1

ENTRYPOINT /scripts/entrypoint.sh
