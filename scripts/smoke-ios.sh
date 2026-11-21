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

diagnose_failure() {
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "iPhone smoke failed; recent Runner simulator log follows." >&2
    xcrun simctl spawn "$DEVICE_ID" log show \
      --last 20m --style compact \
      --predicate 'process == "Runner"' || true
  fi
  exit "$status"
}
trap diagnose_failure EXIT

# Flutter can wait forever when a simulator app never connects to the test
# service. Stream verbose output and give the whole launch/test process a
# bounded 15 minutes so CI returns evidence instead of hanging until job
# timeout.
python3 - "$DEVICE_ID" <<'PY'
import subprocess
import sys

device_id = sys.argv[1]
command = [
    "flutter",
    "test",
    "integration_test/ios_smoke_test.dart",
    "-d",
    device_id,
    "--no-pub",
    "--reporter",
    "expanded",
    "--verbose",
]
try:
    completed = subprocess.run(command, timeout=15 * 60, check=False)
except subprocess.TimeoutExpired:
    print("iPhone smoke timed out after 15 minutes.", file=sys.stderr)
    raise SystemExit(124)
raise SystemExit(completed.returncode)
PY

trap - EXIT
