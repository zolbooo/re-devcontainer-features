#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-6.1.0}"

if [[ -z "${VERSION}" ]]; then
    echo "ERROR: VERSION is empty." >&2
    exit 1
fi

VERSION="${VERSION#v}"
ARCH="$(dpkg --print-architecture)"
ASSET_NAME="radare2_${VERSION}_${ARCH}.deb"
RELEASE_API_URL="https://api.github.com/repos/radareorg/radare2/releases/tags/${VERSION}"

case "${ARCH}" in
    amd64 | arm64 | i386)
        ;;
    *)
        echo "ERROR: Unsupported architecture: ${ARCH}." >&2
        exit 1
        ;;
esac

apt-get update
apt-get install --no-install-recommends -y ca-certificates curl jq

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

RELEASE_JSON="${TMP_DIR}/release.json"
ASSET_PATH="${TMP_DIR}/${ASSET_NAME}"

if ! curl -fsSL "${RELEASE_API_URL}" -o "${RELEASE_JSON}"; then
    echo "ERROR: Failed to fetch Radare2 release metadata for ${VERSION}." >&2
    exit 1
fi

ASSET_URL="$(jq -r --arg name "${ASSET_NAME}" '.assets[] | select(.name == $name) | .browser_download_url' "${RELEASE_JSON}" | head -n 1)"
ASSET_DIGEST="$(jq -r --arg name "${ASSET_NAME}" '.assets[] | select(.name == $name) | .digest' "${RELEASE_JSON}" | head -n 1)"

if [[ -z "${ASSET_URL}" || "${ASSET_URL}" == "null" ]]; then
    echo "ERROR: Could not find asset URL for ${ASSET_NAME} in release ${VERSION}." >&2
    exit 1
fi

if [[ -z "${ASSET_DIGEST}" || "${ASSET_DIGEST}" == "null" ]]; then
    echo "ERROR: Could not find digest for ${ASSET_NAME} in release ${VERSION}." >&2
    exit 1
fi

if [[ "${ASSET_DIGEST}" != sha256:* ]]; then
    echo "ERROR: Unsupported digest format: ${ASSET_DIGEST}." >&2
    exit 1
fi

ASSET_SHA256="${ASSET_DIGEST#sha256:}"

if ! curl -fL --retry 5 --retry-delay 2 "${ASSET_URL}" -o "${ASSET_PATH}"; then
    echo "ERROR: Failed to download ${ASSET_NAME} for ${VERSION}." >&2
    exit 1
fi

echo "${ASSET_SHA256}  ${ASSET_PATH}" | sha256sum -c -

apt-get install --no-install-recommends -y "${ASSET_PATH}"

if ! command -v r2 >/dev/null 2>&1; then
    echo "ERROR: r2 binary was not found after installation." >&2
    exit 1
fi

r2 -v >/dev/null

rm -rf /var/lib/apt/lists/*
