# syntax=docker/dockerfile:1.4

ARG OPENJDK_VERSION
ARG UBUNTU_VERSION

# -------------------------------------

FROM docker.io/library/amazoncorretto:${OPENJDK_VERSION} as openjdk
ARG OPENJDK_VERSION
# Safety check: the final image hard-codes JAVA_HOME as /usr/lib/jvm/java-${OPENJDK_VERSION}-amazon-corretto, so fail
# the build if the amazoncorretto image doesn't provide that same JAVA_HOME (and a working JDK there).
# Corretto's JAVA_HOME is a symlink into /etc/alternatives, which points at an arch-specific directory
# (e.g. java-25-amazon-corretto.x86_64). Replace it with a direct relative symlink so that copying just
# /usr/lib/jvm yields a working JDK.
RUN \
    set -eux; \
    expected="/usr/lib/jvm/java-${OPENJDK_VERSION}-amazon-corretto"; \
    [ "${JAVA_HOME}" = "${expected}" ] || { echo "Unexpected JAVA_HOME='${JAVA_HOME}', expected '${expected}'" >&2; exit 1; }; \
    real="$(readlink -f "${expected}")"; \
    rm "${expected}"; \
    ln -s "$(basename "${real}")" "${expected}"; \
    "${expected}/bin/java" -version

# -------------------------------------

FROM docker.io/ubuntu:${UBUNTU_VERSION} as os-bits
ARG DEBIAN_FRONTEND="noninteractive"
ARG TARGETARCH
ARG UBUNTU_VERSION
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${TARGETARCH}-${UBUNTU_VERSION} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib-${TARGETARCH}-${UBUNTU_VERSION} \
    set -eux; \
    rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee /etc/apt/apt.conf.d/keep-cache; \
    apt-get -qq update; \
    # fontconfig necessary until https://github.com/deephaven/deephaven-core/issues/3330 is fixed
    apt-get -qq -y --no-install-recommends install \
        liblzo2-2 \
        tzdata \
        ca-certificates \
        locales \
        fontconfig \
        ; \
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

# This stage is done later to help with earlier layer cacheability
FROM os-bits as custom-bits
ARG DEBIAN_FRONTEND="noninteractive"
ARG TARGETARCH
ARG UBUNTU_VERSION

# curl is necessary for some kafka integration testing
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-cache-${TARGETARCH}-${UBUNTU_VERSION} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-lib-${TARGETARCH}-${UBUNTU_VERSION} \
    set -eux; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install curl

# -------------------------------------

FROM custom-bits as openjdk-bits
ARG OPENJDK_VERSION
# Corretto installs into an arch-specific directory plus a version symlink (see the openjdk stage);
# copy the whole directory to keep both, and use the same JAVA_HOME as the amazoncorretto image.
COPY --link --from=openjdk /usr/lib/jvm /usr/lib/jvm
ENV \
    JAVA_HOME="/usr/lib/jvm/java-${OPENJDK_VERSION}-amazon-corretto" \
    PATH="/usr/lib/jvm/java-${OPENJDK_VERSION}-amazon-corretto/bin:${PATH}"
LABEL \
    io.deephaven.server.java.version="${OPENJDK_VERSION}" \
    io.deephaven.server.java.base.name="docker.io/library/amazoncorretto:${OPENJDK_VERSION}"

# -------------------------------------

FROM openjdk-bits as grpc-health-probe-bits
ARG GRPC_HEALTH_PROBE_VERSION
ADD --link --chmod=755 \
    https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-${TARGETARCH} \
    /opt/grpc_health_probe/grpc_health_probe
LABEL \
    io.deephaven.server.grpc-health-probe.version="${GRPC_HEALTH_PROBE_VERSION}"

# -------------------------------------

FROM grpc-health-probe-bits as server-slim-base
LABEL \
    io.deephaven.image.type="server-slim-base" \
    org.opencontainers.image.title="Deephaven Server Slim Base" \
    org.opencontainers.image.description="Deephaven Server Slim Base"
