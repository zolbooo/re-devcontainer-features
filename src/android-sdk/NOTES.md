## Android CLI

This feature now installs Google's `android` CLI by running:

```sh
curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install.sh | bash
```

Use the new CLI for package and emulator management:

- `android --sdk "$ANDROID_HOME" sdk list "platform-tools*"`
- `android --sdk "$ANDROID_HOME" sdk install "platforms;android-34"`
- `android --sdk "$ANDROID_HOME" emulator list --long`

## Emulator profiles

`wanted_emulators` now accepts Android CLI profile names such as `medium_phone` or `small_phone`.

- The legacy `name=system-image-package` format is no longer supported.
- Managed AVDs are created under `$HOME/.android/avd`.
- `ANDROID_AVD_HOME` is exported as `$HOME/.android/avd` for shell compatibility.
