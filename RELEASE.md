# Release

This document is primarily targeted towards Deephaven release managers.
It contains the necessary instructions for releasing Deephaven server images.

## Artifacts

The Deephaven server images are important artifacts for easily running the Deephaven server in docker.
These images are released to the GitHub container registry `ghcr.io/`.

The regular images are `server` (includes Python environment) and `server-slim` (does not include Python environment).
* [ghcr.io/deephaven/server](https://github.com/deephaven/deephaven-core/pkgs/container/server)
* [ghcr.io/deephaven/server-slim](https://github.com/deephaven/deephaven-core/pkgs/container/server-slim)

The extended images are all extensions to the `server` image and include additional Python dependencies.
* [ghcr.io/deephaven/server-all-ai](https://github.com/deephaven/deephaven-core/pkgs/container/server-all-ai)
* [ghcr.io/deephaven/server-nltk](https://github.com/deephaven/deephaven-core/pkgs/container/server-nltk)
* [ghcr.io/deephaven/server-pytorch](https://github.com/deephaven/deephaven-core/pkgs/container/server-pytorch)
* [ghcr.io/deephaven/server-sklearn](https://github.com/deephaven/deephaven-core/pkgs/container/server-sklearn)
* [ghcr.io/deephaven/server-tensorflow](https://github.com/deephaven/deephaven-core/pkgs/container/server-tensorflow)

## Release process

### 1. Create and push release branch
Navigate to your checkout of [deephaven/deepaven-server-docker](https://github.com/deephaven/deephaven-server-docker).
The `upstream` remote is expected to be `git@github.com:deephaven/deephaven-server-docker.git`.

```shell
$ git remote get-url upstream
git@github.com:deephaven/deephaven-server-docker.git
```

Checkout the appropriate commit, create a release branch, update `DEEPHAVEN_VERSION` to the new version, and push.

```shell
$ git fetch upstream
$ git checkout upstream/main
# If doing a patch release, instead check out the appropriate <sha>
# $ git checkout <sha>
$ git checkout -b release/vX.Y.Z
# edit files `server.hcl` and `server-slim.hcl` and update the `DEEPHAVEN_VERSION`
$ git add server.hcl server-slim.hcl
$ git commit -m "Bump DEEPHAVEN_VERSION to X.Y.Z"
$ git push -u upstream release/vX.Y.Z
```

This will create the [Release CI](https://github.com/deephaven/deephaven-server-docker/actions/workflows/release-ci.yml) job.

### 2. Monitor and test image(s)

Monitor the release.
If all is green, you should be able to test the new release:

```shell
$ docker run --rm --name deephaven -p 10000:10000 ghcr.io/deephaven/server:X.Y.Z
```
If the release is the latest version, match the version from the latest image
```shell
$ docker run --rm --name deephaven -p 10000:10000 ghcr.io/deephaven/server:latest
```

The docker image release process is more forgiving than releasing jar artifacts.
If something goes wrong during this stage, it can easily be corrected.

### 3. Merge release branch to main


During a normal release, follow-up with a fast-forward merge of `release/vX.Y.Z` into `main`.

```shell
$ git checkout main
# Ensure you are tracking upstream/main
$ git branch -u upstream/main
$ git pull
$ git merge --ff-only release/vX.Y.Z
$ git push -u upstream main
```

If the branch is unable to be fast-forwarded, it's worth double checking your work and asking for assistance. 
Typically, the fast-forward be successful during a normal release since the release branch was just forked off from `main`.
In cases where that's not true, there's a good chance that care may be needed to ensure any merge conflicts are handled appropriately.

In the case of a patch release, the branch may, or may not, be fast-forwardable.
Use care, and ensure any merge conflicts are handled appropriately before pushing.

> :warning: If the release is a patch on an older release (i.e. not the latest), skip the following section.

```shell
$ git checkout main
# Ensure you are tracking upstream/main
$ git branch -u upstream/main
$ git pull
# Handle any merge conflicts with care
$ git merge release/vX.Y.Z
$ git push -u upstream main
```
