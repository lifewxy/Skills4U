# Zipic CLI Reference

Ground-truth spec for the `zipic` binary shipped with Zipic.app >= 1.9.5. The CLI talks to the running GUI over a UDS socket at `~/Library/Application Support/zipic/cli.sock` and returns line-delimited JSON. If the GUI isn't running, the CLI auto-launches it and waits up to 8 s for the socket to bind.

Install path: `/usr/local/bin/zipic` (symlink into `Zipic.app/Contents/Resources/zipic`). Installed via Zipic menu bar → "Install zipic CLI" (one-time admin password prompt).

## Synopsis

```
zipic <command> [arguments]
zipic --version | -v
zipic --help    | -h
```

## Global flags

| Flag         | Effect                                                 |
| ------------ | ------------------------------------------------------ |
| `--json`     | Emit a single JSON line on stdout. Required for AI use. |
| `--dry-run`  | (compress only) Return the resolved plan, no work done. |
| `--version`  | Print CLI version (e.g. `zipic 0.1.0`) and exit.        |
| `--help`     | Print built-in help and exit.                           |

## Exit codes

| Code | Constant          | Meaning                                                  |
| ---- | ----------------- | -------------------------------------------------------- |
| 0    | success           | Operation completed.                                     |
| 1    | businessError     | Runtime/business failure (e.g. `pro_required`, `not_found`, `internal_error`). |
| 64   | usageError        | Invalid arguments (bad flag, wrong enum, missing required value). |
| 65   | guiNotRunning     | Couldn't reach the Zipic GUI socket and auto-launch failed. |

## Subcommand: `compress`

```
zipic compress [flags] <files-or-dirs>...
```

Positional args are files or directories. Directories are walked recursively for image files.

### compress flags

| Flag                                              | Type                                       | Default          | Notes |
| ------------------------------------------------- | ------------------------------------------ | ---------------- | ----- |
| `--level <1-6>`                                   | int 1–6                                    | from current setting / preset | 1 = best quality, 6 = smallest. |
| `--format <value>`                                | `original\|jpeg\|png\|webp\|avif\|heic\|jxl` | inherited       | `avif` and `jxl` are Pro-only output formats; gated server-side. SVG is **not** an output value (SVG inputs stay SVG). |
| `--width <px>`                                    | int                                        | 0 (auto)         | 0 = no resize on this axis. |
| `--height <px>`                                   | int                                        | 0 (auto)         | 0 = no resize on this axis. |
| `--keep-aspect` / `--no-keep-aspect`              | bool                                       | keep             | Lock aspect ratio when one axis is set. |
| `--preserve-metadata` / `--no-metadata`           | bool                                       | inherited        | EXIF/ICC retention. |
| `--progressive`                                   | bool                                       | off              | Progressive JPEG. |
| `--tiff-compression <lzw\|zip>`                   | enum                                       | inherited        | TIFF output codec. |
| `--location <original\|custom>`                   | enum                                       | inherited        | `original` = save next to input; `custom` = `--output`. Auto-set to `custom` if `--output` is given without explicit `--location`. |
| `--output <dir>`                                  | path                                       | —                | Output directory. Forces `--location custom` when set. |
| `--suffix <text>`                                 | string                                     | inherited        | Filename suffix. |
| `--add-suffix` / `--no-suffix`                    | bool                                       | inherited        | Toggle suffix usage. |
| `--subfolder <name>`                              | string                                     | inherited        | Output subfolder under destination. |
| `--add-subfolder` / `--no-subfolder`              | bool                                       | inherited        | Toggle subfolder usage. |
| `--keep-hierarchy`                                | bool                                       | off              | Mirror the source directory tree under `--output`. |
| `--overwrite`                                     | bool                                       | off              | Replace existing output files. |
| `--autocopy <off\|path\|file\|markdown>`          | enum                                       | `off`            | After compression, copy to clipboard as `path` / `file` / `markdown` snippet. |
| `--preset <name-or-id>`                           | string                                     | —                | Use a saved preset as base; explicit flags override its values. UUID match wins; falls back to name; "default" matches the seeded default preset regardless of locale. |
| `--dry-run`                                       | bool                                       | off              | Returns `data.plan` without compressing. |

### compress JSON response

Success (after a real run):

```json
{
  "tool": "compress",
  "isError": false,
  "version": "<protocol-version>",
  "data": {
    "results": [
      {
        "id": "UUID",
        "input": "/path/to/in.png",
        "output": "/path/to/out.png",
        "file_name": "in.png",
        "input_bytes": 123456,
        "output_bytes": 56789,
        "saved_pct": 54,
        "state": "success",          // or "kept_source" | "failed" | other
        "started_at": "2026-05-08T10:00:00Z"
      }
    ],
    "completed_count": 1,
    "total_urls": 1
  }
}
```

`state` values:
- `success` — compressed, output file written.
- `kept_source` — compressed result was larger than the input, so the original was kept.
- `failed` (or any other string) — failure for that file; check the GUI for details.

Dry run:

```json
{
  "tool": "compress", "isError": false,
  "data": {
    "plan": {
      "urls": ["/p/a.png", "/p/b.jpg"],
      "option": { "level": 3, "output_format": "webp", "width": 1920, "height": 0,
                  "keep_aspect_ratio": true, "location": "custom",
                  "output_directory": "/Users/.../out", "...": "..." }
    }
  }
}
```

## Subcommand: `preset`

```
zipic preset <subcommand> [args]
```

| Subcommand                                              | Arguments                                       |
| ------------------------------------------------------- | ----------------------------------------------- |
| `list`                                                  | — Lists all presets.                            |
| `show <name-or-id>`                                     | Show one preset including resolved options.     |
| `create --name <text> [compress flags]`                 | Create a preset from current options + overrides. Free users limited to 1 custom preset (returns `pro_required`). |
| `delete <name-or-id>`                                   | Delete a custom preset (default cannot be deleted — returns `not_allowed`). |
| `duplicate <name-or-id>`                                | Clone an existing preset.                       |
| `set-favorite <name-or-id> [--off]`                     | Toggle favorite flag; `--off` forces unfavorite. |
| `set-default <name-or-id>`                              | **Declared but not implemented in 1.9.5** — returns `not_implemented`. |
| `import <file>`                                         | Import preset JSON; auto-renames on name collision (`<name> (Imported)`, `(Imported 2)`, …). |
| `export <name-or-id> --output <file>`                   | Export to JSON.                                 |

`create` accepts the same `--level/--format/--width/--height/--suffix/--subfolder/--output/--location/--keep-aspect/--preserve-metadata/--overwrite/--progressive` flags as `compress` (they're baked into the preset).

### preset JSON response

`preset list`:

```json
{ "tool": "preset.list", "isError": false, "data": { "presets": [
  { "id": "UUID", "name": "Default", "is_default": true, "is_favorite": false,
    "created_at": "ISO8601", "last_modified": "ISO8601",
    "option": { "level": 3, "output_format": "original", "...": "..." } }
]}}
```

`preset show / create / duplicate / import` return `data.preset = { ... }` with the same shape as a list entry.

`preset delete` returns `data: { "deleted": true, "name": "...", "id": "UUID" }`.

`preset set-favorite` returns the updated preset.

`preset export` returns `data: { "path": "/abs/out.json" }`.

## Subcommand: `list`

Reflects the GUI's current compression list, deduplicated by source path (re-compressing replaces the previous entry — it's a snapshot, not an append-only log).

```
zipic list [--limit N] [--status all|success|failed]
zipic list clear
```

| Flag             | Type | Default | Notes                                |
| ---------------- | ---- | ------- | ------------------------------------ |
| `--limit <N>`    | int  | 0 (all) | Cap the returned items.              |
| `--status <v>`   | enum | `all`   | Filter by `success` / `failed`.      |

`list` JSON:

```json
{ "tool": "list", "isError": false, "data": {
  "items": [
    { "id": "UUID", "input": "/p/a.png", "output": "/p/a-min.png",
      "file_name": "a.png", "input_bytes": 100, "output_bytes": 60,
      "saved_pct": 40, "state": "success", "started_at": "ISO8601" }
  ],
  "summary": { "count": 1, "skipped": 0, "storage_saved_bytes": 40, "total": 1 }
}}
```

`list clear` returns `data: { "cleared": true }`.

## Error response shape

```json
{ "tool": "<tool>", "isError": true, "version": "<v>",
  "error": { "code": "<code>", "message": "<human readable>", "data": { ... optional ... } } }
```

Common `error.code` values:

| Code                | Meaning                                           |
| ------------------- | ------------------------------------------------- |
| `invalid_arguments` | Missing/invalid argument. Exit 64.                |
| `not_found`         | Preset / file not found. Exit 1.                  |
| `not_allowed`       | E.g. trying to delete the default preset. Exit 1. |
| `not_implemented`   | E.g. `preset set-default` in 1.9.5. Exit 1.       |
| `internal_error`    | Unexpected. Exit 1.                               |
| `gui_not_running`   | Auto-launch failed. Exit 65.                      |
| `io_error`          | Socket / IO problem. Exit 1.                      |
| `pro_required`      | Free-tier gate hit. Exit 1.                       |

### Pro-gate (`pro_required`) shape

```json
{ "isError": true, "error": {
  "code": "pro_required",
  "message": "Converting to AVIF is a Pro-only feature. Upgrade to Pro to enable it.",
  "data": {
    "purchase_url": "https://...",
    "trial_available": true,
    "trial_issue_url": "https://trial.zipic.app/issue",
    "blocked_format": "AVIF",       // when format-related
    "direction": "output",          // "output" or "input"
    "blocked_input": "/p/x.svg",    // when input-format-related
    "remaining": 3,                 // when quota-related
    "requested": 12                 //
  }
}}
```

Triggers:
- `--format avif` or `--format jxl` while not activated → `direction: "output"`.
- Input file is SVG / APNG / animated PNG / AVIF / TIFF / ICNS / JXL while not activated → `direction: "input"`.
- Free-tier daily quota exceeded → `remaining` / `requested` populated.
- `preset create` while user already has 1 custom preset → quota-style payload.

## CLI vs URL Scheme matrix

| Capability                              | CLI | URL Scheme |
| --------------------------------------- | --- | ---------- |
| Per-file structured results (sizes, %)  | ✅  | ❌         |
| Exit code / `isError`                   | ✅  | ❌         |
| Dry run                                 | ✅  | ❌         |
| Presets (list/show/create/delete/...)   | ✅  | ❌         |
| Compression history (`list`)            | ✅  | ❌         |
| Pro gate as structured error            | ✅  | (silent / GUI alert) |
| Auto-launch Zipic.app                   | ✅  | (LaunchServices) |
| Path encoding required                  | ❌  | ✅ (`urllib.parse.quote`) |
| Available on Zipic < 1.9.5              | ❌  | ✅         |

When in doubt, prefer CLI. Fall back to URL Scheme only when `app_version < 1.9.5` or `command -v zipic` is empty.
