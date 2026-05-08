# Zipic URL Scheme Reference

Fallback path for Zipic < 1.9.5 or hosts where the `zipic` CLI is not installed. Fire-and-forget — there is no return data, no exit code, no structured errors.

## Format

```
zipic://compress?key=value&key=value&...
```

Invoke with `open` on macOS:

```bash
open "zipic://compress?url=/path/to/image.png&level=3"
```

Multiple files use repeated `url=` parameters:

```bash
open "zipic://compress?url=/p/a.png&url=/p/b.jpg&level=3"
```

Folders can be passed directly — Zipic walks them recursively.

## Parameters

| Parameter      | Type / Values                                                | Default | Notes |
| -------------- | ------------------------------------------------------------ | ------- | ----- |
| `url`          | path string (repeatable)                                     | —       | File or folder. URL-encode (`%20` for spaces, percent-encode CJK). At least one `url` or `data` required. |
| `data`         | URL-encoded JSON: `{"urls":["/p/a.png","/p/b.jpg"]}`         | —       | Alternative to repeated `url=`. Each entry must be an existing file/dir; non-image files and app bundles are silently skipped. |
| `level`        | int 1–6                                                      | current setting | Compression level. |
| `format`       | `jpeg\|png\|webp\|heic\|avif\|gif\|tiff\|icns\|pdf\|jxl`     | keep original | Output format. **Not** a valid value: `svg` — SVG inputs are optimized in-place and stay SVG. AVIF/JXL require Pro. |
| `width`        | int (pixels)                                                 | 0 (auto) |  |
| `height`       | int (pixels)                                                 | 0 (auto) |  |
| `ratio`        | bool (`true`/`false`)                                        | true    | Keep aspect ratio when only one of width/height is set. |
| `directory`    | absolute path string                                         | —       | Output directory (use with `location=custom`). |
| `location`     | `original\|custom`                                           | inherited | `original` = save next to input; `custom` = use `directory`. |
| `overwrite`    | bool                                                         | false   | Replace existing output files. |
| `addSuffix`    | bool                                                         | inherited | Toggle suffix usage. |
| `suffix`       | string                                                       | inherited | Filename suffix. |
| `addSubfolder` | bool                                                         | inherited | Toggle subfolder usage. |
| `subfolder`    | string                                                       | inherited | Subfolder name under destination. |
| `specified`    | bool                                                         | false   | Save to Zipic's configured default output directory rather than overwriting input. |
| `progressive`  | bool                                                         | inherited | Progressive JPEG. |

Anything Zipic doesn't recognize is ignored. Bool values must be the literals `true` or `false`.

## Path encoding

Required for spaces and non-ASCII (CJK, accents, etc.). The CLI does NOT need this; URL Scheme does.

```bash
encoded=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1],safe='/'))" "$path")
open "zipic://compress?url=${encoded}&level=3"
```

Batch:

```bash
params=""
for f in /path/to/folder/*.{png,jpg,jpeg,webp}; do
  encoded=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1],safe='/'))" "$f")
  params="${params}&url=${encoded}"
done
open "zipic://compress?${params:1}&level=3&format=webp"
```

`safe='/'` keeps the path separator unencoded; everything else (spaces, `?`, CJK, etc.) gets percent-encoded.

## Examples

```bash
# 1. Compress one file at level 3, keep format
open "zipic://compress?url=/path/to/image.png&level=3"

# 2. Batch, repeated url=
open "zipic://compress?url=/p/a.png&url=/p/b.jpg&url=/p/c.jpeg&level=3"

# 3. Convert to WebP (good for web)
open "zipic://compress?url=/p/photo.png&format=webp&level=3"

# 4. Resize to 1920px wide, keep aspect, save to custom dir
open "zipic://compress?url=/p/photo.png&width=1920&ratio=true&level=3&location=custom&directory=/Users/me/out"
```

## Limitations vs CLI

- ❌ No structured response (no per-file output paths or sizes).
- ❌ No exit code; failures are silent. Pre-check `[ -e "$path" ]` and that Zipic is installed.
- ❌ No preset access. No history queries.
- ❌ No dry-run.
- ❌ Pro-gate hits surface as a GUI alert / silent skip, not as parseable output.
- ✅ Works on Zipic >= 1.9.0 (>= 1.9.5 not required).

For any task where you need to know whether compression succeeded, by how much, or for which files — use the CLI.
