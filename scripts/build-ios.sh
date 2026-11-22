#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-debug}"
API_BASE_URL="${2:-}"
OFFLINE_ONLY="${3:-false}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS builds require macOS and Xcode." >&2
  exit 2
fi
if [[ "$MODE" != "debug" && "$MODE" != "release" ]]; then
  echo "Usage: $0 [debug|release] [https-api-url] [true-for-offline-preview]" >&2
  exit 2
fi
if [[ -n "$API_BASE_URL" && "$API_BASE_URL" != https://* ]]; then
  echo "Release API URL must use HTTPS." >&2
  exit 2
fi
if [[ -n "$API_BASE_URL" && "$OFFLINE_ONLY" == "true" ]]; then
  echo "Choose an HTTPS API or offline preview, not both." >&2
  exit 2
fi
if [[ "$MODE" == "release" && -z "$API_BASE_URL" && "$OFFLINE_ONLY" != "true" ]]; then
  echo "Release builds require an HTTPS API URL or offline preview=true." >&2
  exit 2
fi

export PUB_CACHE="${PUB_CACHE:-$ROOT/.local/cache/pub}"
export TMPDIR="${TMPDIR:-$ROOT/.local/tmp}"
mkdir -p "$PUB_CACHE" "$TMPDIR"

cd "$ROOT/apps/quiz"
flutter pub get

args=(build ios "--$MODE" --no-codesign)
if [[ "$MODE" != "release" ]]; then
  args+=(--no-pub)
fi
if [[ "$MODE" == "debug" ]]; then
  args+=(--simulator)
fi
if [[ -n "$API_BASE_URL" ]]; then
  args+=("--dart-define=API_BASE_URL=$API_BASE_URL")
fi
if [[ "$OFFLINE_ONLY" == "true" ]]; then
  args+=("--dart-define=OFFLINE_ONLY=true")
fi
flutter "${args[@]}"
