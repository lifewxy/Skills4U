#!/bin/bash
# detect.sh — Probe the host for Zipic readiness and emit a route recommendation.
#
# Output is line-oriented `key=value` so the caller (an AI agent) can parse it
# without a JSON tool. The most important field is `route`, which collapses the
# detection logic into a single decision the agent can act on directly.
#
# Fields:
#   os            uname -s (Darwin/Linux/...). Anything other than Darwin → halt.
#   app_path      Resolved Zipic.app bundle path, or empty.
#   app_version   CFBundleShortVersionString, or empty.
#   cli           Absolute path to the `zipic` binary, or empty.
#   running       1 if the GUI process is up, 0 otherwise. Informational only —
#                 the CLI auto-launches the app, so a missing process is not a
#                 blocker for the CLI route.
#   cli_supported 1 if app_version >= 1.9.5 AND cli is non-empty.
#   route         One of:
#                   cli            → preferred path; use `zipic compress --json ...`
#                   install_cli    → app supports CLI but binary not installed;
#                                    use URL Scheme this round, ask user to run
#                                    Zipic menu bar → "Install zipic CLI".
#                   url_scheme     → app version too old for CLI; use URL Scheme
#                                    and suggest upgrading Zipic.
#                   halt_no_app    → Zipic.app not found; suggest install.
#                   halt_not_macos → not on macOS.
#
# Exit code is always 0 — the caller branches on `route`, not on $?.

set -u

emit() { printf '%s=%s\n' "$1" "$2"; }

# Compare two dotted version strings. Echoes 1 if $1 >= $2, else 0.
# Pure awk so we don't depend on `sort -V` (BSD sort on older macOS
# releases doesn't support it).
ver_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    n = split(a, A, ".")
    m = split(b, B, ".")
    k = (n > m ? n : m)
    for (i = 1; i <= k; i++) {
      x = (i <= n ? A[i] + 0 : 0)
      y = (i <= m ? B[i] + 0 : 0)
      if (x > y) { print 1; exit }
      if (x < y) { print 0; exit }
    }
    print 1
  }'
}

OS=$(uname -s)
emit os "$OS"

if [ "$OS" != "Darwin" ]; then
  emit app_path ""
  emit app_version ""
  emit cli ""
  emit running 0
  emit cli_supported 0
  emit route halt_not_macos
  exit 0
fi

# Resolve Zipic.app bundle. Prefer Spotlight (works for Setapp, custom
# install locations, DerivedData builds) and fall back to /Applications.
APP=$(mdfind "kMDItemCFBundleIdentifier == 'studio.5km.zipic'" 2>/dev/null | head -1)
if [ -z "$APP" ] && [ -d /Applications/Zipic.app ]; then
  APP=/Applications/Zipic.app
fi
emit app_path "${APP:-}"

if [ -z "$APP" ]; then
  emit app_version ""
  emit cli ""
  emit running 0
  emit cli_supported 0
  emit route halt_no_app
  exit 0
fi

APP_VERSION=$(defaults read "$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "")
emit app_version "$APP_VERSION"

CLI=$(command -v zipic 2>/dev/null || true)
emit cli "${CLI:-}"

if pgrep -x Zipic >/dev/null 2>&1; then
  emit running 1
else
  emit running 0
fi

# Decide route. CLI requires both >= 1.9.5 AND the binary on PATH.
CLI_OK=0
if [ -n "$APP_VERSION" ] && [ "$(ver_ge "$APP_VERSION" 1.9.5)" = "1" ] && [ -n "$CLI" ]; then
  CLI_OK=1
fi
emit cli_supported "$CLI_OK"

if [ "$CLI_OK" = "1" ]; then
  emit route cli
elif [ -n "$APP_VERSION" ] && [ "$(ver_ge "$APP_VERSION" 1.9.5)" = "1" ]; then
  emit route install_cli
else
  emit route url_scheme
fi
