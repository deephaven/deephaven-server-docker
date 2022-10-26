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
        "python-17-38",
        "python-17-39",
        "python-17-310",
        "python-19-38",
        "python-19-39",
        "python-19-310",

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
    default = "0.17.0"
}

variable "DEEPHAVEN_SHA256SUM" {
    default = "e9dc4fe64d5a0e6d78f41670d5111239a412d787019be161700521e7f7e9c9a1"
}

variable "SERVER_SCRATCH_TARGET" {
    default = "server-scratch"
    // See directions in DEVELOPMENT.md
    // default = "server-scratch-local"
}

variable "TAG" {
    default = "latest"
}

// Due to our nightly builds, setting a build timestamp for org.opencontainers.image.created would
// cause a new image manifest to be created every night, which is something we don't want unless
// the base image has been updated.
// variable "BUILD_TIMESTAMP" {
//     default = "${timestamp()}"
// }

variable "JAVA_OPTS" {
    default = "-XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication"
}

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
    inherits = [ "groovy-17" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-slim:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}-slim:${DEEPHAVEN_VERSION}" : ""
    ]
}

target "server-python" {
    inherits = [ "python-17-310" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}:${TAG}",
        equal("latest", TAG) ? "${REPO_PREFIX}${IMAGE_PREFIX}:${DEEPHAVEN_VERSION}" : ""
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

target "server-contexts" {
    context = "server/"
    contexts = {
        server-scratch = "target:server-scratch"
    }
    args = {
        "DEEPHAVEN_VERSION" = "${DEEPHAVEN_VERSION}"
        "DEEPHAVEN_SHA256SUM" = "${DEEPHAVEN_SHA256SUM}"
        // "BUILD_TIMESTAMP" = "${BUILD_TIMESTAMP}"
        "JAVA_OPTS" = "${JAVA_OPTS}"
    }
}

target "groovy-11" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-11:${TAG}"
    ]
    target = "groovy"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "11"
    }
}

target "groovy-17" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-17:${TAG}"
    ]
    target = "groovy"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
    }
}

target "groovy-19" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-groovy-19:${TAG}"
    ]
    target = "groovy"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "19"
    }
}

target "python-11-38" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-38:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.8"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-11-39" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-39:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.9"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-11-310" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-11-310:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "11"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-38" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-38:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.8"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-39" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-39:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.9"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-17-310" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-17-310:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "17"
        "PYTHON_VERSION" = "3.10"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-38" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-38:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.8"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-39" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-39:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.9"
        "REQUIREMENTS_DIR" = "./python/base/"
    }
}

target "python-19-310" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_PREFIX}-python-19-310:${TAG}"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "19"
        "PYTHON_VERSION" = "3.10"
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
        "JAVA_OPTS" = "${JAVA_OPTS}"
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
