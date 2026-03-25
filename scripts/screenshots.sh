#!/bin/bash
# 스크린샷 자동화 스크립트
# 실행: bash scripts/screenshots.sh
set -e

PROJ_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="$PROJ_DIR/whiskey-note.xcodeproj"
SCHEME="whiskey-note"
DD="/tmp/whiskey-note-screenshot-dd"
OUTPUT_BASE="$PROJ_DIR/screenshots"
CACHE_DIR="$HOME/Library/Caches/tools.fastlane/screenshots"
DEST="platform=iOS Simulator,name=iPhone 17 Pro Max"

echo "=== 빌드 (build-for-testing) ==="
xcodebuild build-for-testing \
    -project "$PROJ" \
    -scheme "$SCHEME" \
    -destination "$DEST" \
    -derivedDataPath "$DD" \
    2>&1 | grep -E "BUILD|error:" | tail -5

# xctestrun 패치
XCTESTRUN=$(ls "$DD/Build/Products/"*.xctestrun 2>/dev/null | grep -v patched | head -1)
PATCHED="$DD/Build/Products/whiskey-note-patched.xctestrun"
python3 << PYEOF
import plistlib, shutil
src = '$XCTESTRUN'
dst = '$PATCHED'
shutil.copy2(src, dst)
with open(dst, 'rb') as f:
    data = plistlib.load(f)
for k in data:
    if k.startswith('__'):
        continue
    t = data[k]
    if isinstance(t, dict) and t.get('IsUITestBundle'):
        t['UITargetAppPath'] = '__TESTROOT__/Debug-iphonesimulator/whiskey-note.app'
        print(f'Patched UITargetAppPath for {k}')
with open(dst, 'wb') as f:
    plistlib.dump(data, f, fmt=plistlib.FMT_XML)
PYEOF

# 번들 ID 추출
BUNDLE_ID=$(plutil -convert json -o - \
    "$DD/Build/Products/Debug-iphonesimulator/whiskey-note.app/Info.plist" \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['CFBundleIdentifier'])")
echo "Bundle ID: $BUNDLE_ID"

# 시뮬레이터 UDID 추출 (iPhone 17 Pro Max, Unavailable 제외)
UDID=$(xcrun simctl list devices --json | python3 -c "
import sys, json
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if 'iPhone 17 Pro Max' in d.get('name','') and d.get('state') not in ('Unavailable',):
            print(d['udid']); sys.exit(0)
")
echo "Simulator UDID: $UDID"

# 시뮬레이터 부트
xcrun simctl boot "$UDID" 2>/dev/null || true
sleep 3

mkdir -p "$CACHE_DIR"

for LANG in ko en; do
    echo ""
    echo "=== 시뮬레이터 언어 설정: $LANG ==="

    if [ "$LANG" = "ko" ]; then
        REGION="ko_KR"
        # 한국어를 첫 번째로
        xcrun simctl spawn "$UDID" defaults write NSGlobalDomain AppleLanguages \
            -array "ko-KR" "ko" "en-US" "en"
    else
        REGION="en_US"
        # 영어를 첫 번째로
        xcrun simctl spawn "$UDID" defaults write NSGlobalDomain AppleLanguages \
            -array "en-US" "en" "ko-KR" "ko"
    fi
    xcrun simctl spawn "$UDID" defaults write NSGlobalDomain AppleLocale "$REGION"

    # 앱 언인스톨 → SwiftData 포함 데이터 완전 초기화
    echo "앱 데이터 초기화 (언인스톨)..."
    xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
    sleep 1

    # SnapshotHelper 언어 파일 (스크린샷 저장 경로 지정용)
    FASTLANE_DIR="$HOME/Library/Caches/tools.fastlane"
    mkdir -p "$FASTLANE_DIR"
    echo "$LANG" > "$FASTLANE_DIR/language.txt"
    echo "$REGION" > "$FASTLANE_DIR/locale.txt"

    # 이전 스크린샷 정리
    rm -f "$CACHE_DIR/"*.png

    echo "=== 스크린샷 촬영: $LANG ==="
    xcodebuild test-without-building \
        -xctestrun "$PATCHED" \
        -destination "$DEST" \
        -only-testing "whiskey-noteUITests/ScreenshotTests/testTakeScreenshots" \
        2>&1 | grep -E "Test Case|snapshot|error:|TEST SUCCEEDED|TEST FAILED"

    # 스크린샷 복사 (기기명 접두사 제거)
    mkdir -p "$OUTPUT_BASE/$LANG"
    for f in "$CACHE_DIR/"*.png; do
        [ -f "$f" ] || continue
        name=$(basename "$f" | sed 's/^[^-]*-//')
        cp "$f" "$OUTPUT_BASE/$LANG/$name"
    done
    echo "$LANG 완료: $(ls "$OUTPUT_BASE/$LANG/" | wc -l)장"
done

echo ""
echo "=== 완료 ==="
echo "스크린샷 위치: $OUTPUT_BASE"
ls "$OUTPUT_BASE/ko/" "$OUTPUT_BASE/en/" 2>/dev/null
