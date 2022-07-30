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
    rm -rf /var/lib/apt/lists/*
RUN --mount=type=bind,source=./python/requirements.txt,target=./python/requirements.txt \
    set -eux; \
    python${PYTHON_VERSION} -m venv ${DEEPHAVEN_HOME}/venv; \
    ${DEEPHAVEN_HOME}/venv/bin/pip install --no-cache-dir -r ./python/requirements.txt
ENV VIRTUAL_ENV="${DEEPHAVEN_HOME}/venv" \
    PATH="${DEEPHAVEN_HOME}/venv/bin:${PATH}"
# TODO: add requirements.txt into .tar, or as separate release artifact?

# -------------------------------------

FROM --platform=linux/amd64 server-scratch as server-scratch-amd64

# -------------------------------------

FROM base as groovy
COPY --link --from=openjdk ${JAVA_HOME} ${JAVA_HOME}
COPY --link --from=server-scratch-amd64 ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link groovy/image-bootstrap.properties ${DEEPHAVEN_HOME}/config/image-bootstrap.properties
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start", "/opt/deephaven/config/image-bootstrap.properties"]

# -------------------------------------

FROM python-base as python
COPY --link --from=openjdk ${JAVA_HOME} ${JAVA_HOME}
COPY --link --from=server-scratch-amd64 ${DEEPHAVEN_HOME} ${DEEPHAVEN_HOME}
COPY --link python/image-bootstrap.properties ${DEEPHAVEN_HOME}/config/image-bootstrap.properties
VOLUME /data
VOLUME /cache
EXPOSE 10000
ENTRYPOINT ["/opt/deephaven/server-jetty/bin/start", "/opt/deephaven/config/image-bootstrap.properties"]

# -------------------------------------
