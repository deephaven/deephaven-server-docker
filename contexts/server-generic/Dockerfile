# syntax=docker/dockerfile:1.4

ARG GENERIC_JAVA_BASE
FROM $GENERIC_JAVA_BASE
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG GRPC_HEALTH_PROBE_VERSION
ARG TARGETARCH
ADD --link --chmod=755 https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} /opt/grpc_health_probe/grpc_health_probe
COPY --link --from=server-scratch /opt/deephaven /opt/deephaven
COPY --link deephaven.prop /opt/deephaven/config/deephaven.prop
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENV \
    DEEPHAVEN_CACHE_DIR="/cache" \
    DEEPHAVEN_CONFIG_DIR="/opt/deephaven/config" \
    DEEPHAVEN_DATA_DIR="/data"
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start"]
HEALTHCHECK --interval=3s --retries=3 --timeout=11s CMD /opt/grpc_health_probe/grpc_health_probe -addr=localhost:10000 -connect-timeout=10s || exit 1
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server-generic" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0"
