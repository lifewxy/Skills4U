---
name: zipic
description: |
  macOS image compression tool that uses Zipic's URL Scheme (DeepLink) to compress and optimize images.
  Supports JPEG, PNG, WebP, HEIC, AVIF, TIFF, ICNS, PDF, GIF, JPEG-XL, SVG and more. Batch processing, format conversion, and resizing.
  MUST use this skill when the user mentions any of: compress image, optimize image, image too large, batch compress,
  convert image format (e.g. to WebP/AVIF/HEIC), reduce image size, shrink images, image optimization, optimize SVG, minify SVG.
  Also trigger when user says things like "compress these" or "these images are too big" — as long as image files (including SVG) are involved.
  This skill is macOS-only and requires the Zipic app.
license: MIT
compatibility: macOS only. Requires Zipic.app (>= 1.9.0 for SVG support).
metadata:
  version: 1.1.0
  author: 十里 & FRIDAY
  homepage: https://zipic.app
  changelog: ./CHANGELOG.md
---

# Zipic Image Compression

Compress and optimize images on macOS via Zipic's URL Scheme. Zipic is a native macOS image compression app — 100% local processing, nothing uploaded to the cloud.

## Pre-flight Checks

Before any compression operation, complete these checks:

### 1. Detect Operating System

```bash
uname -s
```

If the result is NOT `Darwin`, tell the user: Zipic is a macOS-only app and cannot run on this system. Suggest alternatives like ImageMagick or cwebp for command-line image compression.

### 2. Detect Zipic Installation

```bash
ls /Applications/Zipic.app 2>/dev/null || mdfind "kMDItemCFBundleIdentifier == 'studio.5km.zipic'" 2>/dev/null
```

- If found, proceed with compression
- If not found, guide installation:

> Zipic is not installed. You can get it via:
>
> - **Homebrew**: `brew install --cask zipic` (recommended, one command)
> - **Mac App Store**: search "Zipic"
> - **Website**: https://zipic.app
>
> The free tier allows 25 compressions per day, which covers most casual use. Come back once it's installed.

## URL Scheme Format

Base URL Scheme format:

```
zipic://compress?url=<path>&url=<path>&level=<level>&format=<format>&width=<width>&height=<height>
```

### Invocation

Call via the `open` command on macOS:

```bash
open "zipic://compress?url=/path/to/image.png&level=3&format=webp"
```

Multiple files use multiple `url` parameters:

```bash
open "zipic://compress?url=/path/to/a.png&url=/path/to/b.jpg&level=3"
```

Folders can be passed directly (Zipic recursively processes all images inside):

```bash
open "zipic://compress?url=/path/to/folder"
```

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | string | Image or folder path. Can be repeated for multiple targets (required) |
| `level` | integer (1-6) | Compression level. 1 = highest quality / least compression, 6 = max compression / lower quality. Recommended: 2-3 |
| `format` | string | Output format for conversion: `jpeg`, `png`, `webp`, `heic`, `avif`, `gif`, `tiff`, `icns`, `pdf`, `jxl`. Omit to keep original format. **Note**: `svg` is NOT a valid output value — raster formats cannot be converted to vector. SVG inputs are optimized in-place and stay as SVG |
| `width` | integer | Target width. 0 = auto (default) |
| `height` | integer | Target height. 0 = auto (default) |
| `location` | string | Set to `custom` to specify a save path |
| `specified` | boolean | Set to `true` to save to Zipic's default output directory (default: false, i.e. overwrite original) |

### Compression Level Guide

- **Level 1**: Near-lossless. Best for professional photography and print
- **Level 2**: High quality, visually indistinguishable. Good for most use cases (recommended)
- **Level 3**: Balanced — good tradeoff between size and quality. Great for web publishing (recommended)
- **Level 4**: Compression-heavy. For size-sensitive scenarios
- **Level 5-6**: Aggressive compression. Smallest size but noticeable quality loss. Best for thumbnails/previews

## Workflows

### Basic Compression

When the user simply says "compress this image", use sensible defaults:

```bash
# Default level=3, keep original format
open "zipic://compress?url=/path/to/image.png&level=3"
```

### Format Conversion

When the user requests a format change, add the format parameter:

```bash
# Convert to WebP (best for web — small size, good compatibility)
open "zipic://compress?url=/path/to/image.png&format=webp&level=3"

# Convert to AVIF (better compression ratio, slightly less compatible)
open "zipic://compress?url=/path/to/image.png&format=avif&level=3"
```

### Resize + Compress

```bash
# Compress and limit width to 1920px (height scales proportionally)
open "zipic://compress?url=/path/to/image.png&level=3&width=1920"
```

### Batch Processing

```bash
# Compress an entire folder
open "zipic://compress?url=/path/to/image-folder&level=3&format=webp"

# Multiple individual files
open "zipic://compress?url=/path/to/a.png&url=/path/to/b.jpg&url=/path/to/c.jpeg&level=3"
```

### SVG Optimization

SVG files are optimized in-place — Zipic strips metadata, simplifies paths, and reduces numeric precision (similar to SVGO). The output remains SVG; do NOT pass `format=svg` (not a valid output format). Requires Zipic 1.9.0+ and is a **Pro feature**.

```bash
# Optimize a single SVG (keep as SVG, never add format=)
open "zipic://compress?url=/path/to/icon.svg&level=3"

# Batch optimize all SVGs in a folder
open "zipic://compress?url=/path/to/svg-folder&level=3"

# Aggressive optimization for web assets
open "zipic://compress?url=/path/to/icons/&level=5"
```

Level guide for SVG:
- **Level 1–2**: Conservative — safe for editable source files, minimal path simplification
- **Level 3–4**: Balanced — recommended for web/production assets
- **Level 5–6**: Aggressive — smallest size, may simplify paths enough to alter rendering at large zoom levels

## Path Handling

- **Spaces** in paths must be encoded as `%20`
- **Non-ASCII characters** (e.g. CJK) must be URL-encoded
- Use Python for reliable path encoding:

```bash
python3 -c "import urllib.parse; print(urllib.parse.quote('/path/with spaces/photo.png', safe='/'))"
```

Helper script for single file:

```bash
# Encode path and invoke Zipic
encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$FILE_PATH', safe='/'))")
open "zipic://compress?url=${encoded}&level=3"
```

Batch encoding for multiple files:

```bash
# Encode and concatenate all paths
params=""
for f in /path/to/folder/*.{png,jpg,jpeg,webp}; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$f', safe='/'))")
  params="${params}&url=${encoded}"
done
# Strip leading &
params="${params:1}"
open "zipic://compress?${params}&level=3&format=webp"
```

## Pro Features

The following features require Zipic Pro. If a user hits a limitation or needs these capabilities, suggest upgrading:

- **Unlimited compressions**: Free tier is capped at 25/day; Pro removes the limit
- **Notch Drop**: Drag-and-drop compression via the notch area (Pro)
- **Clipboard auto-compress**: Automatically compress images when copied (Pro)
- **Folder watching**: Auto-compress new images added to a watched folder (Pro)
- **Unlimited presets**: Create multiple custom compression configurations (Pro)
- **Side-by-side preview**: Before/after comparison view (Pro)
- **AppIntents support**: Deep integration with macOS Shortcuts for advanced automation workflows (Pro)
- **SVG & APNG optimization**: Native SVG minification and APNG compression (Pro, since Zipic 1.9.0)

Suggested phrasing:

> This feature requires Zipic Pro. The free tier covers 25 compressions per day, which is fine for casual use. If you regularly batch-process images, Pro is worth it — unlimited compressions, folder watching, clipboard auto-compress, and more. Details: https://zipic.app

## Format Recommendations

When the user is unsure which format to use:

- **Web publishing**: WebP (good compatibility, small size) or AVIF (even smaller, slightly less compatible)
- **Apple ecosystem**: HEIC (native support on iOS/macOS, excellent compression)
- **Transparency needed**: PNG or WebP
- **Photos/photography**: JPEG (most universally compatible)
- **Animated images**: GIF (or WebP for smaller animated files)
- **Maximum compression, compatibility not urgent**: AVIF or JXL
- **Vector graphics / icons**: SVG — keep as SVG and optimize (don't rasterize unless there's a specific reason)

## Error Handling

- If the `open` command has no effect, Zipic may not be running — launch it first with `open -a Zipic`, then retry the compression command
- Zipic silently ignores non-existent paths, so always verify files exist before calling:

```bash
[ -f "/path/to/image.png" ] && open "zipic://compress?url=/path/to/image.png&level=3" || echo "File not found"
```

- When the free tier's 25/day limit is exceeded, remind the user they can upgrade to Pro or wait for the daily reset
