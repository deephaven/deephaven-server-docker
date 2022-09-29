group "default" {
    targets = [
        "server-groovy",
        "server-python"
    ]
}

group "release" {
    targets = [
        "server-scratch-release",
        "server-groovy-release",
        "server-python-release"
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
        "groovy-18",
        "python-11-38",
        "python-11-39",
        "python-11-310",
        "python-17-38",
        "python-17-39",
        "python-17-310",
        "python-18-38",
        "python-18-39",
        "python-18-310",

        // Generic servers
        "zulu-18",
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

target "groovy-18" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-18"
    ]
    target = "groovy"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "18"
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
    }
}

target "python-18-38" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-18-38"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "18"
        "PYTHON_VERSION" = "3.8"
    }
}

target "python-18-39" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-18-39"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "20.04"
        "OPENJDK_VERSION" = "18"
        "PYTHON_VERSION" = "3.9"
    }
}

target "python-18-310" {
    inherits = [ "server-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-18-310"
    ]
    target = "python"
    args = {
        "UBUNTU_TAG" = "22.04"
        "OPENJDK_VERSION" = "18"
        "PYTHON_VERSION" = "3.10"
    }
}

# -------------------------------------

target "generic-contexts" {
    context = "server-generic/"
    contexts = {
        server-scratch = "target:server-scratch"
    }
}

target "zulu-18" {
    inherits = [ "generic-contexts" ]
    tags = [
        "${REPO_PREFIX}${IMAGE_NAME}:${DEEPHAVEN_VERSION}-zulu-18"
    ]
    args = {
        "GENERIC_JAVA_BASE" = "azul/zulu-openjdk:18"
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
