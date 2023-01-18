group "default" {
    targets = [
        "server-slim"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "IMAGE_PREFIX" {
    default = "server-slim"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

variable "DEEPHAVEN_VERSION" {
    default = "0.20.0"
}

variable "OPENJDK_VERSION" {
    default = "17"
}

variable "UBUNTU_VERSION" {
    default = "22.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.14"
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
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}:${DEEPHAVEN_VERSION}" : ""
    ]
}

# -------------------------------------

target "shared-context" {
    context = "contexts/server-slim/"
    args = {
        "DEEPHAVEN_VERSION" = "${DEEPHAVEN_VERSION}"
        "OPENJDK_VERSION" = "${OPENJDK_VERSION}"
        "UBUNTU_VERSION" = "${UBUNTU_VERSION}"
        "GRPC_HEALTH_PROBE_VERSION" = "${GRPC_HEALTH_PROBE_VERSION}"
    }
    cache-from = [
        GITHUB_ACTIONS && RELEASE ? "type=gha,scope=${CACHE_PREFIX}" : ""
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
