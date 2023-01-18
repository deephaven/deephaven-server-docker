# syntax=docker/dockerfile:1.4

ARG OPENJDK_VERSION
ARG UBUNTU_VERSION

# -------------------------------------

FROM docker.io/eclipse-temurin:${OPENJDK_VERSION} as openjdk

# -------------------------------------

FROM docker.io/library/busybox as deephaven
ARG DEEPHAVEN_VERSION
ADD --link https://github.com/deephaven/deephaven-core/releases/download/v${DEEPHAVEN_VERSION}/server-jetty-${DEEPHAVEN_VERSION}.tar .
RUN \
    set -eux; \
    mkdir -p /opt/deephaven; \
    tar -xf server-jetty-${DEEPHAVEN_VERSION}.tar -C /opt/deephaven; \
    ln -s /opt/deephaven/server-jetty-${DEEPHAVEN_VERSION} /opt/deephaven/server-jetty

# -------------------------------------

FROM docker.io/ubuntu:${UBUNTU_VERSION} as os-bits
ARG DEBIAN_FRONTEND="noninteractive"
ARG TARGETARCH
ARG UBUNTU_VERSION
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETARCH}-${UBUNTU_VERSION} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${TARGETARCH}-${UBUNTU_VERSION} \
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
    io.deephaven.server.ubuntu.version="${UBUNTU_VERSION}" \
    org.opencontainers.image.vendor="Deephaven Data Labs" \
    org.opencontainers.image.licenses="Deephaven Community License Agreement 1.0" \
    org.opencontainers.image.authors="developers@deephaven.io" \
    org.opencontainers.image.base.name="docker.io/ubuntu:${UBUNTU_VERSION}" \
    org.opencontainers.image.source="https://github.com/deephaven/deephaven-server-docker" \
    org.opencontainers.image.url="https://github.com/deephaven/deephaven-server-docker"

# -------------------------------------

FROM os-bits as openjdk-bits
ARG OPENJDK_VERSION
COPY --link --from=openjdk /opt/java/openjdk /opt/java/openjdk
ENV \
    JAVA_HOME="/opt/java/openjdk" \
    PATH="/opt/java/openjdk/bin:${PATH}"
LABEL \
    io.deephaven.server.java.version="${OPENJDK_VERSION}" \
    io.deephaven.server.java.base.name="docker.io/eclipse-temurin:${OPENJDK_VERSION}"

# -------------------------------------

FROM openjdk-bits as deephaven-bits
ARG DEEPHAVEN_VERSION
COPY --link --from=deephaven /opt/deephaven /opt/deephaven
LABEL \
    io.deephaven.server.version="${DEEPHAVEN_VERSION}"

# -------------------------------------

FROM deephaven-bits as grpc-health-probe-bits
ARG GRPC_HEALTH_PROBE_VERSION
ADD --link --chmod=755 \
    https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} \
    /opt/grpc_health_probe/grpc_health_probe
LABEL \
    io.deephaven.server.grpc-health-probe.version="${GRPC_HEALTH_PROBE_VERSION}"

# -------------------------------------

FROM grpc-health-probe-bits as server-slim
COPY --link deephaven.prop /opt/deephaven/config/deephaven.prop
EXPOSE 10000
VOLUME /data
VOLUME /cache
ENV \
    DEEPHAVEN_CACHE_DIR="/cache" \
    DEEPHAVEN_CONFIG_DIR="/opt/deephaven/config" \
    DEEPHAVEN_DATA_DIR="/data"
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start"]
HEALTHCHECK --interval=3s --retries=3 --timeout=11s CMD /opt/grpc_health_probe/grpc_health_probe -addr=localhost:10000 -connect-timeout=10s || exit 1
LABEL \
    io.deephaven.image.type="server-slim" \
    org.opencontainers.image.title="Deephaven Server Slim" \
    org.opencontainers.image.description="Deephaven Server Slim" \
    org.opencontainers.image.version="${DEEPHAVEN_VERSION}"
