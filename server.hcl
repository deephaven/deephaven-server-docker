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

variable "DEEPHAVEN_SOURCES" {
    // "released" means that the build will use the released sources - tar from GitHub and wheel from PyPi
    // "custom" means that the builder will provide the tar and wheel files
    default = "released"
}

variable "DEEPHAVEN_VERSION" {
    default = "0.40.0"
}

variable "GIT_REVISION" {
    default = ""
}

variable "DEEPHAVEN_CORE_WHEEL" {
    default = ""
}

variable "OPENJDK_VERSION" {
    default = "21"
}

variable "PYTHON_VERSION" {
    default = "3.10"
}

variable "UBUNTU_VERSION" {
    default = "22.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.34"
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

target "server" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}:${TAG}",
        "${REPO_PREFIX}${SERVER_PREFIX}-ui:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}:${DEEPHAVEN_VERSION}" : "",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}-ui:${DEEPHAVEN_VERSION}" : "",
    ]
    args = {
        REQUIREMENTS_TYPE = "server"
    }
}

# -------------------------------------

target "server-all-ai" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-all-ai:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}-all-ai:${DEEPHAVEN_VERSION}" : ""
    ]
    args = {
        REQUIREMENTS_TYPE = "server-all-ai"
    }
}

target "server-nltk" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-nltk:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}-nltk:${DEEPHAVEN_VERSION}" : ""
    ]
    args = {
        REQUIREMENTS_TYPE = "server-nltk"
    }
}

target "server-pytorch" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-pytorch:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}-pytorch:${DEEPHAVEN_VERSION}" : ""
    ]
    args = {
        REQUIREMENTS_TYPE = "server-pytorch"
    }
}

target "server-sklearn" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-sklearn:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}-sklearn:${DEEPHAVEN_VERSION}" : ""
    ]
    args = {
        REQUIREMENTS_TYPE = "server-sklearn"
    }
}

target "server-tensorflow" {
    inherits = [ "server-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_PREFIX}-tensorflow:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${SERVER_PREFIX}-tensorflow:${DEEPHAVEN_VERSION}" : ""
    ]
    args = {
        REQUIREMENTS_TYPE = "server-tensorflow"
    }
}

# -------------------------------------

target "server-context" {
    context = "contexts/server/"
    args = {
        DEEPHAVEN_VERSION = DEEPHAVEN_VERSION
        GIT_REVISION = GIT_REVISION
        DEEPHAVEN_CORE_WHEEL = DEEPHAVEN_CORE_WHEEL
        OPENJDK_VERSION = OPENJDK_VERSION
        PYTHON_VERSION = PYTHON_VERSION
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
