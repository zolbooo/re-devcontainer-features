#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-1.5.5}"

if [[ -z "${VERSION}" ]]; then
    echo "ERROR: VERSION is empty." >&2
    exit 1
fi

VERSION="${VERSION#v}"
TAG="v${VERSION}"
ASSET_NAME="jadx-${VERSION}.zip"
RELEASE_API_URL="https://api.github.com/repos/skylot/jadx/releases/tags/${TAG}"

apt-get update
apt-get install --no-install-recommends -y ca-certificates curl jq unzip
rm -rf /var/lib/apt/lists/*

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

RELEASE_JSON="${TMP_DIR}/release.json"
ASSET_PATH="${TMP_DIR}/${ASSET_NAME}"

if ! curl -fsSL "${RELEASE_API_URL}" -o "${RELEASE_JSON}"; then
    echo "ERROR: Failed to fetch JADX release metadata for ${TAG}." >&2
    exit 1
fi

ASSET_URL="$(jq -r --arg name "${ASSET_NAME}" '.assets[] | select(.name == $name) | .browser_download_url' "${RELEASE_JSON}" | head -n 1)"
ASSET_DIGEST="$(jq -r --arg name "${ASSET_NAME}" '.assets[] | select(.name == $name) | .digest' "${RELEASE_JSON}" | head -n 1)"

if [[ -z "${ASSET_URL}" || "${ASSET_URL}" == "null" ]]; then
    echo "ERROR: Could not find asset URL for ${ASSET_NAME} in release ${TAG}." >&2
    exit 1
fi

if [[ -z "${ASSET_DIGEST}" || "${ASSET_DIGEST}" == "null" ]]; then
    echo "ERROR: Could not find digest for ${ASSET_NAME} in release ${TAG}." >&2
    exit 1
fi

if [[ "${ASSET_DIGEST}" != sha256:* ]]; then
    echo "ERROR: Unsupported digest format: ${ASSET_DIGEST}." >&2
    exit 1
fi

ASSET_SHA256="${ASSET_DIGEST#sha256:}"

if ! curl -fL --retry 5 --retry-delay 2 "${ASSET_URL}" -o "${ASSET_PATH}"; then
    echo "ERROR: Failed to download ${ASSET_NAME} for ${TAG}." >&2
    exit 1
fi

echo "${ASSET_SHA256}  ${ASSET_PATH}" | sha256sum -c -

INSTALL_ROOT="/usr/local/lib/jadx"
VERSION_DIR="${INSTALL_ROOT}/${VERSION}"
CURRENT_LINK="${INSTALL_ROOT}/current"

mkdir -p "${INSTALL_ROOT}"
rm -rf "${VERSION_DIR}"
mkdir -p "${VERSION_DIR}"
unzip -q "${ASSET_PATH}" -d "${VERSION_DIR}"

chmod +x "${VERSION_DIR}/bin/jadx" "${VERSION_DIR}/bin/jadx-gui"

ln -sfn "${VERSION_DIR}" "${CURRENT_LINK}"
ln -sfn "${CURRENT_LINK}/bin/jadx" /usr/local/bin/jadx
ln -sfn "${CURRENT_LINK}/bin/jadx-gui" /usr/local/bin/jadx-gui
