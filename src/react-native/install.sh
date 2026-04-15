#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

UV_VERSION="${UV_VERSION:-0.10.9}"
HERMES_DEC_VERSION="${HERMES_DEC_VERSION:-0.1.0}"

if [[ -z "${UV_VERSION}" ]]; then
    echo "ERROR: UV_VERSION is empty." >&2
    exit 1
fi

if [[ -z "${HERMES_DEC_VERSION}" ]]; then
    echo "ERROR: HERMES_DEC_VERSION is empty." >&2
    exit 1
fi

apt-get update
apt-get install --no-install-recommends -y ca-certificates curl
rm -rf /var/lib/apt/lists/*

UV_INSTALL_ROOT="/usr/local/bin"
UV_DATA_ROOT="/usr/local/share/uv"
UV_TOOL_DIR="${UV_DATA_ROOT}/tools"
UV_TOOL_BIN_DIR="/usr/local/bin"
UV_PYTHON_INSTALL_DIR="${UV_DATA_ROOT}/python"
UV_PYTHON_BIN_DIR="${UV_DATA_ROOT}/python-bin"
UV_CACHE_DIR="${UV_DATA_ROOT}/cache"

mkdir -p \
    "${UV_DATA_ROOT}" \
    "${UV_TOOL_DIR}" \
    "${UV_PYTHON_INSTALL_DIR}" \
    "${UV_PYTHON_BIN_DIR}" \
    "${UV_CACHE_DIR}"

curl -fsSL "https://astral.sh/uv/${UV_VERSION}/install.sh" \
    | env UV_UNMANAGED_INSTALL="${UV_INSTALL_ROOT}" sh

export UV_TOOL_DIR
export UV_TOOL_BIN_DIR
export UV_PYTHON_INSTALL_DIR
export UV_PYTHON_BIN_DIR
export UV_CACHE_DIR

uv tool install --python 3.12 "hermes-dec==${HERMES_DEC_VERSION}"

for command_name in node uv uvx hbc-file-parser hbc-disassembler hbc-decompiler; do
    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "ERROR: Expected command '${command_name}' was not installed." >&2
        exit 1
    fi
done

hbc-file-parser --help >/dev/null
hbc-disassembler --help >/dev/null
hbc-decompiler --help >/dev/null

echo "INFO: React Native tooling installed successfully."
