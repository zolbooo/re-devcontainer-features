#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

VERSION="${VERSION:-latest}"

if [[ -z "${VERSION}" ]]; then
    echo "ERROR: VERSION is empty." >&2
    exit 1
fi

# ── System dependencies ───────────────────────────────────────────────
apt-get update
apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libcapstone-dev \
    libicu-dev \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip
rm -rf /var/lib/apt/lists/*

# ── Ensure a C++20-capable compiler is available ──────────────────────
GCC_MAJOR="$(gcc -dumpversion 2>/dev/null | cut -d. -f1 || echo 0)"
if [[ "${GCC_MAJOR}" -lt 13 ]]; then
    echo "INFO: gcc ${GCC_MAJOR} found; attempting to install gcc-13 for C++20 support."
    apt-get update
    if apt-get install --no-install-recommends -y gcc-13 g++-13; then
        update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 130 \
            --slave /usr/bin/g++ g++ /usr/bin/g++-13
    else
        echo "WARN: gcc-13 not available in apt repos. Build may fail if default gcc lacks C++20." >&2
    fi
    rm -rf /var/lib/apt/lists/*
fi

# ── Python dependencies ──────────────────────────────────────────────
if ! pip3 install --no-cache-dir pyelftools requests; then
    if ! pip3 install --no-cache-dir --break-system-packages pyelftools requests; then
        echo "ERROR: Failed to install Python packages pyelftools and requests." >&2
        exit 1
    fi
fi

# ── Clone blutter ────────────────────────────────────────────────────
INSTALL_ROOT="/usr/local/lib/blutter"
REPO_URL="https://github.com/worawit/blutter.git"

if [[ "${VERSION}" == "latest" ]]; then
    RESOLVED_VERSION="$(git ls-remote "${REPO_URL}" HEAD | awk '{print $1}')"
    if [[ -z "${RESOLVED_VERSION}" ]]; then
        echo "ERROR: Failed to resolve HEAD commit for ${REPO_URL}." >&2
        exit 1
    fi
    CLONE_REF=""
else
    RESOLVED_VERSION="${VERSION}"
    CLONE_REF="${VERSION}"
fi

VERSION_DIR="${INSTALL_ROOT}/${RESOLVED_VERSION}"
CURRENT_LINK="${INSTALL_ROOT}/current"

mkdir -p "${INSTALL_ROOT}"
rm -rf "${VERSION_DIR}"

if [[ -n "${CLONE_REF}" ]]; then
    git clone --depth 1 --branch "${CLONE_REF}" "${REPO_URL}" "${VERSION_DIR}"
else
    git clone --depth 1 "${REPO_URL}" "${VERSION_DIR}"
fi

ln -sfn "${VERSION_DIR}" "${CURRENT_LINK}"

# ── Wrapper script ───────────────────────────────────────────────────
WRAPPER_PATH="/usr/local/bin/blutter"
cat > "${WRAPPER_PATH}" <<'WRAPPER'
#!/bin/bash
set -euo pipefail
exec python3 /usr/local/lib/blutter/current/blutter.py "$@"
WRAPPER
chmod +x "${WRAPPER_PATH}"

# ── Verify installation ─────────────────────────────────────────────
if [[ ! -f "${CURRENT_LINK}/blutter.py" ]]; then
    echo "ERROR: blutter.py not found at ${CURRENT_LINK}/blutter.py." >&2
    exit 1
fi

if ! command -v blutter >/dev/null 2>&1; then
    echo "ERROR: blutter wrapper command not found in PATH." >&2
    exit 1
fi

echo "INFO: Blutter installed successfully (${RESOLVED_VERSION})."
