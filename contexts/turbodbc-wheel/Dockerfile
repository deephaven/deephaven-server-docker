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

# CFLAGS fixes https://github.com/blue-yonder/turbodbc/issues/375
RUN \
    --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    CFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" pip wheel -w /wheels -r requirements.txt

FROM scratch
COPY --link --from=build /wheels /wheels