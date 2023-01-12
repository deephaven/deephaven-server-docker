# syntax=docker/dockerfile:1.4

ARG UBUNTU_TAG
ARG OPENJDK_VERSION

# -------------------------------------

FROM docker.io/eclipse-temurin:${OPENJDK_VERSION} as openjdk

# -------------------------------------

FROM --platform=linux/amd64 server-scratch as server-scratch-amd64

# -------------------------------------

FROM docker.io/ubuntu:${UBUNTU_TAG} as os-packages-impl
ARG DEBIAN_FRONTEND="noninteractive"
ARG TARGETARCH
ARG UBUNTU_TAG
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETARCH}-${UBUNTU_TAG} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${TARGETARCH}-${UBUNTU_TAG} \
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
ENV \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'
LABEL \
    io.deephaven.server.ubuntu.version="${UBUNTU_TAG}" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0" \
    org.opencontainers.image.authors="developers@deephaven.io" \
    org.opencontainers.image.base.name="docker.io/ubuntu:${UBUNTU_TAG}" \
    org.opencontainers.image.source="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.url="https://github.com/deephaven/deephaven-server-docker"

# -------------------------------------

FROM os-packages-impl as slim-base-impl
ARG GRPC_HEALTH_PROBE_VERSION
ARG OPENJDK_VERSION
ARG TARGETARCH
ADD --link --chmod=755 https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} /opt/grpc_health_probe/grpc_health_probe
COPY --link --from=openjdk /opt/java/openjdk /opt/java/openjdk
ENV \
    JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:${PATH}"
LABEL \
    io.deephaven.server.java.version="${OPENJDK_VERSION}" \
    io.deephaven.server.java.base.name="docker.io/eclipse-temurin:${OPENJDK_VERSION}" \
    io.deephaven.server.grpc-health-probe.version="${GRPC_HEALTH_PROBE_VERSION}"

# -------------------------------------

FROM slim-base-impl as groovy-base
LABEL \
    io.deephaven.image.type="server-slim-base" \
    org.opencontainers.image.title="Deephaven Slim Base" \
    org.opencontainers.image.description="Deephaven Slim Base"

# -------------------------------------

FROM slim-base-impl as groovy
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
COPY --link --from=server-scratch-amd64 /opt/deephaven /opt/deephaven
COPY --link groovy/deephaven.prop /opt/deephaven/config/deephaven.prop
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
    io.deephaven.image.type="server-slim" \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    org.opencontainers.image.title="Deephaven Slim Server" \
    org.opencontainers.image.description="Deephaven Slim Server" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"

# -------------------------------------

FROM os-packages-impl as python-packages-impl
ARG DEBIAN_FRONTEND="noninteractive"
ARG PYTHON_VERSION
ARG TARGETARCH
ARG UBUNTU_TAG
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETARCH}-${UBUNTU_TAG} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${TARGETARCH}-${UBUNTU_TAG} \
    set -eux; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install \
        libpython${PYTHON_VERSION} \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-venv
LABEL \
    io.deephaven.server.python.version="${PYTHON_VERSION}"

# -------------------------------------

FROM python-packages-impl as python-base-impl
ARG GRPC_HEALTH_PROBE_VERSION
ARG OPENJDK_VERSION
ARG TARGETARCH
ADD --link --chmod=755 https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} /opt/grpc_health_probe/grpc_health_probe
COPY --link --from=openjdk /opt/java/openjdk /opt/java/openjdk
ENV \
    JAVA_HOME="/opt/java/openjdk" \
    PATH="/opt/java/openjdk/bin:${PATH}"
LABEL \
    io.deephaven.server.java.version="${OPENJDK_VERSION}" \
    io.deephaven.server.java.base.name="docker.io/eclipse-temurin:${OPENJDK_VERSION}" \
    io.deephaven.server.grpc-health-probe.version="${GRPC_HEALTH_PROBE_VERSION}"

# -------------------------------------

FROM python-base-impl as python-base
LABEL \
    io.deephaven.image.type="server-base" \
    org.opencontainers.image.title="Deephaven Server Base" \
    org.opencontainers.image.description="Deephaven Server Base"

# -------------------------------------

FROM python-base-impl as python
ARG DEEPHAVEN_VERSION
ARG DEEPHAVEN_SHA256SUM
ARG REQUIREMENTS_DIR
ARG PYTHON_VERSION
RUN \
    --mount=type=bind,source=${REQUIREMENTS_DIR},target=./requirements \
    --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    set -eux; \
    python${PYTHON_VERSION} -m venv /opt/deephaven/venv; \
    /opt/deephaven/venv/bin/pip install --upgrade pip setuptools; \
    /opt/deephaven/venv/bin/pip install --only-binary=:all: -r ./requirements/requirements.txt
COPY --link --from=server-scratch-amd64 /opt/deephaven /opt/deephaven
COPY --link python/deephaven.prop /opt/deephaven/config/deephaven.prop
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENV \
    VIRTUAL_ENV="/opt/deephaven/venv" \
    PATH="/opt/deephaven/venv/bin:${PATH}" \
    DEEPHAVEN_CACHE_DIR="/cache" \
    DEEPHAVEN_CONFIG_DIR="/opt/deephaven/config" \
    DEEPHAVEN_DATA_DIR="/data"
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start"]
HEALTHCHECK --interval=3s --retries=3 --timeout=11s CMD /opt/grpc_health_probe/grpc_health_probe -addr=localhost:10000 -connect-timeout=10s || exit 1
LABEL \
    io.deephaven.image.type="server" \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}" \
    io.deephaven.server.checksum="${DEEPHAVEN_SHA256SUM}" \
    org.opencontainers.image.title="Deephaven Server" \
    org.opencontainers.image.description="Deephaven Server" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"

# -------------------------------------
