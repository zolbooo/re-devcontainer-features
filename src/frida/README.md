# Frida (frida)

Install Frida CLI/tools and Android Frida server or gadget artifacts.

## Example Usage

```json
"features": {
    "ghcr.io/zolbooo/re-devcontainer-features/frida:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Frida core release version | string | 17.7.3 |
| tools_version | frida-tools PyPI version | string | 14.6.0 |
| android_arch | Android architecture for downloaded Frida artifact | string | arm64 |
| android_artifact | Android artifact type to install | string | server |

## Installed Paths

- Frida client binaries (for example `frida`, `frida-ps`) are installed to your system `PATH` via `pip`.
- Android artifact path: `/usr/local/lib/frida/current/android/<android_arch>/`
  - `server`: `frida-server`
  - `gadget`: `frida-gadget.so`

## Manual Android Deployment (Server)

```bash
adb push /usr/local/lib/frida/current/android/arm64/frida-server /data/local/tmp/frida-server
adb shell "chmod 755 /data/local/tmp/frida-server && /data/local/tmp/frida-server &"
```

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zolbooo/re-devcontainer-features/blob/main/src/frida/devcontainer-feature.json). Add additional notes to a `NOTES.md`._
