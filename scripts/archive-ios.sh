#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_BASE_URL="${1:-}"
OFFLINE_ONLY="${2:-false}"
ARCHIVE_PATH="${3:-$ROOT/.local/release/diia-my-iphone.xcarchive}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "An iOS archive requires macOS and Xcode." >&2
  exit 2
fi
if [[ -e "$ARCHIVE_PATH" ]]; then
  echo "Archive path already exists: $ARCHIVE_PATH" >&2
  exit 2
fi

mkdir -p "$(dirname "$ARCHIVE_PATH")" "$ROOT/.local/tmp/ios-archive"
bash "$ROOT/scripts/build-ios.sh" release "$API_BASE_URL" "$OFFLINE_ONLY"

cd "$ROOT/apps/quiz"
xcodebuild archive \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$ROOT/.local/tmp/ios-archive" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO

test -f "$ARCHIVE_PATH/Info.plist"
test -d "$ARCHIVE_PATH/Products/Applications/Runner.app"
echo "Unsigned iOS archive created: $ARCHIVE_PATH"
