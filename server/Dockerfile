# syntax=docker/dockerfile:1.4

ARG UBUNTU_TAG
ARG OPENJDK_VERSION

# -------------------------------------

FROM docker.io/eclipse-temurin:${OPENJDK_VERSION} as openjdk

# -------------------------------------

FROM --platform=linux/amd64 server-scratch as server-scratch-amd64

# -------------------------------------

FROM docker.io/ubuntu:${UBUNTU_TAG} as os-packages
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEEPHAVEN_HOME=/opt/deephaven
ARG TARGETARCH
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${TARGETARCH} \
    set -eux; \
    rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee /etc/apt/apt.conf.d/keep-cache; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install \
        liblzo2-2 \
        tzdata \
        ca-certificates \
        locales; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; \
    locale-gen en_US.UTF-8

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    DEEPHAVEN_HOME=${DEEPHAVEN_HOME}

# -------------------------------------

FROM os-packages as groovy-base
COPY --link --from=openjdk /opt/java/openjdk /opt/java/openjdk
ARG GRPC_HEALTH_PROBE_VERSION=v0.4.14
ARG TARGETARCH
ADD --link --chmod=755 https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} /opt/grpc_health_probe/grpc_health_probe
ENV \
    JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:${PATH}"

# -------------------------------------

FROM groovy-base as groovy
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG UBUNTU_TAG
COPY --link --from=server-scratch-amd64 ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link groovy/deephaven.prop ${DEEPHAVEN_HOME}/config/deephaven.prop
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
    io.deephaven.image.type="server-slim" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0" \
    org.opencontainers.image.authors="developers@deephaven.io" \
    org.opencontainers.image.base.name="docker.io/ubuntu:${UBUNTU_TAG}" \
    org.opencontainers.image.source="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.url="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"

# -------------------------------------

FROM os-packages as python-packages
ARG DEBIAN_FRONTEND="noninteractive"
ARG PYTHON_VERSION
ARG TARGETARCH
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${TARGETARCH} \
    --mount=type=cache,target=/root/.cache/pip,sharing=locked,id=pip-${TARGETARCH} \
    set -eux; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install \
        libpython${PYTHON_VERSION} \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-venv; \
    python${PYTHON_VERSION} -m venv ${DEEPHAVEN_HOME}/venv; \
    ${DEEPHAVEN_HOME}/venv/bin/pip install --upgrade pip setuptools
ENV \
    VIRTUAL_ENV="${DEEPHAVEN_HOME}/venv" \
    PATH="${DEEPHAVEN_HOME}/venv/bin:${PATH}"

# -------------------------------------

FROM python-packages as python-base
ARG GRPC_HEALTH_PROBE_VERSION=v0.4.14
ARG TARGETARCH
ADD --link --chmod=755 https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} /opt/grpc_health_probe/grpc_health_probe
COPY --link --from=openjdk /opt/java/openjdk /opt/java/openjdk
ENV \
    JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:${PATH}"

# -------------------------------------

FROM python-base as python
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG UBUNTU_TAG
ARG REQUIREMENTS_DIR
ARG TARGETARCH
RUN \
    --mount=type=bind,source=${REQUIREMENTS_DIR},target=./requirements \
    --mount=type=cache,target=/root/.cache/pip,sharing=locked,id=pip-${TARGETARCH} \
    set -eux; \
    ${DEEPHAVEN_HOME}/venv/bin/pip \
        install \
        --only-binary=:all: \
        -r ./requirements/requirements.txt
COPY --link --from=server-scratch-amd64 ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link python/deephaven.prop ${DEEPHAVEN_HOME}/config/deephaven.prop
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
    io.deephaven.image.type="server" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0" \
    org.opencontainers.image.authors="developers@deephaven.io" \
    org.opencontainers.image.base.name="docker.io/ubuntu:${UBUNTU_TAG}" \
    org.opencontainers.image.source="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.url="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"

# -------------------------------------
