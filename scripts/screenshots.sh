#!/opt/homebrew/bin/bash
# brew install bash  ← bash 4+ 필요 (연관 배열 지원)
set -e

PROJ_DIR="/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation"
PROJ="$PROJ_DIR/whiskey-note.xcodeproj"
SCHEME="whiskey-note"
DEST="platform=iOS Simulator,name=iPhone 16 Pro Max"
OUTPUT_BASE="$PROJ_DIR/screenshots"

declare -A REGIONS=([ko]="ko_KR" [en]="en_US")

for LANG in ko en; do
    echo ""
    echo "=== Taking screenshots: $LANG ==="
    mkdir -p "$OUTPUT_BASE/$LANG"

    xcodebuild test \
        -project "$PROJ" \
        -scheme "$SCHEME" \
        -destination "$DEST" \
        -only-testing:"whiskey noteUITests/ScreenshotTests/testTakeScreenshots" \
        -testLanguage "$LANG" \
        -testRegion "${REGIONS[$LANG]}" \
        -testEnvironmentVariable SCREENSHOT_OUTPUT_DIR="$OUTPUT_BASE/$LANG" \
        2>&1 | grep -E "Test Case|snapshot|error:|TEST SUCCEEDED|TEST FAILED"
done

echo ""
echo "=== 완료 ==="
echo "스크린샷 위치: $OUTPUT_BASE"
ls "$OUTPUT_BASE/ko/" "$OUTPUT_BASE/en/" 2>/dev/null
