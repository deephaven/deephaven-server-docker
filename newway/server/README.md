# server

## Arguments

* DEEPHAVEN_VERSION
* REQUIREMENTS_TYPE
* OPENJDK_VERSION
* PYTHON_VERSION
* GRPC_HEALTH_PROBE_VERSION
* UBUNTU_TAG

```
docker buildx build \
    --build-arg DEEPHAVEN_VERSION=0.19.1 \
    --build-arg REQUIREMENTS_TYPE=server \
    --build-arg OPENJDK_VERSION=17 \
    --build-arg PYTHON_VERSION=3.10 \
    --build-arg UBUNTU_VERSION=22.04 \
    --build-arg GRPC_HEALTH_PROBE_VERSION=0.4.14 \
    .
```

or

```
docker buildx bake
```


| Image                       | REQUIREMENTS_TYPE | OPENJDK_VERSION | PYTHON_VERSION | UBUNTU_VERSION |
| --------------------------- | ----------------- | --------------- | -------------- | -------------- |
| deephaven/server            | server            | 17              | 3.10           | 22.04          |
| deephaven/server-all-ai     | server-all-ai     | 17              | 3.10           | 22.04          |
| deephaven/server-nltk       | server-nltk       | 17              | 3.10           | 22.04          |
| deephaven/server-pytorch    | server-pytorch    | 17              | 3.10           | 22.04          |
| deephaven/server-sklearn    | server-sklearn    | 17              | 3.10           | 22.04          |
| deephaven/server-tensorflow | server-tensorflow | 17              | 3.10           | 22.04          |
