# Reproducible development environment for deephaven-server-docker, via
# devenv.sh (https://devenv.sh).
#
# Usage:
#   devenv shell                                  # enter the environment
#   docker buildx bake -f server-slim-base.hcl    # build into the local engine
#
# This repository is Dockerfiles plus buildx bake definitions (*.hcl), so the
# environment only pins the *client* side of the build: the docker CLI with its
# buildx plugin, the same frontend CI drives through docker/setup-buildx-action
# and docker/bake-action. bake's HCL semantics move between buildx releases, so
# that is the version worth pinning.
#
# It deliberately does not provide a container engine. A Docker or Podman
# daemon is a system service (root, sockets, storage, binfmt for cross-arch)
# that has to come from the host; this file only finds whichever one is
# running and wires the CLI up to it -- see engineHook below. The podman CLI is
# left out for the same reason: it should be whatever version matches the
# host's podman service, and it cannot build this repo anyway (`podman buildx`
# is an alias for buildah's `podman build`, with no `bake`).
{ pkgs, ... }:
let
  # Name of the buildx builder created when the engine is Podman. Overridable
  # by exporting BUILDX_BUILDER before entering the shell.
  builderName = "deephaven-server-docker";

  # Finds a Docker-API engine and, when it is Podman, a builder that can use it.
  #
  # 1. If the docker CLI can already reach an engine (DOCKER_HOST, the active
  #    `docker context`, or the default /var/run/docker.sock), leave it be --
  #    Docker Desktop, colima and friends all work through contexts, which an
  #    exported DOCKER_HOST would override.
  # 2. Otherwise try Podman's API socket: CONTAINER_HOST if it names a unix
  #    socket, then the rootless ($XDG_RUNTIME_DIR) and rootful locations.
  #    Only a live socket counts; nothing is started here.
  #
  # Podman's API cannot serve buildx's default `docker` driver, so against
  # Podman builds go through a BuildKit container (the `docker-container`
  # driver) running on that engine. `default-load=true` makes that builder
  # load results into Podman's image store the way the `docker` driver does
  # into Docker's, so a plain `docker buildx bake -f <file>.hcl` behaves the
  # same on either engine. The builder is created once, lazily -- its BuildKit
  # container only starts on the first build, and its cache lives in a volume
  # on the engine, so it survives across shells.
  engineHook = ''
    _dsd_engine_ok() { docker version --format '{{.Server.Version}}' >/dev/null 2>&1; }

    if ! _dsd_engine_ok && [[ -z "''${DOCKER_HOST:-}" ]]; then
      for _dsd_sock in \
          "''${CONTAINER_HOST:-}" \
          "''${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/podman/podman.sock}" \
          /run/podman/podman.sock; do
        _dsd_sock="''${_dsd_sock#unix://}"
        if [[ -n "$_dsd_sock" && -S "$_dsd_sock" ]]; then
          export DOCKER_HOST="unix://$_dsd_sock"
          _dsd_engine_ok && break
          unset DOCKER_HOST
        fi
      done
    fi

    if ! _dsd_engine_ok; then
      echo "warning: no Docker or Podman engine reachable; builds will fail until one is running." >&2
      echo "         Start Docker, or Podman's API socket (e.g. 'systemctl --user start podman.socket')," >&2
      echo "         or point DOCKER_HOST at one, then re-enter the shell." >&2
    elif docker version --format '{{range .Server.Components}}{{.Name}} {{end}}' 2>/dev/null | grep -q Podman; then
      export BUILDX_BUILDER="''${BUILDX_BUILDER:-${builderName}}"
      if ! docker buildx inspect "$BUILDX_BUILDER" >/dev/null 2>&1; then
        echo "Creating buildx builder '$BUILDX_BUILDER' (docker-container driver on Podman)"
        docker buildx create --name "$BUILDX_BUILDER" --driver docker-container \
          --driver-opt default-load=true >/dev/null
      fi
    fi

    unset -f _dsd_engine_ok
    unset _dsd_sock
  '';
in
{
  packages = [
    # CLI only (no dockerd). nixpkgs compiles the buildx and compose plugin
    # paths into the binary, so the plugins are pinned alongside it with no
    # ~/.docker/cli-plugins setup.
    pkgs.docker-client
  ];

  # The shell inherits SOURCE_DATE_EPOCH=315532800 (1980-01-01) from nixpkgs'
  # stdenv, and buildx honours it, stamping every image built here as created
  # in 1980 -- unlike the same build in CI. Drop it so local images match.
  enterShell = ''
    unset SOURCE_DATE_EPOCH
  '' + engineHook + ''
    echo "deephaven-server-docker dev shell ($(docker --version), buildx $(docker buildx version | cut -d' ' -f2))"
    echo "engine: ''${DOCKER_HOST:-docker default}''${BUILDX_BUILDER:+, builder: $BUILDX_BUILDER}"
  '';

  # `devenv test`: every bake file must parse and resolve with this buildx.
  # --print needs no engine, so this also runs where none is available.
  enterTest = ''
    for f in server-slim-base.hcl server-base.hcl server-slim.hcl server.hcl; do
      echo "bake --print $f"
      docker buildx bake -f "$f" --print --progress=quiet >/dev/null
    done
  '';
}
