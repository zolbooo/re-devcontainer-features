#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-3.0.1}"

if [[ -z "${VERSION}" ]]; then
    echo "ERROR: VERSION is empty." >&2
    exit 1
fi

VERSION="${VERSION#v}"
TAG="v${VERSION}"
ASSET_NAME="apktool_${VERSION}.jar"
RELEASE_API_URL="https://api.github.com/repos/iBotPeaches/Apktool/releases/tags/${TAG}"

apt-get update
apt-get install --no-install-recommends -y ca-certificates curl jq
rm -rf /var/lib/apt/lists/*

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

RELEASE_JSON="${TMP_DIR}/release.json"
ASSET_PATH="${TMP_DIR}/${ASSET_NAME}"

if ! curl -fsSL "${RELEASE_API_URL}" -o "${RELEASE_JSON}"; then
    echo "ERROR: Failed to fetch Apktool release metadata for ${TAG}." >&2
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

INSTALL_ROOT="/usr/local/lib/apktool"
VERSION_DIR="${INSTALL_ROOT}/${VERSION}"
CURRENT_LINK="${INSTALL_ROOT}/current"

mkdir -p "${INSTALL_ROOT}"
rm -rf "${VERSION_DIR}"
mkdir -p "${VERSION_DIR}"
mv "${ASSET_PATH}" "${VERSION_DIR}/${ASSET_NAME}"

WRAPPER_PATH="${VERSION_DIR}/apktool"
cat > "${WRAPPER_PATH}" <<'EOF'
#!/bin/bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
JAR_FILE="$(ls "${SCRIPT_DIR}"/apktool_*.jar 2>/dev/null | sort -V | tail -n 1 || true)"

if [[ -z "${JAR_FILE}" ]]; then
    echo "ERROR: Could not locate apktool jar in ${SCRIPT_DIR}." >&2
    exit 1
fi

exec java -Xmx1024M \
    -Dfile.encoding=utf-8 \
    -Djdk.util.zip.disableZip64ExtraFieldValidation=true \
    -Djdk.nio.zipfs.allowDotZipEntry=true \
    -jar "${JAR_FILE}" "$@"
EOF

chmod +x "${WRAPPER_PATH}"

ln -sfn "${VERSION_DIR}" "${CURRENT_LINK}"
ln -sfn "${CURRENT_LINK}/apktool" /usr/local/bin/apktool
