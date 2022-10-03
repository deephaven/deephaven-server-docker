# syntax=docker/dockerfile:1.4

# ----------------------------------------------------------------------------

FROM busybox as untarred
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG DEEPHAVEN_HOME=/opt/deephaven
ADD --link https://github.com/deephaven/deephaven-core/releases/download/v${DEEPHAVEN_VERSION}/server-jetty-${DEEPHAVEN_VERSION}.tar .
RUN set -eux; \
    echo "${DEEPHAVEN_SHA256SUM}  server-jetty-${DEEPHAVEN_VERSION}.tar" | sha256sum -c -; \
    mkdir -p ${DEEPHAVEN_HOME}; \
    tar -xf server-jetty-${DEEPHAVEN_VERSION}.tar -C ${DEEPHAVEN_HOME}; \
    ln -s ${DEEPHAVEN_HOME}/server-jetty-${DEEPHAVEN_VERSION} ${DEEPHAVEN_HOME}/server-jetty

# ----------------------------------------------------------------------------

FROM scratch as server-scratch
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG DEEPHAVEN_HOME=/opt/deephaven
COPY --link --from=untarred ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server-scratch" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server Scratch" \
    org.opencontainers.image.description="Deephaven Server Scratch" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0"

# ----------------------------------------------------------------------------
#
# The construction below is meant to present the same output as above,
# but with a local .tar file. This is useful for development purposes.
#
# ----------------------------------------------------------------------------

FROM busybox as untarred-local
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG DEEPHAVEN_HOME=/opt/deephaven
COPY --link server-jetty-${DEEPHAVEN_VERSION}.tar .
RUN set -eux; \
    echo "${DEEPHAVEN_SHA256SUM}  server-jetty-${DEEPHAVEN_VERSION}.tar" | sha256sum -c -; \
    mkdir -p ${DEEPHAVEN_HOME}; \
    tar -xf server-jetty-${DEEPHAVEN_VERSION}.tar -C ${DEEPHAVEN_HOME}; \
    ln -s ${DEEPHAVEN_HOME}/server-jetty-${DEEPHAVEN_VERSION} ${DEEPHAVEN_HOME}/server-jetty

# ----------------------------------------------------------------------------

FROM scratch as server-scratch-local
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG DEEPHAVEN_HOME=/opt/deephaven
COPY --link --from=untarred-local ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server-scratch" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server Scratch" \
    org.opencontainers.image.description="Deephaven Server Scratch" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0"

# ----------------------------------------------------------------------------
