group "default" {
    targets = [
        "server-slim-base"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "SERVER_SLIM_BASE_PREFIX" {
    default = "server-slim-base"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

variable "OPENJDK_VERSION" {
    default = "17"
}

variable "UBUNTU_VERSION" {
    default = "22.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.18"
}

variable "TAG" {
    default = "latest"
}

variable "RELEASE" {
    default = false
}

variable "MULTI_ARCH" {
    default = false
}

variable "GITHUB_ACTIONS" {
    default = false
}

// Due to our nightly builds, setting a build timestamp for org.opencontainers.image.created would
// cause a new image manifest to be created every night, which is something we don't want unless
// the base image has been updated.
// variable "BUILD_TIMESTAMP" {
//     default = "${timestamp()}"
// }

# -------------------------------------

target "server-slim-base" {
    context = "contexts/server-slim-base/"
    tags = [
        "${REPO_PREFIX}${SERVER_SLIM_BASE_PREFIX}:${TAG}"
    ]
    args = {
        OPENJDK_VERSION = OPENJDK_VERSION
        UBUNTU_VERSION = UBUNTU_VERSION
        GRPC_HEALTH_PROBE_VERSION = GRPC_HEALTH_PROBE_VERSION
    }
    cache-from = [
        GITHUB_ACTIONS ? "type=gha,scope=${CACHE_PREFIX}" : ""
    ]
    cache-to = [
        GITHUB_ACTIONS && RELEASE ? "type=gha,mode=max,scope=${CACHE_PREFIX}" : ""
    ]
    platforms = [
        MULTI_ARCH || RELEASE ? "linux/amd64" : "",
        MULTI_ARCH || RELEASE ? "linux/arm64" : "",
    ]
    output = [
        RELEASE ? "type=registry" : ""
    ]
}

# -------------------------------------
