# syntax=docker/dockerfile:1.4

ARG PYTHON_VERSION

FROM python:${PYTHON_VERSION} as build
ARG DEBIAN_FRONTEND="noninteractive"
ARG TARGETARCH
RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${TARGETARCH} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${TARGETARCH} \
    set -eux; \
    rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' | tee /etc/apt/apt.conf.d/keep-cache; \
    apt-get -qq update; \
    apt-get -qq -y --no-install-recommends install libboost-all-dev unixodbc-dev

RUN \
    --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    set -eux; \
    pip install --only-binary=:all: -r requirements.txt

# Ensure requirements.txt is updated whenever turbodbc version bumped
RUN \
    set -eux; \
    pip wheel --no-cache-dir -w /wheels-tmp turbodbc==4.8.0

RUN \
    --mount=type=bind,source=auditwheel-keep-pyarrow.py,target=auditwheel-keep-pyarrow.py \
    python auditwheel-keep-pyarrow.py \
        repair \
        --plat manylinux_2_35_$(uname -m) \
        --only-plat \
        --wheel-dir /wheels \
        /wheels-tmp/turbodbc*

FROM scratch
COPY --link --from=build /wheels /wheels
