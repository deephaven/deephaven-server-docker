# deephaven-server-docker

This repository produces [Deephaven](https://deephaven.io/) server Docker images with the [deephaven-core releases](https://github.com/deephaven/deephaven-core/releases).

## Quickstart

To get started quickly, simply run:

```bash
docker run \
    --rm \
    --name deephaven \
    -p 10000:10000 \
    ghcr.io/deephaven/server:0.33.2
```

This will start the server, and the web UI will be available at [http://localhost:10000](http://localhost:10000).

## Images

The following server images are currently being produced:

* `ghcr.io/deephaven/server:0.33.2`
* `ghcr.io/deephaven/server-slim:0.33.2`
* `ghcr.io/deephaven/server-all-ai:0.33.2`
* `ghcr.io/deephaven/server-nltk:0.33.2`
* `ghcr.io/deephaven/server-pytorch:0.33.2`
* `ghcr.io/deephaven/server-sklearn:0.33.2`
* `ghcr.io/deephaven/server-tensorflow:0.33.2`

### Linux

Images are produced for the `linux/amd64` and `linux/arm64` platforms. The images are based off of the [ubuntu](https://hub.docker.com/_/ubuntu) Docker image.

### Mac

Both the Intel and M1 architectures are supported with the Linux images.

### Windows

The Linux images can be used with the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/). Windows native images are not currently being produced, but may be produced in the future.

## Build

### CI

The images are automatically built and deployed by GitHub Actions CI, see [release-ci.yml](.github/workflows/release-ci.yml).

### Local

For a default, local-only build on your system's platform, run:

```
# Build the default server image:
docker buildx bake -f server.hcl

# Build a specific target image:
docker buildx bake -f server.hcl server-all-ai
```

See the various hcl files for parameterization options.

## Release

See [RELEASE](RELEASE.md).

## Resources

* [Issues](https://github.com/deephaven/deephaven-server-docker/issues)
* [Deephaven Community Slack](https://deephaven.io/slack)
* [Deephaven Documentation](https://deephaven.io/core/docs/)
