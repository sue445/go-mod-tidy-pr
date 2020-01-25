FROM golang

RUN apt-get update \
 && apt-get install -y hub \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
