group "default" {
    targets = [
        "server-groovy",
        "server-python"
    ]
}

group "extras" {
    targets = [
        "python-all-ai",
        "python-nltk",
        "python-pytorch",
        "python-sklearn",
        "python-tensorflow",
    ]
}

group "release" {
    targets = [
        "server-scratch-release",
        "server-groovy-release",
        "server-python-release",
        "python-all-ai-release",
        "python-nltk-release",
        "python-pytorch-release",
        "python-sklearn-release",
        "python-tensorflow-release",
    ]
}

group "all" {
    targets = [
        // Defaults
        "server-scratch",
        "server-groovy",
        "server-python",

        // Explicit JDK and Python versions
        "groovy-11",
        "groovy-17",
        "groovy-19",
        "python-11-38",
        "python-11-39",
        "python-11-310",
        "python-11-311",
        "python-17-38",
        "python-17-39",
        "python-17-310",
        "python-17-311",
        "python-19-38",
        "python-19-39",
        "python-19-310",
        "python-19-311",

        // Generic servers
        "zulu-19",
        "zulu-17",
        "zulu-11",
        "graal-17-22-3-0",
        "graal-11-22-3-0",

        // Extras
        "python-all-ai",
        "python-nltk",
        "python-pytorch",
        "python-sklearn",
        "python-tensorflow"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "IMAGE_PREFIX" {
    default = "server"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

// Note: when updating DEEPHAVEN_VERSION, we should update requirements.txt.
variable "DEEPHAVEN_VERSION" {
    default = "0.19.1"
}

variable "DEEPHAVEN_SHA256SUM" {
    default = "8b856558524e42d48ed37f8f63fb90e89b421f73160d1427186b3c5e6f09a412"
}

variable "SERVER_SCRATCH_TARGET" {
    default = "server-scratch"
    // See directions in DEVELOPMENT.md
    // default = "server-scratch-local"
}

variable "TAG" {
    default = "latest"
}

variable "INTERNAL_RELEASE_JAVA_STR" {
    default = "17"
}

variable "INTERNAL_RELEASE_PYTHON_STR" {
    default = "310"
}

// Due to our nightly builds, setting a build timestamp for org.opencontainers.image.created would
// cause a new image manifest to be created every night, which is something we don't want unless
// the base image has been updated.
// variable "BUILD_TIMESTAMP" {
//     default = "${timestamp()}"
// }

# -------------------------------------

target "server-scratch" {
    context = "server-scratch/"
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-scratch:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-scratch:${DEEPHAVEN_VERSION}" : ""
    ]
    target = "${SERVER_SCRATCH_TARGET}"
    args = {
        "DEEPHAVEN_VERSION" = "${DEEPHAVEN_VERSION}"
        "DEEPHAVEN_SHA256SUM" = "${DEEPHAVEN_SHA256SUM}"
    }
}

target "server-groovy" {
    inherits = [ "groovy-${INTERNAL_RELEASE_JAVA_STR}" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-slim:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-slim:${DEEPHAVEN_VERSION}" : ""
    ]
}

target "server-python" {
    inherits = [ "python-${INTERNAL_RELEASE_JAVA_STR}-${INTERNAL_RELEASE_PYTHON_STR}" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}:${DEEPHAVEN_VERSION}" : ""
    ]
}

# -------------------------------------

# Note: the base hierarchy includes a bit more targets than actually necessary.
# They include the scratch image, which isn't included as part of the base images.
# This can be fixed in the future if we want to create a separate context that
# isolates the base building logic.
#
# To see,
# `docker buildx bake server-groovy-base --print`
# includes the `server-scratch` target.

target "server-groovy-base" {
    inherits = [ "groovy-${INTERNAL_RELEASE_JAVA_STR}-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-slim-base-os:${TAG}"
    ]
}

target "server-python-base" {
    inherits = [ "python-${INTERNAL_RELEASE_JAVA_STR}-${INTERNAL_RELEASE_PYTHON_STR}-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-base-os:${TAG}"
    ]
}

# -------------------------------------

target "server-scratch-release" {
    inherits = [ "server-scratch" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}scratch" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}scratch" ]
    # We'll only release amd64, as the contents are the same as arm64
    platforms = [ "linux/amd64" ]
}

target "server-groovy-release" {
    inherits = [ "server-groovy" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}groovy" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}groovy" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

target "server-python-release" {
    inherits = [ "server-python" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}python" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}python" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

# -------------------------------------

# todo: should these be different cache scopes?

target "server-groovy-base-release" {
    inherits = [ "server-groovy-base" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}groovy" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}groovy" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

target "server-python-base-release" {
    inherits = [ "server-python-base" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}python" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}python" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

# -------------------------------------


target "server-contexts" {
    context = "server/"
    contexts = {
        server-scratch = "target:server-scratch"
    }
    args = {
        "DEEPHAVEN_VERSION" = "${DEEPHAVEN_VERSION}"
        "DEEPHAVEN_SHA256SUM" = "${DEEPHAVEN_SHA256SUM}"
        // "BUILD_TIMESTAMP" = "${BUILD_TIMESTAMP}"
    }
}

# -------------------------------------

target "groovy-11-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-11-base:${TAG}"
    ]
    target = "groovy-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "11"
    }
}

target "groovy-17-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-17-base:${TAG}"
    ]
    target = "groovy-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
    }
}

target "groovy-19-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-19-base:${TAG}"
    ]
    target = "groovy-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "19"
    }
}

# -------------------------------------

target "groovy-11" {
    inherits = [ "groovy-11-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-11:${TAG}"
    ]
    target = "groovy"
}

target "groovy-17" {
    inherits = [ "groovy-17-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-17:${TAG}"
    ]
    target = "groovy"
}

target "groovy-19" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-19:${TAG}"
    ]
    target = "groovy-19-base"
}

# -------------------------------------

target "python-11-38-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-38-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.8"
    }
}

target "python-11-39-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-39-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.9"
    }
}

target "python-11-310-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-310-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.10"
    }
}

target "python-11-311-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-311-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.11"
    }
}

target "python-17-38-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-38-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.8"
    }
}

target "python-17-39-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-39-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.9"
    }
}

target "python-17-310-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-310-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
    }
}

target "python-17-311-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-311-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.11"
    }
}

target "python-19-38-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-38-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.8"
    }
}

target "python-19-39-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-39-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.9"
    }
}

target "python-19-310-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-310-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.10"
    }
}

target "python-19-311-base" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-311-base:${TAG}"
    ]
    target = "python-base"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.11"
    }
}

# -------------------------------------

target "python-11-38" {
    inherits = [ "python-11-38-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-38:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-11-39" {
    inherits = [ "python-11-39-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-39:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-11-310" {
    inherits = [ "python-11-310-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-310:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-11-311" {
    inherits = [ "python-11-311-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-311:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-38" {
    inherits = [ "python-17-38-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-38:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-39" {
    inherits = [ "python-17-39-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-39:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-310" {
    inherits = [ "python-17-310-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-310:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-311" {
    inherits = [ "python-17-311-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-311:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-38" {
    inherits = [ "python-19-38-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-38:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-39" {
    inherits = [ "python-19-39-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-39:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-310" {
    inherits = [ "python-19-310-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-310:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-311" {
    inherits = [ "python-19-311-base" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-311:${TAG}"
    ]
    target = "python"
    args = {
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

# -------------------------------------

target "generic-contexts" {
    context = "server-generic/"
    contexts = {
        server-scratch = "target:server-scratch"
    }
    args = {
        "DEEPHAVEN_VERSION" = "${DEEPHAVEN_VERSION}"
        "DEEPHAVEN_SHA256SUM" = "${DEEPHAVEN_SHA256SUM}"
    }
}

target "zulu-19" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-zulu-19:${TAG}"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:19"
    }
}

target "zulu-17" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-zulu-17:${TAG}"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:17"
    }
}

target "zulu-11" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-zulu-11:${TAG}"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:11"
    }
}

target "graal-17-22-3-0" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-graal-17-22.3.0:${TAG}"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "ghcr.io/graalvm/jdk:ol9-java17-22.3.0"
    }
}

target "graal-11-22-3-0" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-graal-11-22.3.0:${TAG}"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "ghcr.io/graalvm/jdk:ol9-java11-22.3.0"
    }
}

# -------------------------------------

target "python-all-ai" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-all-ai:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-all-ai:${DEEPHAVEN_VERSION}" : ""
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/all-ai/"
    }
}

target "python-nltk" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-nltk:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-nltk:${DEEPHAVEN_VERSION}" : ""
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/nltk/"
    }
}

target "python-pytorch" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-pytorch:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-pytorch:${DEEPHAVEN_VERSION}" : ""
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/pytorch/"
    }
}

target "python-sklearn" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-sklearn:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-sklearn:${DEEPHAVEN_VERSION}" : ""
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/sklearn/"
    }
}

target "python-tensorflow" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-tensorflow:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-tensorflow:${DEEPHAVEN_VERSION}" : ""
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/tensorflow/"
    }
}

# -------------------------------------

target "python-all-ai-release" {
    inherits = [ "python-all-ai" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}all-ai" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}all-ai" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

target "python-nltk-release" {
    inherits = [ "python-nltk" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}nltk" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}nltk" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

target "python-pytorch-release" {
    inherits = [ "python-pytorch" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}pytorch" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}pytorch" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

target "python-sklearn-release" {
    inherits = [ "python-sklearn" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}sklearn" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}sklearn" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

target "python-tensorflow-release" {
    inherits = [ "python-tensorflow" ]
    cache-from = [ "type=gha,scope=${CACHE_PREFIX}tensorflow" ]
    cache-to = [ "type=gha,mode=max,scope=${CACHE_PREFIX}tensorflow" ]
    platforms = [ "linux/amd64", "linux/arm64" ]
}

# -------------------------------------
