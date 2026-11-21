#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-debug}"
API_BASE_URL="${2:-}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS builds require macOS and Xcode." >&2
  exit 2
fi
if [[ "$MODE" != "debug" && "$MODE" != "release" ]]; then
  echo "Usage: $0 [debug|release] [https-api-url]" >&2
  exit 2
fi

export PUB_CACHE="${PUB_CACHE:-$ROOT/.local/cache/pub}"
export TMPDIR="${TMPDIR:-$ROOT/.local/tmp}"
mkdir -p "$PUB_CACHE" "$TMPDIR"

cd "$ROOT/apps/quiz"
flutter pub get

args=(build ios "--$MODE" --no-codesign --no-pub)
if [[ "$MODE" == "debug" ]]; then
  args+=(--simulator)
fi
if [[ -n "$API_BASE_URL" ]]; then
  args+=("--dart-define=API_BASE_URL=$API_BASE_URL")
fi
flutter "${args[@]}"
