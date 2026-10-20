group "default" {
    targets = [
        "server-base"
    ]
}

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
    default = "3.12"
}

variable "UBUNTU_VERSION" {
    default = "24.04"
}

variable "GRPC_HEALTH_PROBE_VERSION" {
    default = "0.4.58"
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

// Experimental: server-base images for a range of python versions, each on the newest Ubuntu
// LTS where it can be installed. Ubuntu 26.04 ships only python 3.14; the others come from the
// deadsnakes PPA, which publishes amd64 and arm64 builds for Ubuntu LTS releases.
//
//   docker buildx bake -f server-base.hcl python
//   docker buildx bake -f server-base.hcl server-base-python313

group "python" {
    targets = [
        "server-base-python39",
        "server-base-python310",
        "server-base-python311",
        "server-base-python312",
        "server-base-python313",
        "server-base-python314"
    ]
}

target "server-base-python" {
    name = "server-base-python${replace(item.python, ".", "")}"
    matrix = {
        item = [
            { python = "3.9",  ubuntu = "26.04", source = "deadsnakes" },
            { python = "3.10", ubuntu = "26.04", source = "deadsnakes" },
            { python = "3.11", ubuntu = "26.04", source = "deadsnakes" },
            { python = "3.12", ubuntu = "26.04", source = "deadsnakes" },
            { python = "3.13", ubuntu = "26.04", source = "deadsnakes" },
            { python = "3.14", ubuntu = "26.04", source = "ubuntu" },
        ]
    }
    inherits = [ "server-base-context" ]
    tags = [
        "${REPO_PREFIX}${SERVER_BASE_PREFIX}-python${item.python}:${TAG}"
    ]
    args = {
        REQUIREMENTS_TYPE = "server"
        PYTHON_VERSION = item.python
        PYTHON_SOURCE = item.source
        UBUNTU_VERSION = item.ubuntu
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
