
# Android SDK (android-sdk)

Install Android SDK `cmdline-tools`, `platform-tools`, and, `build-tools`.

## Example Usage

```json
"features": {
    "ghcr.io/zolbooo/android-devcontainer-features/android-sdk:1": {}
}
```

```json
"features": {
    "ghcr.io/zolbooo/android-devcontainer-features/android-sdk:1": {
        "wanted_emulators": "pixel34=system-images;android-34;google_apis;x86_64"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| platform | SDK platform version | string | 34 |
| build_tools | SDK build-tools version | string | 34.0.0 |
| base_packages | packages will override default packages, split by space | string | - |
| extra_packages | extra packages, split by space | string | - |
| wanted_emulators | space-separated entries in name=system-image-package format | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zolbooo/android-devcontainer-features/blob/main/src/android-sdk/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
