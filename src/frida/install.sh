#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-17.7.3}"
TOOLS_VERSION="${TOOLS_VERSION:-14.6.0}"
OBJECTION_VERSION="${OBJECTION_VERSION:-1.11.0}"
ANDROID_ARCH="${ANDROID_ARCH:-arm64}"
ANDROID_ARTIFACT="${ANDROID_ARTIFACT:-server}"

if [[ -z "${VERSION}" ]]; then
    echo "ERROR: VERSION is empty." >&2
    exit 1
fi

if [[ -z "${TOOLS_VERSION}" ]]; then
    echo "ERROR: TOOLS_VERSION is empty." >&2
    exit 1
fi

VERSION="${VERSION#v}"
TOOLS_VERSION="${TOOLS_VERSION#v}"

case "${ANDROID_ARCH}" in
    arm | arm64 | x86 | x86_64)
        ;;
    *)
        echo "ERROR: Unsupported Android architecture: ${ANDROID_ARCH}." >&2
        exit 1
        ;;
esac

case "${ANDROID_ARTIFACT}" in
    server)
        ASSET_NAME="frida-server-${VERSION}-android-${ANDROID_ARCH}.xz"
        EXTRACTED_NAME="frida-server"
        ;;
    gadget)
        ASSET_NAME="frida-gadget-${VERSION}-android-${ANDROID_ARCH}.so.xz"
        EXTRACTED_NAME="frida-gadget.so"
        ;;
    *)
        echo "ERROR: Unsupported Android artifact type: ${ANDROID_ARTIFACT}." >&2
        exit 1
        ;;
esac

RELEASE_API_URL="https://api.github.com/repos/frida/frida/releases/tags/${VERSION}"

apt-get update
apt-get install --no-install-recommends -y ca-certificates curl jq python3 python3-pip xz-utils
rm -rf /var/lib/apt/lists/*

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

RELEASE_JSON="${TMP_DIR}/release.json"
ASSET_PATH="${TMP_DIR}/${ASSET_NAME}"

if ! curl -fsSL "${RELEASE_API_URL}" -o "${RELEASE_JSON}"; then
    echo "ERROR: Failed to fetch Frida release metadata for ${VERSION}." >&2
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

PIP_PACKAGES=("frida==${VERSION}" "frida-tools==${TOOLS_VERSION}")
if [[ "${OBJECTION_VERSION}" != "none" ]]; then
    PIP_PACKAGES+=("objection==${OBJECTION_VERSION}")
fi

if ! pip3 install --no-cache-dir "${PIP_PACKAGES[@]}"; then
    if ! pip3 install --no-cache-dir --break-system-packages "${PIP_PACKAGES[@]}"; then
        echo "ERROR: Failed to install Python packages: ${PIP_PACKAGES[*]}." >&2
        exit 1
    fi
fi

INSTALL_ROOT="/usr/local/lib/frida"
VERSION_DIR="${INSTALL_ROOT}/${VERSION}"
CURRENT_LINK="${INSTALL_ROOT}/current"
TARGET_DIR="${VERSION_DIR}/android/${ANDROID_ARCH}"
TARGET_PATH="${TARGET_DIR}/${EXTRACTED_NAME}"

mkdir -p "${INSTALL_ROOT}"
rm -rf "${VERSION_DIR}"
mkdir -p "${TARGET_DIR}"

xz -dc "${ASSET_PATH}" > "${TARGET_PATH}"

if [[ "${ANDROID_ARTIFACT}" == "server" ]]; then
    chmod +x "${TARGET_PATH}"
fi

ln -sfn "${VERSION_DIR}" "${CURRENT_LINK}"

if ! command -v frida >/dev/null 2>&1; then
    echo "ERROR: frida command was not found after installation." >&2
    exit 1
fi

frida --version >/dev/null

if [[ ! -f "${CURRENT_LINK}/android/${ANDROID_ARCH}/${EXTRACTED_NAME}" ]]; then
    echo "ERROR: Expected artifact was not found at ${CURRENT_LINK}/android/${ANDROID_ARCH}/${EXTRACTED_NAME}." >&2
    exit 1
fi
