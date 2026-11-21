#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVICE_ID="${1:-}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "The iOS smoke test requires macOS, Xcode and an iPhone simulator or device." >&2
  exit 2
fi

export PUB_CACHE="${PUB_CACHE:-$ROOT/.local/cache/pub}"
export TMPDIR="${TMPDIR:-$ROOT/.local/tmp}"
mkdir -p "$PUB_CACHE" "$TMPDIR"

if [[ -z "$DEVICE_ID" ]]; then
  DEVICE_ID="$(xcrun simctl list devices available -j | python3 -c 'import json,sys; data=json.load(sys.stdin); print(next(d["udid"] for devices in data["devices"].values() for d in devices if d["name"].startswith("iPhone")))')"
fi

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b

cd "$ROOT/apps/quiz"
flutter pub get
flutter test integration_test/ios_smoke_test.dart -d "$DEVICE_ID" --no-pub
