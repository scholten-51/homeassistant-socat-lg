ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache socat jq

COPY rootfs /
RUN chmod +x /etc/services.d/socat/run
