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

variable "IMAGE_PREFIX" {
    default = "server-base"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
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

target "server" {
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server"
    }
}

# -------------------------------------

target "server-all-ai" {
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-all-ai:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-all-ai"
    }
}

target "server-nltk" {
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-nltk:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-nltk"
    }
}

target "server-pytorch" {
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-pytorch:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-pytorch"
    }
}

target "server-sklearn" {
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-sklearn:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-sklearn"
    }
}

target "server-tensorflow" {
    inherits = [ "shared-context" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-tensorflow:${TAG}"
    ]
    args = {
        "REQUIREMENTS_TYPE" = "server-tensorflow"
    }
}

# -------------------------------------

target "shared-context" {
    context = "contexts/server-base/"
    args = {
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
