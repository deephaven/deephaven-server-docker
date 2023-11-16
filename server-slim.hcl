group "default" {
    targets = [
        "server-slim"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "SERVER_SLIM_PREFIX" {
    default = "server-slim"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

variable "DEEPHAVEN_SOURCES" {
    // "released" means that the build will use the released sources - tar from GitHub
    // "custom" means that the builder will provide the tar file
    default = "released"
}

variable "DEEPHAVEN_VERSION" {
    default = "0.30.1"
}

variable "OPENJDK_VERSION" {
    default = "21"
}

variable "UBUNTU_VERSION" {
    default = "22.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.22"
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

target "server-slim" {
    context = "contexts/server-slim/"
    tags = [
        "${REPO_PREFIX}${SERVER_SLIM_PREFIX}:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_SLIM_PREFIX}:${DEEPHAVEN_VERSION}" : ""
    ]
    args = {
        DEEPHAVEN_VERSION = DEEPHAVEN_VERSION
        OPENJDK_VERSION = OPENJDK_VERSION
        UBUNTU_VERSION = UBUNTU_VERSION
        GRPC_HEALTH_PROBE_VERSION = GRPC_HEALTH_PROBE_VERSION
        DEEPHAVEN_SOURCES = DEEPHAVEN_SOURCES
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
