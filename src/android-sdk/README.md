
# Android SDK (android-sdk)

Install Android SDK packages and emulators using Google's Android CLI.

## Example Usage

```json
"features": {
    "ghcr.io/zolbooo/re-devcontainer-features/android-sdk:2": {}
}
```

```json
"features": {
    "ghcr.io/zolbooo/re-devcontainer-features/android-sdk:2": {
        "wanted_emulators": "medium_phone"
    }
}
```

The supported automation surface is the `android` CLI:

```sh
android --sdk "$ANDROID_HOME" sdk list "platform-tools*"
android --sdk "$ANDROID_HOME" emulator list --long
```

`wanted_emulators` now accepts Android CLI emulator profiles instead of `name=system-image-package` entries.

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| platform | SDK platform version | string | 34 |
| build_tools | SDK build-tools version | string | 34.0.0 |
| base_packages | packages will override default packages, split by space | string | - |
| extra_packages | extra packages, split by space | string | - |
| wanted_emulators | space-separated Android CLI emulator profiles such as 'medium_phone small_phone' | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zolbooo/re-devcontainer-features/blob/main/src/android-sdk/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
