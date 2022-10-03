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
        "graal-ol8-17",
        "graal-ol8-11"
    ]
}

# -------------------------------------

variable "REPO_PREFIX" {
    default = "deephaven/"
}

variable "IMAGE_NAME" {
    default = "server"
}

variable "CACHE_PREFIX" {
    default = "deephaven-server-docker-"
}

// Note: when updating DEEPHAVEN_VERSION, we should update requirements.txt.
variable "DEEPHAVEN_VERSION" {
    default = "0.16.1"
}

variable "DEEPHAVEN_SHA256SUM" {
    default = "4a0f73dbed9ede52353dd0b689e1019575278a1741221c7d81b379c460158334"
}

variable "SERVER_SCRATCH_TARGET" {
    default = "server-scratch"
    // See directions in DEVELOPMENT.md
    // default = "server-scratch-local"
}

# -------------------------------------

target "server-scratch" {
    context = "server-scratch/"
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-scratch"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-groovy"
    ]
}

target "server-python" {
    inherits = [ "python-17-310" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-python"
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
    }
}

target "groovy-11" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-11"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-17"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-19"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-11-38"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-11-39"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-11-310"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-17-38"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-17-39"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-17-310"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-19-38"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-19-39"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-19-310"
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
    }
}

target "zulu-19" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-zulu-19"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:19"
    }
}

target "zulu-17" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-zulu-17"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:17"
    }
}

target "zulu-11" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-zulu-11"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:11"
    }
}

target "graal-ol8-17" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-graal-ol8-17"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "ghcr.io/graalvm/jdk:ol8-java17"
    }
}

target "graal-ol8-11" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-graal-ol8-11"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "ghcr.io/graalvm/jdk:ol8-java11"
    }
}

# -------------------------------------

target "python-all-ai" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-all-ai"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-nltk"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-pytorch"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-sklearn"
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
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-tensorflow"
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
