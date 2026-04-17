#!/bin/bash
set -euo pipefail

wanted_emulators="${WANTED_EMULATORS:-}"
avd_home="${ANDROID_AVD_HOME:-${HOME}/.android/avd}"

if [ -z "${wanted_emulators}" ]; then
    exit 0
fi

mkdir -p "${avd_home}"
export ANDROID_AVD_HOME="${avd_home}"

IFS=' ' read -r -a entries <<< "${wanted_emulators}"

android_cli() {
    android --no-metrics --sdk "${ANDROID_HOME}" "$@"
}

profile_output="$(android_cli emulator create --list-profiles)"
declare -a available_profiles=()
while IFS= read -r line; do
    if [[ "${line}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        available_profiles+=("${line}")
    fi
done <<< "${profile_output}"

if [ "${#available_profiles[@]}" -eq 0 ]; then
    echo "ERROR: Unable to discover Android emulator profiles from the Android CLI." >&2
    exit 1
fi

declare -A known_profiles=()
for profile in "${available_profiles[@]}"; do
    known_profiles["${profile}"]=1
done

declare -A seen_profiles=()
declare -a requested_profiles=()

for entry in "${entries[@]}"; do
    if [[ "${entry}" == *=* ]]; then
        echo "ERROR: Invalid emulator entry '${entry}'. The legacy name=system-image-package format is no longer supported. Use Android CLI profiles such as 'medium_phone small_phone'." >&2
        exit 1
    fi

    if [ -z "${entry}" ]; then
        echo "ERROR: Invalid emulator entry ''. Profiles must be non-empty." >&2
        exit 1
    fi

    if [[ ! "${entry}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo "ERROR: Invalid emulator profile '${entry}'. Allowed pattern: ^[A-Za-z0-9._-]+$." >&2
        exit 1
    fi

    if [ -z "${known_profiles[${entry}]:-}" ]; then
        echo "ERROR: Unknown emulator profile '${entry}'. Available profiles: ${available_profiles[*]}." >&2
        exit 1
    fi

    if [ -n "${seen_profiles[${entry}]:-}" ]; then
        echo "ERROR: Duplicate emulator profile '${entry}' is not allowed." >&2
        exit 1
    fi

    seen_profiles["${entry}"]=1
    requested_profiles+=("${entry}")
done

android_cli sdk install emulator

for profile in "${requested_profiles[@]}"; do
    avd_dir="${ANDROID_AVD_HOME}/${profile}.avd"
    if [ -d "${avd_dir}" ]; then
        continue
    fi

    android_cli emulator create --profile "${profile}"
    if [ ! -d "${avd_dir}" ]; then
        echo "ERROR: Failed to create AVD '${profile}'. Missing directory: ${avd_dir}." >&2
        exit 1
    fi
done

echo "Created AVDs: ${requested_profiles[*]}"
