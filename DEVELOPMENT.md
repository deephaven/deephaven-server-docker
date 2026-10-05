# Development

## Development environment

A [devenv](https://devenv.sh) environment pins the build client: the docker CLI with its buildx
(and compose) plugin, the same frontend CI uses.

```shell
devenv shell
docker buildx bake -f server-slim-base.hcl
```

It does not provide a container engine; Docker or Podman must already be installed and running.
On entry the shell uses whatever engine the docker CLI can already reach, and otherwise looks
for a live Podman API socket (`$CONTAINER_HOST`, then the rootless and rootful defaults) and sets
`DOCKER_HOST` to it. With Podman it also creates a buildx builder named `deephaven-server-docker`
(the `docker-container` driver, which Podman's API needs) that loads results into Podman's
image store, so `--load` is not required. Set `BUILDX_BUILDER` beforehand to use a different
builder.

Multi-arch builds (`MULTI_ARCH=true`) also need QEMU binfmt handlers registered on the host,
which CI does with `docker/setup-qemu-action`.

`devenv test` checks that every bake file parses with the pinned buildx.

## Local development

It's possible to modify the setup to work with local development. Note: the python specific parts of the following directions can be skipped if you don't care about python images.


In [deephaven-core](https://github.com/deephaven/deephaven-core):

```shell
./gradlew server-jetty-app:assemble py-server:assemble
```

In this repository:

```shell
cp <deephaven-core>/server/jetty-app/build/distributions/server-jetty-<version>.tar contexts/server-slim/
cp <deephaven-core>/server/jetty-app/build/distributions/server-jetty-<version>.tar contexts/server/
cp <deephaven-core>/py/server/build/wheel/deephaven_core-<version>-py3-none-any.whl contexts/server/
```

```shell
DEEPHAVEN_SOURCES=custom docker buildx bake -f server.hcl
```
