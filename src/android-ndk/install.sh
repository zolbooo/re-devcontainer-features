#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-r27c}"
API_LEVEL="${API_LEVEL:-24}"

if [[ -z "${VERSION}" ]]; then
    echo "ERROR: VERSION is empty." >&2
    exit 1
fi

# Strip leading 'v' if present, though NDK versions use 'r' prefix.
VERSION="${VERSION#v}"

# Validate API level is numeric.
if ! [[ "${API_LEVEL}" =~ ^[0-9]+$ ]]; then
    echo "ERROR: API_LEVEL must be a number, got: ${API_LEVEL}." >&2
    exit 1
fi

NDK_ZIP="android-ndk-${VERSION}-linux.zip"
NDK_URL="https://dl.google.com/android/repository/${NDK_ZIP}"

apt-get update
apt-get install --no-install-recommends -y \
    ca-certificates \
    cmake \
    curl \
    file \
    ninja-build \
    unzip
rm -rf /var/lib/apt/lists/*

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "INFO: Downloading NDK ${VERSION} from ${NDK_URL}..."
if ! curl -fL --retry 5 --retry-delay 2 "${NDK_URL}" -o "${TMP_DIR}/${NDK_ZIP}"; then
    echo "ERROR: Failed to download NDK ${VERSION}. Check that the version exists." >&2
    exit 1
fi

echo "INFO: Extracting NDK..."
unzip -q "${TMP_DIR}/${NDK_ZIP}" -d "${TMP_DIR}"

EXTRACTED_DIR="${TMP_DIR}/android-ndk-${VERSION}"
if [[ ! -d "${EXTRACTED_DIR}" ]]; then
    echo "ERROR: Expected directory ${EXTRACTED_DIR} not found after extraction." >&2
    exit 1
fi

INSTALL_ROOT="/usr/local/lib/android-ndk"
VERSION_DIR="${INSTALL_ROOT}/${VERSION}"
CURRENT_LINK="${INSTALL_ROOT}/current"

mkdir -p "${INSTALL_ROOT}"
rm -rf "${VERSION_DIR}"
mv "${EXTRACTED_DIR}" "${VERSION_DIR}"
ln -sfn "${VERSION_DIR}" "${CURRENT_LINK}"

# Write a helper script with cross-compilation variables for Makefile-based projects.
cat > "${INSTALL_ROOT}/env.sh" <<ENVEOF
# Android NDK cross-compilation environment for ARM64.
# Source this file to configure CC/CXX/AR/STRIP for Makefile-based builds.
export ANDROID_NDK_HOME="${CURRENT_LINK}"
export ANDROID_API_LEVEL="${API_LEVEL}"
export CC="aarch64-linux-android${API_LEVEL}-clang"
export CXX="aarch64-linux-android${API_LEVEL}-clang++"
export AR="llvm-ar"
export STRIP="llvm-strip"
export RANLIB="llvm-ranlib"
export CMAKE_TOOLCHAIN_FILE="${CURRENT_LINK}/build/cmake/android.toolchain.cmake"
ENVEOF

TOOLCHAIN_BIN="${CURRENT_LINK}/toolchains/llvm/prebuilt/linux-x86_64/bin"

if [[ ! -x "${TOOLCHAIN_BIN}/aarch64-linux-android${API_LEVEL}-clang" ]]; then
    echo "ERROR: Expected compiler not found at ${TOOLCHAIN_BIN}/aarch64-linux-android${API_LEVEL}-clang." >&2
    echo "INFO: Available ARM64 compilers:" >&2
    ls "${TOOLCHAIN_BIN}"/aarch64-linux-android*-clang 2>/dev/null || echo "(none found)"
    exit 1
fi

if [[ ! -f "${CURRENT_LINK}/build/cmake/android.toolchain.cmake" ]]; then
    echo "ERROR: CMake toolchain file not found at ${CURRENT_LINK}/build/cmake/android.toolchain.cmake." >&2
    exit 1
fi

echo "INFO: Android NDK ${VERSION} installed successfully (API level ${API_LEVEL})."
