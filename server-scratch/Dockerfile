# syntax=docker/dockerfile:1.4

# -------------------------------------

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

# -------------------------------------

FROM scratch as server-scratch
ARG DEEPHAVEN_HOME=/opt/deephaven
COPY --link --from=untarred ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}

# -------------------------------------
