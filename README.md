# devcontainer-features

Collection of `.devcontainer` features for reverse engineering. A fork of [NordcomInc/devcontainer-features](https://github.com/NordcomInc/devcontainer-features).

## Table of Contents

- [General](#general)
    - [Ghidra](#ghidra)
    - [Radare2](#radare2)
    - [Frida](#frida)
- [Android](#android)
    - [Android SDK](#android-sdk)
    - [Android NDK](#android-ndk)
    - [Apktool](#apktool)
    - [JADX](#jadx)
- [Flutter](#flutter)
    - [Blutter](#blutter)
- [Frameworks](#frameworks)
    - [React Native](#react-native-feature)

## General

### <a id="ghidra">`ghcr.io/zolbooo/re-devcontainer-features/ghidra:1`</a>

Install Ghidra reverse engineering framework from official GitHub releases. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/ghidra).

After installation, both `ghidra` (GUI launcher) and `analyzeHeadless` (headless analysis script) will be available on `PATH`.

### <a id="radare2">`ghcr.io/zolbooo/re-devcontainer-features/radare2:1`</a>

Install Radare2 CLI from official GitHub releases. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/radare2).

### <a id="frida">`ghcr.io/zolbooo/re-devcontainer-features/frida:1`</a>

Install Frida CLI/tools and Android Frida server or gadget artifacts. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/frida).

## Android

### <a id="android-sdk">`ghcr.io/zolbooo/re-devcontainer-features/android-sdk:1`</a>

Setup and update the Android SDK. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/android-sdk).

### <a id="android-ndk">`ghcr.io/zolbooo/re-devcontainer-features/android-ndk:1`</a>

Install Android NDK cross-compilation toolchain for building native ARM64 libraries. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/android-ndk).

### <a id="apktool">`ghcr.io/zolbooo/re-devcontainer-features/apktool:1`</a>

Install Apktool CLI from official GitHub releases. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/apktool).

### <a id="jadx">`ghcr.io/zolbooo/re-devcontainer-features/jadx:1`</a>

Install JADX CLI and GUI from official GitHub releases. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/jadx).

## Flutter

### <a id="blutter">`ghcr.io/zolbooo/re-devcontainer-features/blutter:1`</a>

Install Blutter - Flutter reverse engineering tool from source. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/blutter).

## Frameworks

### <a id="react-native-feature">`ghcr.io/zolbooo/re-devcontainer-features/react-native:1`</a>

Install Node.js, uv, and hermes-dec for React Native Hermes reverse engineering. [View source](https://github.com/zolbooo/re-devcontainer-features/tree/main/src/react-native).
