# Screenshot Automation Design

## Goal

fastlane의 SnapshotHelper.swift만 사용해 App Store용 스크린샷 14장(한국어 7 + 영어 7)을 자동 생성한다. gem 설치 없이 Xcode UI Test 안에서 동작한다.

## Architecture

```
앱 실행 (-SCREENSHOT_MODE 런치 인자)
  → whiskey_noteApp.swift: ModelContainer 수동 생성 → onAppear에서 언어별 데모 데이터 주입
  → UI Test: setupSnapshot(app) → 화면 이동 + 필드 입력 + snapshot() 호출
  → screenshots/{ko,en}/*.png 저장
```

## 파일 구조

| 파일 | 역할 |
|------|------|
| `whiskey noteUITests/SnapshotHelper.swift` | fastlane 제공 스냅샷 헬퍼 (복사) |
| `whiskey noteUITests/ScreenshotTests.swift` | 화면 탐색 + snapshot() 호출 |
| `whiskey note/Screenshot/ScreenshotSeedData.swift` | 언어별 데모 데이터 정의 |
| `whiskey note/whiskey_noteApp.swift` | ModelContainer 수동 생성, -SCREENSHOT_MODE 감지 → 데이터 주입 |
| `whiskey note/Views/Wizard/WizardStep4View.swift` | TextEditor에 accessibilityIdentifier 추가 |
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

> **참고:** UI 레이블(탭바 등)은 현재 한국어 전용이므로 영어 스크린샷에서도 한국어로 표시된다. App Store 영어 스크린샷 목적상 허용 범위로 간주한다.

## 데모 데이터

### 5개 노트 — FlavorIntensity 포함 (구체적 강도 값)

통계 차트가 의미있게 렌더링되려면 aroma intensity > 0 값이 5개 이상의 서로 다른 향 이름에 존재해야 한다.

| 이름 | 종류 | 도수 | 연수 | 별점 | 주요 아로마 (intensity) |
|------|------|------|------|------|------------------------|
| Laphroaig 10yr | Single Malt | 43% | 10 | 5.0 | 피트=5, 과일=2, 우디=3 |
| Glenfiddich 18yr | Single Malt | 40% | 18 | 4.0 | 과일=4, 꽃=3, 견과류=2 |
| Yamazaki 12yr | Japanese | 43% | 12 | 5.0 | 꽃=5, 과일=3, 와인=2 |
| Maker's Mark | Bourbon | 45% | — | 3.0 | 곡물=4, 견과류=3, 스파이시=2 |
| Jameson | Irish | 40% | — | 4.0 | 과일=3, 꽃=2, 곡물=2 |

taste·mouthfeel·finish도 각 노트에 2–3개씩 non-zero intensity로 설정.

### 언어별 텍스트 (memo / dish)

앱 실행 시 `Locale.current.language.languageCode?.identifier`로 언어 감지.

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

Step 1: 이름 `"Ardbeg 10yr"`, 도수 `"46.0"`, 연수 `"10"`, 가격 `"95000"`

Step 4 (언어별):
- 한국어: `"바닷바람과 피트가 압도적이지만 뒷맛이 놀랍도록 달콤하다"`
- 영어: `"Overwhelming sea breeze and peat, yet the finish is surprisingly sweet"`

## 데이터 주입 방식

`.modelContainer(for:)` convenience API는 내부적으로 컨테이너를 숨기므로 `mainContext`에 직접 접근 불가. 대신 `ModelContainer`를 수동 생성해 앱 프로퍼티로 보유한다.

```swift
// whiskey_noteApp.swift
@main
struct whiskey_noteApp: App {
    let container: ModelContainer = {
        let schema = Schema([WhiskeyNote.self, FlavorIntensity.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if ProcessInfo.processInfo.arguments.contains("-SCREENSHOT_MODE") {
                        ScreenshotSeedData.seed(into: container.mainContext)
                    }
                }
        }
        .modelContainer(container)
    }
}
```

프로덕션에서는 `-SCREENSHOT_MODE` 인자 없이 실행되므로 영향 없음.

## UI Test 흐름

```swift
override func setUp() {
    super.setUp()
    continueAfterFailure = false
    let app = XCUIApplication()
    setupSnapshot(app)                        // SnapshotHelper 필수 호출
    app.launchArguments = ["-SCREENSHOT_MODE"]
    app.launch()
}
```

```
1. snapshot("01_홈")
2. 첫 번째 노트 셀 탭 → NoteDetailView
   snapshot("02_노트_상세")
3. back → 통계 탭 탭 (app.tabBars.buttons["통계"])
   snapshot("03_통계")
4. 홈 탭 탭 → FAB(+) 탭 → WizardStep1
   - app.textFields["위스키 이름 *"].tap() + typeText("Ardbeg 10yr")
   - 도수·연수·가격 필드 타이핑
   - snapshot("04_위스키_추가_1")
5. 다음 → WizardStep2
   - app.sliders로 아로마 슬라이더 4개 조작
     (adjust(toNormalizedSliderPosition:) 사용)
   - snapshot("05_위스키_추가_2")
6. 다음 → WizardStep3
   - 맛·질감·마무리 슬라이더 조작
   - snapshot("06_위스키_추가_3")
7. 다음 → WizardStep4
   - StarRatingView 별 4번째 탭
   - app.textViews["memoEditor"].tap() + typeText(...)
     (메모는 TextEditor → textViews로 접근, accessibilityIdentifier "memoEditor" 필요)
   - snapshot("07_위스키_추가_4")
```

**WizardStep4View 수정:** `TextEditor`에 `.accessibilityIdentifier("memoEditor")` 추가 필요.

## 실행 스크립트

```bash
#!/bin/bash
set -e

PROJ="whiskey-note.xcodeproj"
SCHEME="whiskey-note"
DEST="platform=iOS Simulator,name=iPhone 16 Pro Max"

declare -A REGIONS=([ko]="ko_KR" [en]="en_US")   # bash 4+ 필요 → brew install bash

for LANG in ko en; do
    mkdir -p "screenshots/$LANG"
    xcodebuild test \
        -project "$PROJ" \
        -scheme "$SCHEME" \
        -destination "$DEST" \
        -only-testing:"whiskey noteUITests/ScreenshotTests" \
        -testLanguage "$LANG" \
        -testRegion "${REGIONS[$LANG]}" \
        -testEnvironmentVariables \
          SCREENSHOT_OUTPUT_DIR="$(pwd)/screenshots/$LANG"
done
```

> macOS 기본 bash(3.2)는 연관 배열 미지원. `brew install bash` 후 `/opt/homebrew/bin/bash scripts/screenshots.sh`로 실행.

실행 결과:
```
screenshots/ko/01_홈.png … 07_위스키_추가_4.png
screenshots/en/01_홈.png … 07_위스키_추가_4.png
```
