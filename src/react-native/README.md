# React Native (react-native)

Install Node.js, uv, and hermes-dec for React Native Hermes reverse engineering.

## Example Usage

```json
"features": {
    "ghcr.io/zolbooo/re-devcontainer-features/react-native:1": {}
}
```

## Options

| Options Id         | Description                     | Type   | Default Value |
| ------------------ | ------------------------------- | ------ | ------------- |
| uv_version         | uv standalone installer version | string | 0.10.9        |
| hermes_dec_version | hermes-dec PyPI version         | string | 0.1.0         |

## Installed Paths

- `node`, `npm`, and `npx` are provided by the official Dev Container Node feature.
- `uv` and `uvx` are installed to `/usr/local/bin`.
- `hermes-dec` CLI entrypoints are installed to `/usr/local/bin`:
    - `hbc-file-parser`
    - `hbc-disassembler`
    - `hbc-decompiler`

---

_Note: This file was generated from the feature definition. Add additional notes to a `NOTES.md`._
