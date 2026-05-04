# Changelog

All notable changes to the `zipic` skill are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/).
Versioning follows [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

## [1.1.0] — 2026-04-22

### Added
- SVG optimization support (requires Zipic 1.9.0+, Pro feature)
  - New `### SVG Optimization` workflow section with usage examples and level-specific guidance
  - SVG compression-level guide (1–2 conservative / 3–4 balanced / 5–6 aggressive)
- SVG + APNG entry in the Pro Features list
- SVG recommendation entry in the Format Recommendations section
- Trigger keywords in frontmatter `description`: `optimize SVG`, `minify SVG`

### Changed
- Bumped minimum Zipic version from "current stable" to `>= 1.9.0` (required for SVG support)
- Clarified `format=` parameter documentation: explicitly noted that `svg` is NOT a valid output value (raster → vector is impossible); SVG inputs are optimized in-place and stay as SVG

## [1.0.0] — 2026-04-22

First tagged release.

### Added
- Skill metadata in YAML frontmatter: `version`, `author`, `license`, `homepage`, `platform`, `requires`
- Standalone `CHANGELOG.md` (this file) to track version history
- Standalone `LICENSE` file (MIT)

### Skill capabilities (baseline)
- Zipic URL Scheme invocation via the `open` command
- Parameter reference: `url`, `level` (1–6), `format`, `width`, `height`, `location`, `specified`
- Pre-flight checks: OS detection + Zipic installation detection
- Workflows: basic compression, format conversion, resize + compress, batch processing
- Path handling with URL encoding for spaces and non-ASCII characters
- Pro feature awareness (free tier cap at 25/day)
- Error handling for missing Zipic app and non-existent paths
