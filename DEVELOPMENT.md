# Development

## Local development

It's possible to modify the setup to work with local development. Note: the python specific parts of the following directions can be skipped if you don't care about python images.


In [deephaven-core](https://github.com/deephaven/deephaven-core):

```shell
./gradlew server-jetty-app:assemble py-server:assemble
```

In this repository:

```shell
cp <deephaven-core>/server/jetty-app/build/distributions/server-jetty-<version>.tar server-scratch/
cp <deephaven-core>/docker/server/src/main/server/requirements.txt server/python/requirements/
cp <deephaven-core>/py/server/build/wheel/deephaven_core-<version>-py3-none-any.whl server/python/requirements/
```

Add `deephaven-core @ file:///python/requirements/deephaven_core-<version>-py3-none-any.whl` to [server/python/requirements/requirements.txt](server/python/requirements/requirements.txt).

Edit the [docker-bake.hcl](./docker-bake.hcl) variables `DEEPHAVEN_VERSION` and `DEEPHAVEN_SHA256SUM` as appropriate, and change `SERVER_SCRATCH_TARGET` to "server-scratch-local".

Build your images!

```shell
docker buildx bake <target>
```

For example:

```shell
docker buildx bake server-python --load
docker run --rm --name deephaven -p 10000:10000 deephaven/server:<version>-python
```
