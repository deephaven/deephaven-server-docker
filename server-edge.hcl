group "default" {
    targets = [
        "server"
    ]
}

group "extra" {
    targets = [
        "server-all-ai",
        "server-nltk",
        "server-pytorch",
        "server-sklearn",
        "server-tensorflow"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "SERVER_PREFIX" {
    default = "server"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

variable "DEEPHAVEN_VERSION" {
    default = "0.21.0"
}

variable "OPENJDK_VERSION" {
    default = "17"
}

variable "PYTHON_VERSION" {
    default = "3.10"
}

variable "UBUNTU_VERSION" {
    default = "22.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.15"
}

variable "TAG" {
    default = "edge"
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

target "server" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server"
    }
}

# -------------------------------------

target "server-all-ai" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-all-ai:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-all-ai"
    }
}

target "server-nltk" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-nltk:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-nltk"
    }
}

target "server-pytorch" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-pytorch:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-pytorch"
    }
}

target "server-sklearn" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-sklearn:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-sklearn"
    }
}

target "server-tensorflow" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-tensorflow:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-tensorflow"
    }
}

# -------------------------------------

target "server-context" {
    context = "contexts/server-edge/"
    args = {
        "DEEPHAVEN_VERSION" = "${DEEPHAVEN_VERSION}"
        "OPENJDK_VERSION" = "${OPENJDK_VERSION}"
        "PYTHON_VERSION" = "${PYTHON_VERSION}"
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
