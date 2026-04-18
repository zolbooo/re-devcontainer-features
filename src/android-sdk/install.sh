#!/bin/bash
set -euo pipefail
set +H

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ANDROID_CLI_INSTALL_URL="https://dl.google.com/android/cli/latest/linux_x86_64/install.sh"

# Options.
if [ -z "$PLATFORM" ]; then
    PLATFORM="34"
fi
if [ -z "$BUILD_TOOLS" ]; then
    BUILD_TOOLS="34.0.0"
fi
if [ -n "$BASE_PACKAGES" ]; then
    IFS=' ' read -ra PACKAGES <<< "$BASE_PACKAGES"
else
    PACKAGES=( "platform-tools" "platforms;android-$PLATFORM" "build-tools;$BUILD_TOOLS" )
fi
if [ -n "$EXTRA_PACKAGES" ]; then
    IFS=' ' read -ra extra <<< "$EXTRA_PACKAGES"
    PACKAGES=("${PACKAGES[@]}" "${extra[@]}")
fi

if [ "$(uname -s)" != "Linux" ] || [ "$(uname -m)" != "x86_64" ]; then
    echo "ERROR: The Android CLI installer used by this feature currently supports only Linux x86_64." >&2
    exit 1
fi

EMULATOR_RUNTIME_PACKAGES=()
append_first_available_package() {
    local selected=""
    for candidate in "$@"; do
        local candidate_version
        candidate_version=$(apt-cache policy "$candidate" 2>/dev/null | awk '/Candidate:/ {print $2; exit}')
        if [ -n "$candidate_version" ] && [ "$candidate_version" != "(none)" ]; then
            selected="$candidate"
            break
        fi
    done

    if [ -n "$selected" ]; then
        EMULATOR_RUNTIME_PACKAGES+=("$selected")
    fi
}

DEBIAN_FRONTEND="noninteractive" sudo apt update

if [ -n "${WANTED_EMULATORS:-}" ]; then
    # emulator depends on common X11/GTK runtime libraries even for version checks.
    append_first_available_package "libasound2" "libasound2t64"
    append_first_available_package "libatk-bridge2.0-0"
    append_first_available_package "libatk1.0-0"
    append_first_available_package "libcups2" "libcups2t64"
    append_first_available_package "libdrm2"
    append_first_available_package "libgbm1"
    append_first_available_package "libgtk-3-0"
    append_first_available_package "libnss3"
    append_first_available_package "libpng16-16" "libpng16-16t64"
    append_first_available_package "libpulse0" "libpulse0t64"
    append_first_available_package "libx11-6"
    append_first_available_package "libx11-xcb1"
    append_first_available_package "libxcb1"
    append_first_available_package "libxcomposite1"
    append_first_available_package "libxcursor1"
    append_first_available_package "libxdamage1"
    append_first_available_package "libxkbfile1"
    append_first_available_package "libxi6"
    append_first_available_package "libxkbcommon0"
    append_first_available_package "libxrandr2"
    append_first_available_package "libxrender1"
    append_first_available_package "libxshmfence1"
    append_first_available_package "libxss1"
    append_first_available_package "libxtst6"
fi

DEBIAN_FRONTEND="noninteractive" sudo apt install --no-install-recommends -y \
    openjdk-17-jdk-headless \
    curl \
    usbutils \
    "${EMULATOR_RUNTIME_PACKAGES[@]}"
sudo apt clean

REMOTE_HOME="$(getent passwd "$_REMOTE_USER" | cut -d: -f6)"
if [ -z "$REMOTE_HOME" ]; then
    echo "ERROR: Unable to determine home directory for remote user '$_REMOTE_USER'." >&2
    exit 1
fi

REMOTE_CONFIG_HOME="$REMOTE_HOME/.config"
REMOTE_CACHE_HOME="$REMOTE_HOME/.cache"
REMOTE_ANDROID_USER_HOME="$REMOTE_HOME/.android"
REMOTE_AVD_HOME="$REMOTE_ANDROID_USER_HOME/avd"

sudo install -d -m 0755 -o "$_REMOTE_USER" -g "$_REMOTE_USER" \
    "$ANDROID_HOME" \
    "$REMOTE_CONFIG_HOME" \
    "$REMOTE_CACHE_HOME" \
    "$REMOTE_ANDROID_USER_HOME" \
    "$REMOTE_AVD_HOME"

# The feature metadata exports ANDROID_AVD_HOME via "$HOME/.android/avd", but the
# generated container env may resolve $HOME before the remote user's shell runs.
# Provide a stable compatibility path so ANDROID_AVD_HOME=/.android/avd still
# points at the remote user's actual AVD directory.
sudo install -d -m 0755 /.android
sudo ln -sfn "$REMOTE_AVD_HOME" /.android/avd

curl -fsSL "$ANDROID_CLI_INSTALL_URL" | bash

# Save original JAVA_HOME.
OG_JAVA_HOME="${JAVA_HOME:-}"

# thanks https://askubuntu.com/questions/772235/how-to-find-path-to-java#comment2258200_1029326.
export JAVA_HOME
JAVA_HOME="$(dirname "$(dirname "$(update-alternatives --list javac 2>&1 | head -n 1)")")"

run_as_remote_user() {
    sudo -u "$_REMOTE_USER" env \
        HOME="$REMOTE_HOME" \
        XDG_CONFIG_HOME="$REMOTE_CONFIG_HOME" \
        XDG_CACHE_HOME="$REMOTE_CACHE_HOME" \
        ANDROID_HOME="$ANDROID_HOME" \
        ANDROID_SDK_ROOT="$ANDROID_HOME" \
        ANDROID_AVD_HOME="$REMOTE_AVD_HOME" \
        WANTED_EMULATORS="${WANTED_EMULATORS:-}" \
        JAVA_HOME="$JAVA_HOME" \
        PATH="/usr/local/bin:$PATH" \
        "$@"
}

run_as_remote_user /usr/local/bin/android --no-metrics --sdk "$ANDROID_HOME" sdk install "${PACKAGES[@]}"

if [ -n "${WANTED_EMULATORS:-}" ]; then
    run_as_remote_user "$SCRIPT_DIR/setup-emulators.sh"
fi

# Restore JAVA_HOME.
export JAVA_HOME="$OG_JAVA_HOME"

# Expose a stable build-tools path for PATH exports.
sudo ln -sfn "$ANDROID_HOME/build-tools/$BUILD_TOOLS" /usr/local/lib/android-build-tools

# Make sure the Android SDK and Android CLI state directories have the correct permissions.
sudo chown -R "$_REMOTE_USER:$_REMOTE_USER" \
    "$ANDROID_HOME" \
    "$REMOTE_CONFIG_HOME" \
    "$REMOTE_CACHE_HOME" \
    "$REMOTE_ANDROID_USER_HOME"

# Android CLI extracts SDK tools with owner-only execute bits. Normalize modes so
# feature consumers and test users can execute installed binaries from PATH.
sudo chmod -R a+rX "$ANDROID_HOME"
