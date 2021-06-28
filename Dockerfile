FROM quay.io/prometheus/golang-builder AS builder

# Get sql_exporter
ADD .   /go/src/github.com/free/sql_exporter
WORKDIR /go/src/github.com/free/sql_exporter

# Do makefile
RUN make

# Make image and copy build sql_exporter
FROM        alpine:latest
MAINTAINER  The Prometheus Authors <prometheus-developers@googlegroups.com>
COPY        --from=builder /go/src/github.com/free/sql_exporter/sql_exporter  /bin/sql_exporter
ENV GLIBC_VER=2.31-r0

RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

EXPOSE      9399
ENTRYPOINT  [ "/bin/sql_exporter" ]
