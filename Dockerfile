FROM ubuntu:20.04

ENV HUB_VERSION 2.14.1
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget git curl jq tzdata

RUN wget --quiet https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz \
 && tar -xzf hub-linux-amd64-${HUB_VERSION}.tgz \
 && mv hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin/hub \
 && chmod 755 /usr/local/bin/hub \
 && rm -rf hub-linux-amd64-${HUB_VERSION} hub-linux-amd64-${HUB_VERSION}.tgz

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
