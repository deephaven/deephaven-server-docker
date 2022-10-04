# syntax=docker/dockerfile:1.4

ARG GENERIC_JAVA_BASE
FROM $GENERIC_JAVA_BASE
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG DEEPHAVEN_HOME=/opt/deephaven
COPY --link --from=server-scratch ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link groovy/image-bootstrap.properties ${DEEPHAVEN_HOME}/config/image-bootstrap.properties
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENV DEEPHAVEN_HOME=${DEEPHAVEN_HOME}
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start", "/opt/deephaven/config/image-bootstrap.properties"]
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server-generic" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0"
