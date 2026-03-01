#!/bin/bash
set -eu

wanted_emulators="${WANTED_EMULATORS:-}"
avd_home="${ANDROID_AVD_HOME:-${HOME}/.android/avd}"

if [ -z "${wanted_emulators}" ]; then
    exit 0
fi

mkdir -p "${avd_home}"
export ANDROID_AVD_HOME="${avd_home}"

IFS=' ' read -r -a entries <<< "${wanted_emulators}"

declare -A seen_names=()
declare -A seen_packages=()
declare -a sdk_packages=("emulator")
declare -a avd_names=()
declare -a avd_packages=()

for entry in "${entries[@]}"; do
    if [[ "${entry}" != *=* ]]; then
        echo "ERROR: Invalid emulator entry '${entry}'. Expected format name=system-image-package." >&2
        exit 1
    fi

    if [[ "${entry}" == *=*=* ]]; then
        echo "ERROR: Invalid emulator entry '${entry}'. Expected exactly one '='." >&2
        exit 1
    fi

    name="${entry%%=*}"
    package="${entry#*=}"

    if [ -z "${name}" ] || [ -z "${package}" ]; then
        echo "ERROR: Invalid emulator entry '${entry}'. Name and package must be non-empty." >&2
        exit 1
    fi

    if [[ ! "${name}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo "ERROR: Invalid AVD name '${name}'. Allowed pattern: ^[A-Za-z0-9._-]+$." >&2
        exit 1
    fi

    if [[ "${package}" != system-images\;* ]]; then
        echo "ERROR: Invalid system image package '${package}'. It must start with 'system-images;'." >&2
        exit 1
    fi

    if [ -n "${seen_names[${name}]:-}" ]; then
        echo "ERROR: Duplicate AVD name '${name}' is not allowed." >&2
        exit 1
    fi

    seen_names["${name}"]=1
    avd_names+=("${name}")
    avd_packages+=("${package}")

    if [ -z "${seen_packages[${package}]:-}" ]; then
        seen_packages["${package}"]=1
        sdk_packages+=("${package}")
    fi
done

yes | sdkmanager "${sdk_packages[@]}"

for i in "${!avd_names[@]}"; do
    name="${avd_names[$i]}"
    package="${avd_packages[$i]}"
    echo "no" | avdmanager create avd -n "${name}" -k "${package}" --force

    avd_dir="${ANDROID_AVD_HOME}/${name}.avd"
    if [ ! -d "${avd_dir}" ]; then
        echo "ERROR: Failed to create AVD '${name}'. Missing directory: ${avd_dir}." >&2
        exit 1
    fi
done

echo "Created AVDs: ${avd_names[*]}"
