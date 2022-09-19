# deephaven-server-docker

This repository produces [Deephaven](https://deephaven.io/) server Docker images with the [deephaven-core releases](https://github.com/deephaven/deephaven-core/releases).

## Quickstart

To get started quickly, simply run:

```bash
docker run \
    --rm \
    --name deephaven \
    -p 10000:10000 \
    ghcr.io/deephaven/server:0.16.1-python
```

This will start the server, and the web UI will be available at [http://localhost:10000](http://localhost:10000).

## Images

The following server images are currently being produced:

* `ghcr.io/deephaven/server:0.16.1-groovy`
* `ghcr.io/deephaven/server:0.16.1-python`

### Linux

Images are produced for the `linux/amd64` and `linux/arm64` platforms. The images are based off of the [ubuntu](https://hub.docker.com/_/ubuntu) Docker image.

### Mac

Both the Intel and M1 architectures are supported with the Linux images.

### Windows

The Linux images can be used with the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/). Windows native images are not currently being produced, but may be produced in the future.

### Scratch

A "scratch" image is also being produced, `ghcr.io/deephaven/server:0.16.1-scratch`.
It contains just the application bits (no OS) unpackaged into `/opt/deephaven/`.
This is useful for third-parties that want to quickly mix-in the Deephaven application with their own Dockerfiles:

```Dockerfile
COPY --link --from=ghcr.io/deephaven/server:0.16.1-scratch /opt/deephaven /opt/deephaven
```

In this mode, users are responsible for providing their own JVM (and Python virtual environment if applicable).

## Build

### CI

The images are automatically built and deployed by GitHub Actions CI, see [build-ci.yml](.github/workflows/build-ci.yml).

### Local

For a default, local-only build on your system's platform, run:

```
# Build all of the default images:
docker buildx bake

# Build a specific target image:
docker buildx bake python-11-310
```

See [docker-bake.hcl](docker-bake.hcl) for parameterization options.


## Resources

* [Issues](https://github.com/deephaven/deephaven-server-docker/issues)
* [Deephaven Community Slack](https://deephaven.io/slack)
* [Deephaven Documentation](https://deephaven.io/core/docs/)
