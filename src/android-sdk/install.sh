#!/bin/bash
set -e
set +H

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
URL_SDK="https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip"

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
    unzip \
    wget \
    usbutils \
    "${EMULATOR_RUNTIME_PACKAGES[@]}"
sudo apt clean

# Prepare install folder.
mkdir -p "$ANDROID_HOME"
chown -R "$_REMOTE_USER:$_REMOTE_USER" "$ANDROID_HOME"

su - "$_REMOTE_USER"

export ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-$ANDROID_HOME/avd}"
mkdir -p "$ANDROID_AVD_HOME"

cd "$ANDROID_HOME"

tmp_dir="$(mktemp -d)"
wget -q "$URL_SDK" -O "$tmp_dir/sdk.zip"
unzip -q "$tmp_dir/sdk.zip" -d "$tmp_dir"

# Replace cmdline-tools/latest atomically to avoid mv collisions when the directory already exists.
mkdir -p "$ANDROID_HOME/cmdline-tools"
rm -rf "$ANDROID_HOME/cmdline-tools/latest"
mv "$tmp_dir/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
rm -rf "$tmp_dir"

cd "$ANDROID_HOME"

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Save original JAVA_HOME.
OG_JAVA_HOME=$JAVA_HOME

# thanks https://askubuntu.com/questions/772235/how-to-find-path-to-java#comment2258200_1029326.
export JAVA_HOME=$(dirname $(dirname $(update-alternatives --list javac 2>&1 | head -n 1)))

# TODO: Update everything to future-proof for the link getting stale.
# yes | sdkmanager "cmdline-tools;latest"
# Download the platform tools.
yes | sdkmanager "${PACKAGES[@]}"

if [ -n "${WANTED_EMULATORS:-}" ]; then
    "$SCRIPT_DIR/setup-emulators.sh"
fi

# Restore JAVA_HOME.
export JAVA_HOME=$OG_JAVA_HOME

# Expose a stable build-tools path for PATH exports.
sudo ln -sfn "$ANDROID_HOME/build-tools/$BUILD_TOOLS" /usr/local/lib/android-build-tools

# Make sure the Android SDK has the correct permissions.
sudo chown -R "$_REMOTE_USER:$_REMOTE_USER" "$ANDROID_HOME"

# Exist subshell.
exit
