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

# iPhone 17 Pro Max (iOS 26.2) 시뮬레이터 사용
# iOS 26.2 빌드와 호환되는 최신 시뮬레이터
DEST="platform=iOS Simulator,name=iPhone 17 Pro Max"

echo "=== 빌드 (build-for-testing) ==="
xcodebuild build-for-testing \
    -project "$PROJ" \
    -scheme "$SCHEME" \
    -destination "$DEST" \
    -derivedDataPath "$DD" \
    2>&1 | grep -E "BUILD|error:" | tail -5

# xctestrun에 UITargetAppPath 패치 (xcodebuild 자동 설정 누락 대응)
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

mkdir -p "$CACHE_DIR"

for LANG in ko en; do
    echo ""
    echo "=== 스크린샷 촬영: $LANG ==="

    if [ "$LANG" = "ko" ]; then
        REGION="ko_KR"
    else
        REGION="en_US"
    fi

    # 언어 파일 설정 (SnapshotHelper가 앱에 -AppleLanguages 인자 주입하도록)
    FASTLANE_DIR="$HOME/Library/Caches/tools.fastlane"
    mkdir -p "$FASTLANE_DIR"
    echo "$LANG" > "$FASTLANE_DIR/language.txt"
    echo "$REGION" > "$FASTLANE_DIR/locale.txt"

    # 이전 스크린샷 정리
    rm -f "$CACHE_DIR/"*.png

    xcodebuild test-without-building \
        -xctestrun "$PATCHED" \
        -destination "$DEST" \
        -only-testing "whiskey-noteUITests/ScreenshotTests/testTakeScreenshots" \
        -testLanguage "$LANG" \
        -testRegion "$REGION" \
        2>&1 | grep -E "Test Case|snapshot|error:|TEST SUCCEEDED|TEST FAILED"

    # 스크린샷 복사 (기기명 접두사 제거)
    mkdir -p "$OUTPUT_BASE/$LANG"
    for f in "$CACHE_DIR/"*.png; do
        [ -f "$f" ] || continue
        name=$(basename "$f" | sed 's/^[^-]*-//')
        cp "$f" "$OUTPUT_BASE/$LANG/$name"
    done
done

echo ""
echo "=== 완료 ==="
echo "스크린샷 위치: $OUTPUT_BASE"
ls "$OUTPUT_BASE/ko/" "$OUTPUT_BASE/en/" 2>/dev/null
