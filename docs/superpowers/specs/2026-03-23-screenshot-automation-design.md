# Screenshot Automation Design

## Goal

fastlane의 SnapshotHelper.swift만 사용해 App Store용 스크린샷 14장(한국어 7 + 영어 7)을 자동 생성한다. gem 설치 없이 Xcode UI Test 안에서 동작한다.

## Architecture

```
앱 실행 (-SCREENSHOT_MODE 런치 인자)
  → whiskey_noteApp.swift: 언어별 데모 데이터 주입
  → UI Test: 화면 이동 + 필드 입력 + snapshot() 호출
  → screenshots/{ko,en}/*.png 저장
```

## 파일 구조

| 파일 | 역할 |
|------|------|
| `whiskey noteUITests/SnapshotHelper.swift` | fastlane 제공 스냅샷 헬퍼 (복사) |
| `whiskey noteUITests/ScreenshotTests.swift` | 화면 탐색 + snapshot() 호출 |
| `whiskey note/Screenshot/ScreenshotSeedData.swift` | 언어별 데모 데이터 정의 |
| `whiskey note/whiskey_noteApp.swift` | -SCREENSHOT_MODE 감지 → 데이터 주입 |
| `scripts/screenshots.sh` | ko/en 순서로 xcodebuild test 실행 |

## 촬영 화면 (7장 × 2언어 = 14장)

| 파일명 | 화면 | 설명 |
|--------|------|------|
| `01_홈.png` | HomeView | 데모 노트 5개, 프로필 카드 통계 표시 |
| `02_노트_상세.png` | NoteDetailView | 향·맛·질감·마무리 데이터 가득 찬 노트 |
| `03_통계.png` | StatsView | 선호 향 TOP5 + 카테고리 분포 + 별점 분포 |
| `04_위스키_추가_1.png` | WizardStep1 | 이름·도수·연수 입력 중 상태 |
| `05_위스키_추가_2.png` | WizardStep2 | 아로마 슬라이더 여러 개 조작된 상태 |
| `06_위스키_추가_3.png` | WizardStep3 | 맛·질감·마무리 슬라이더 조작된 상태 |
| `07_위스키_추가_4.png` | WizardStep4 | 별점 4개 + 메모 작성 중 상태 |

## 데모 데이터

### 공통 (5개 노트, 언어 무관)

| 이름 | 종류 | 도수 | 연수 | 별점 |
|------|------|------|------|------|
| Laphroaig 10yr | Single Malt | 43% | 10 | 5.0 |
| Glenfiddich 18yr | Single Malt | 40% | 18 | 4.0 |
| Yamazaki 12yr | Japanese | 43% | 12 | 5.0 |
| Maker's Mark | Bourbon | 45% | — | 3.0 |
| Jameson | Irish | 40% | — | 4.0 |

각 노트에 aroma·taste·mouthfeel·finish FlavorIntensity 포함 (통계 차트 의미있게 표시되도록).

### 언어별 텍스트 (memo / dish)

**한국어**

| 이름 | memo | dish |
|------|------|------|
| Laphroaig 10yr | "강렬한 피트 향 뒤로 달콤한 바닐라가 느껴진다" | "다크 초콜릿, 훈제 치즈" |
| Glenfiddich 18yr | "건과일과 오크 향이 조화롭고 여운이 길다" | "호두 타르트, 블루치즈" |
| Yamazaki 12yr | "섬세한 꽃 향과 과일 향이 인상적인 균형미" | "화과자, 녹차 초콜릿" |
| Maker's Mark | "바닐라와 캐러멜 향이 진하고 부드럽다" | "바비큐, 버번 피칸" |
| Jameson | "가볍고 달콤하며 입문용으로 완벽하다" | "아이리시 스튜, 체다 치즈" |

**영어**

| 이름 | memo | dish |
|------|------|------|
| Laphroaig 10yr | "Bold peat smoke with a surprisingly sweet vanilla finish" | "Dark chocolate, smoked cheese" |
| Glenfiddich 18yr | "Dried fruit and oak in perfect harmony, long finish" | "Walnut tart, blue cheese" |
| Yamazaki 12yr | "Delicate floral and fruit notes, beautifully balanced" | "Wagashi, matcha chocolate" |
| Maker's Mark | "Rich vanilla and caramel, smooth and approachable" | "BBQ ribs, bourbon pecans" |
| Jameson | "Light, sweet, and perfectly easy-drinking" | "Irish stew, cheddar cheese" |

### 위자드 입력 데이터 (UI Test에서 타이핑)

**한국어**

- Step 1: 이름 `"Ardbeg 10yr"`, 도수 `"46.0"`, 연수 `"10"`, 가격 `"95000"`
- Step 4: 메모 `"바닷바람과 피트가 압도적이지만 뒷맛이 놀랍도록 달콤하다"`

**영어**

- Step 1: 이름 `"Ardbeg 10yr"`, 도수 `"46.0"`, 연수 `"10"`, 가격 `"95000"`
- Step 4: memo `"Overwhelming sea breeze and peat, yet the finish is surprisingly sweet"`

## 데이터 주입 방식

`whiskey_noteApp.swift`에서 `ProcessInfo.processInfo.arguments`에 `"-SCREENSHOT_MODE"` 포함 여부 확인. 포함 시 `ScreenshotSeedData.seed(into:)` 호출해 ModelContext에 삽입. 언어는 `Locale.current` 감지.

```swift
// whiskey_noteApp.swift (변경 부분)
if ProcessInfo.processInfo.arguments.contains("-SCREENSHOT_MODE") {
    ScreenshotSeedData.seed(into: container.mainContext)
}
```

프로덕션 빌드에서는 이 분기에 진입하지 않음.

## UI Test 흐름

```
setUp: app.launchArguments = ["-SCREENSHOT_MODE"]
       app.launch()

1. snapshot("01_홈")
2. 첫 번째 노트 셀 탭 → snapshot("02_노트_상세")
3. back → 통계 탭 탭 → snapshot("03_통계")
4. 홈 탭 → FAB(+) 탭 → WizardStep1
   - 이름 필드 타이핑 → 도수·연수·가격 타이핑
   - snapshot("04_위스키_추가_1")
5. 다음 → WizardStep2
   - 아로마 슬라이더 4개 조작
   - snapshot("05_위스키_추가_2")
6. 다음 → WizardStep3
   - 맛·질감·마무리 슬라이더 조작
   - snapshot("06_위스키_추가_3")
7. 다음 → WizardStep4
   - 별점 4개 탭 + 메모 타이핑
   - snapshot("07_위스키_추가_4")
```

## 실행 스크립트

```bash
# scripts/screenshots.sh
PROJ="whiskey-note.xcodeproj"
SCHEME="whiskey-note"
DEST="platform=iOS Simulator,name=iPhone 16 Pro Max"

for LANG in ko en; do
  mkdir -p "screenshots/$LANG"
  xcodebuild test \
    -project "$PROJ" \
    -scheme "$SCHEME" \
    -destination "$DEST" \
    -only-testing:"whiskey noteUITests/ScreenshotTests" \
    -testLanguage "$LANG" \
    -testRegion "${LANG}_${LANG^^}" \
    SCREENSHOT_OUTPUT_DIR="$(pwd)/screenshots/$LANG"
done
```

실행: `bash scripts/screenshots.sh`
결과: `screenshots/ko/01_홈.png` … `screenshots/en/07_위스키_추가_4.png`

## 제약 사항

- SnapshotHelper.swift는 fastlane GitHub에서 수동으로 복사 (한 번만)
- 슬라이더 조작은 `XCUIElement.adjust(toNormalizedSliderPosition:)`으로 처리
- 시뮬레이터 iPhone 16 Pro Max (6.9") 필요
