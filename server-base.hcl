group "default" {
    targets = [
        "server-base"
    ]
}

# Note: server-ui is not applicable as a base image at this time as some of the plugins
# explicitly depend on deephaven-core.
group "extra" {
    targets = [
        "server-base-all-ai",
        "server-base-nltk",
        "server-base-pytorch",
        "server-base-sklearn",
        "server-base-tensorflow"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "SERVER_BASE_PREFIX" {
    default = "server-base"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

variable "OPENJDK_VERSION" {
    default = "21"
}

variable "PYTHON_VERSION" {
    default = "3.11"
}

variable "UBUNTU_VERSION" {
    default = "22.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.28"
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

target "server-base" {
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server"
    }
}

# -------------------------------------

target "server-base-all-ai" {
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}-all-ai:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server-all-ai"
    }
}

target "server-base-nltk" {
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}-nltk:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server-nltk"
    }
}

target "server-base-pytorch" {
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}-pytorch:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server-pytorch"
    }
}

target "server-base-sklearn" {
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}-sklearn:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server-sklearn"
    }
}

target "server-base-tensorflow" {
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}-tensorflow:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server-tensorflow"
    }
}

# -------------------------------------

target "server-base-context" {
    context = "contexts/server-base/"
    args = {
        OPENJDK_VERSION = OPENJDK_VERSION
        PYTHON_VERSION = PYTHON_VERSION
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
