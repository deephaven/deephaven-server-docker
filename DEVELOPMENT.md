# Development

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
