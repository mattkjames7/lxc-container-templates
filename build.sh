#!/bin/bash

set -euo pipefail

SUPPORTED_OS=(
    debian-13
    ubuntu-24.04
    ubuntu-26.04
)

print_usage() {
    echo "Usage: $0 <target-os>"
    echo "Supported target OS:"
    for os in "${SUPPORTED_OS[@]}"; do
        echo "  - $os"
    done
}

if [[ $# -ne 1 ]]; then
    print_usage
    exit 1
fi
OS=$1

if [[ ! " ${SUPPORTED_OS[*]} " =~ " ${OS} " ]]; then
    echo "Error: Unsupported target OS '${OS}'"
    print_usage
    exit 1
fi

# launch debian builder if OS is Ubuntu or Debian based
if [[ $OS == ubuntu-* || $OS == debian-* ]]; then
  target=debian-builder
else
    echo "Error: Unsupported target OS '${OS}'"
    exit 1
fi

SCRIPT_NAME_PART="${OS}"
if [[ "$(arch)" == "aarch64" ]]; then
    SCRIPT_NAME_PART="${SCRIPT_NAME_PART}-arm64"
fi
SCRIPT_NAME="${SCRIPT_NAME_PART}.sh"

if [[ ! -d ./build ]]; then
    mkdir ./build
fi
if [[ ! -d ./output ]]; then
    mkdir ./output
fi
uid=$(id -u)
gid=$(id -g)

docker compose up -d $target

container_name="$(docker compose ps -q $target)"
docker exec -it "$container_name" bash -c "/tmp/scripts/${SCRIPT_NAME} /tmp/build /tmp/output"
docker exec -it "$container_name" bash -c "chown ${uid}:${gid} /tmp/output/${SCRIPT_NAME_PART}*.tar*"

docker compose down
