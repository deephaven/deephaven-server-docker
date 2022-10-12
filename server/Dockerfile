# syntax=docker/dockerfile:1.4

ARG UBUNTU_TAG
ARG OPENJDK_VERSION

# -------------------------------------

FROM eclipse-temurin:${OPENJDK_VERSION} as openjdk

# -------------------------------------

FROM ubuntu:${UBUNTU_TAG} as base
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEEPHAVEN_HOME=/opt/deephaven
RUN set -eux; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install \
        liblzo2-2 \
        tzdata \
        ca-certificates \
        locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8; \
    rm -rf /var/lib/apt/lists/*

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.13
ARG TARGETARCH
ADD --link --chmod=755 https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} /opt/grpc_health_probe/grpc_health_probe

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    JAVA_HOME=/opt/java/openjdk \
    DEEPHAVEN_HOME=${DEEPHAVEN_HOME}

# -------------------------------------

FROM base as python-base
ARG DEBIAN_FRONTEND="noninteractive"
ARG PYTHON_VERSION
RUN set -eux; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install \
        libpython${PYTHON_VERSION} \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-venv; \
    rm -rf /var/lib/apt/lists/*; \
    python${PYTHON_VERSION} -m venv ${DEEPHAVEN_HOME}/venv; \
    ${DEEPHAVEN_HOME}/venv/bin/pip install --no-cache-dir --upgrade pip setuptools
ARG REQUIREMENTS_DIR
RUN --mount=type=bind,source=${REQUIREMENTS_DIR},target=./requirements \
    set -eux; \
    ${DEEPHAVEN_HOME}/venv/bin/pip \
        install \
        --no-cache-dir \
        --only-binary=:all: \
        -r ./requirements/requirements.txt
ENV VIRTUAL_ENV="${DEEPHAVEN_HOME}/venv" \
    PATH="${DEEPHAVEN_HOME}/venv/bin:${PATH}"
# TODO: add requirements.txt into .tar, or as separate release artifact?

# -------------------------------------

FROM --platform=linux/amd64 server-scratch as server-scratch-amd64

# -------------------------------------

FROM base as groovy
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
COPY --link --from=openjdk ${JAVA_HOME} ${JAVA_HOME}
COPY --link --from=server-scratch-amd64 ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link groovy/image-bootstrap.properties ${DEEPHAVEN_HOME}/config/image-bootstrap.properties
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start", "/opt/deephaven/config/image-bootstrap.properties"]
HEALTHCHECK --interval=3s --retries=3 --timeout=11s CMD /opt/grpc_health_probe/grpc_health_probe -addr=localhost:10000 -connect-timeout=10s || exit 1
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server-slim" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0"

# -------------------------------------

FROM python-base as python
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
COPY --link --from=openjdk ${JAVA_HOME} ${JAVA_HOME}
COPY --link --from=server-scratch-amd64 ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link python/image-bootstrap.properties ${DEEPHAVEN_HOME}/config/image-bootstrap.properties
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start", "/opt/deephaven/config/image-bootstrap.properties"]
HEALTHCHECK --interval=3s --retries=3 --timeout=11s CMD /opt/grpc_health_probe/grpc_health_probe -addr=localhost:10000 -connect-timeout=10s || exit 1
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    io.deephaven.image.type="server" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0"

# -------------------------------------
