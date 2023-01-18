# syntax=docker/dockerfile:1.4

# ----------------------------------------------------------------------------

FROM docker.io/library/busybox as untarred
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ADD --link https://github.com/deephaven/deephaven-core/releases/download/v${DEEPHAVEN_VERSION}/server-jetty-${DEEPHAVEN_VERSION}.tar .
RUN set -eux; \
    echo "${DEEPHAVEN_SHA256SUM}  server-jetty-${DEEPHAVEN_VERSION}.tar" | sha256sum -c -; \
    mkdir -p /opt/deephaven; \
    tar -xf server-jetty-${DEEPHAVEN_VERSION}.tar -C /opt/deephaven; \
    ln -s /opt/deephaven/server-jetty-${DEEPHAVEN_VERSION} /opt/deephaven/server-jetty

# ----------------------------------------------------------------------------

FROM scratch as server-scratch
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
COPY --link --from=untarred /opt/deephaven /opt/deephaven
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server-scratch" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server Scratch" \
    org.opencontainers.image.description="Deephaven Server Scratch" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0" \
    org.opencontainers.image.authors="developers@deephaven.io" \
    org.opencontainers.image.base.name="scratch" \
    org.opencontainers.image.source="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.url="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"

# ----------------------------------------------------------------------------
#
# The construction below is meant to present the same output as above,
# but with a local .tar file. This is useful for development purposes.
#
# ----------------------------------------------------------------------------

FROM docker.io/library/busybox as untarred-local
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
COPY --link server-jetty-${DEEPHAVEN_VERSION}.tar .
RUN set -eux; \
    echo "${DEEPHAVEN_SHA256SUM}  server-jetty-${DEEPHAVEN_VERSION}.tar" | sha256sum -c -; \
    mkdir -p /opt/deephaven; \
    tar -xf server-jetty-${DEEPHAVEN_VERSION}.tar -C /opt/deephaven; \
    ln -s /opt/deephaven/server-jetty-${DEEPHAVEN_VERSION} /opt/deephaven/server-jetty

# ----------------------------------------------------------------------------

FROM scratch as server-scratch-local
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
COPY --link --from=untarred-local /opt/deephaven /opt/deephaven
LABEL \
    io.deephaven.image.type="server-scratch" \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server Scratch" \
    org.opencontainers.image.description="Deephaven Server Scratch" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0" \
    org.opencontainers.image.authors="developers@deephaven.io" \
    org.opencontainers.image.base.name="scratch" \
    org.opencontainers.image.source="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.url="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"

# ----------------------------------------------------------------------------
