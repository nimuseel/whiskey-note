# Screenshot Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** SnapshotHelper.swift를 사용해 한국어·영어 App Store 스크린샷 14장을 `bash scripts/screenshots.sh` 한 명령으로 자동 생성한다.

**Architecture:** UITest target에 SnapshotHelper.swift를 복사하고, `-SCREENSHOT_MODE` 런치 인자로 데모 데이터를 주입한다. ScreenshotTests가 앱을 탐색하며 각 화면에서 `snapshot()` 을 호출한다. 쉘 스크립트가 한국어·영어 두 번 실행해 `screenshots/{ko,en}/` 에 저장한다.

**Tech Stack:** Swift, XCTest, SnapshotHelper.swift (fastlane), xcodebuild, bash 4+

**Worktree:** `.worktrees/feature/screenshot-automation`
**Base path:** `/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation`

---

## 파일 구조

| 파일 | 작업 |
|------|------|
| `whiskey noteUITests/SnapshotHelper.swift` | **신규** — fastlane 저장소에서 복사 |
| `whiskey noteUITests/ScreenshotTests.swift` | **신규** — 화면 탐색 + snapshot() 호출 |
| `whiskey note/Screenshot/ScreenshotSeedData.swift` | **신규** — 언어별 데모 데이터 5개 노트 |

> **참고:** 이 프로젝트는 `PBXFileSystemSynchronizedRootGroup`을 사용하므로 `whiskey note/` 및 `whiskey noteUITests/` 폴더에 파일을 생성하면 자동으로 해당 타겟에 포함된다. `project.pbxproj` 수동 편집 불필요.
| `whiskey note/whiskey_noteApp.swift` | **수정** — ModelContainer 수동 생성, SCREENSHOT_MODE 처리 |
| `whiskey note/Views/Home/HomeView.swift` | **수정** — FAB에 `.accessibilityIdentifier("fab")` |
| `whiskey note/Views/Components/StarRatingView.swift` | **수정** — HStack에 `.accessibilityIdentifier("starRating")` |
| `whiskey note/Views/Wizard/WizardStep4View.swift` | **수정** — TextEditor에 `.accessibilityIdentifier("memoEditor")` |
| `scripts/screenshots.sh` | **신규** — ko/en 순서로 xcodebuild test 실행 |

---

### Task 1: 워크트리 설정

**Files:**
- (git worktree)

- [ ] **Step 1: 워크트리 생성**

```bash
git worktree add /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation -b feature/screenshot-automation
```

Expected: `.worktrees/feature/screenshot-automation/` 생성, `whiskey note/` 등 전체 파일 포함

- [ ] **Step 2: 워크트리 확인**

```bash
git worktree list
```

Expected: `feature/screenshot-automation` 워크트리가 목록에 표시됨

---

### Task 2: SnapshotHelper.swift 복사

**Files:**
- Create: `whiskey noteUITests/SnapshotHelper.swift`

- [ ] **Step 1: SnapshotHelper.swift 다운로드**

```bash
curl -L \
  "https://raw.githubusercontent.com/fastlane/fastlane/master/snapshot/lib/assets/SnapshotHelper.swift" \
  -o "/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/whiskey noteUITests/SnapshotHelper.swift"
```

Expected: 파일 생성, 첫 줄에 `import XCTest` 포함

- [ ] **Step 2: 파일 확인**

```bash
head -5 "/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/whiskey noteUITests/SnapshotHelper.swift"
```

Expected: `import XCTest` 포함된 Swift 코드

- [ ] **Step 3: 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
git add "whiskey noteUITests/SnapshotHelper.swift"
git commit -m "feat(screenshot): add SnapshotHelper.swift from fastlane"
```

---

### Task 3: 접근성 식별자 추가 (3곳)

UI Test에서 요소를 안정적으로 찾기 위해 3개 뷰에 accessibilityIdentifier를 추가한다.

**Files:**
- Modify: `whiskey note/Views/Home/HomeView.swift:60-68`
- Modify: `whiskey note/Views/Components/StarRatingView.swift:9-35`
- Modify: `whiskey note/Views/Wizard/WizardStep4View.swift:33`

- [ ] **Step 1: HomeView.swift — FAB 버튼에 identifier 추가**

```swift
// Before (line 60):
Button { showWizard = true } label: {

// After:
Button { showWizard = true } label: {
```

FAB 버튼 클로저 끝 `.shadow(radius: 4, y: 2)` 다음 줄 뒤, `.padding(20)` 앞에 추가:

```swift
// Before:
                .shadow(radius: 4, y: 2)
            }
            .padding(20)

// After:
                .shadow(radius: 4, y: 2)
            }
            .accessibilityIdentifier("fab")
            .padding(20)
```

- [ ] **Step 2: StarRatingView.swift — HStack에 identifier 추가**

```swift
// Before (line 9):
        HStack(spacing: 4) {

// After:
        HStack(spacing: 4) {
```

`}` 닫는 부분 (line 35) 앞에 modifier 추가:

```swift
// Before:
        }
    }

    private func starImage(for index: Int) -> Image {

// After:
        }
        .accessibilityIdentifier("starRating")
    }

    private func starImage(for index: Int) -> Image {
```

- [ ] **Step 3: WizardStep4View.swift — TextEditor에 identifier 추가**

```swift
// Before (line 33):
                    TextEditor(text: $memo)
                        .frame(minHeight: 120)

// After:
                    TextEditor(text: $memo)
                        .accessibilityIdentifier("memoEditor")
                        .frame(minHeight: 120)
```

- [ ] **Step 4: 빌드 확인**

```bash
xcodebuild build \
  -project "/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/whiskey-note.xcodeproj" \
  -scheme "whiskey-note" \
  -destination "platform=iOS Simulator,id=45814CE3-4945-400E-821C-DA83CA889C3D" \
  2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
git add "whiskey note/Views/Home/HomeView.swift" \
        "whiskey note/Views/Components/StarRatingView.swift" \
        "whiskey note/Views/Wizard/WizardStep4View.swift"
git commit -m "feat(screenshot): add accessibility identifiers for UI test navigation"
```

---

### Task 4: whiskey_noteApp.swift — ModelContainer 수동 생성

`.modelContainer(for:)` convenience API는 내부적으로 컨테이너를 숨겨 `mainContext`에 접근 불가. 수동 생성으로 전환한다.

**Files:**
- Modify: `whiskey note/whiskey_noteApp.swift`

- [ ] **Step 1: whiskey_noteApp.swift 전체 교체**

```swift
import SwiftUI
import SwiftData

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

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild build \
  -project "/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/whiskey-note.xcodeproj" \
  -scheme "whiskey-note" \
  -destination "platform=iOS Simulator,id=45814CE3-4945-400E-821C-DA83CA889C3D" \
  2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
git add "whiskey note/whiskey_noteApp.swift"
git commit -m "refactor: use manual ModelContainer to support screenshot data injection"
```

---

### Task 5: ScreenshotSeedData.swift 생성

**Files:**
- Create: `whiskey note/Screenshot/ScreenshotSeedData.swift`

- [ ] **Step 1: ScreenshotSeedData.swift 생성**

```swift
import SwiftData
import Foundation

enum ScreenshotSeedData {

    private struct NoteSpec {
        let name: String
        let category: String
        let abv: Double
        let age: Int?
        let price: Int
        let rating: Double
        let memoKo: String
        let memoEn: String
        let dishKo: String
        let dishEn: String
        let aromas: [(String, Int)]
        let tastes: [(String, Int)]
        let mouthfeels: [(String, Int)]
        let finishes: [(String, Int)]
        let daysAgo: Int
    }

    private static let specs: [NoteSpec] = [
        NoteSpec(
            name: "Laphroaig 10yr",
            category: WhiskeyCategory.singleMalt.rawValue,
            abv: 43.0, age: 10, price: 85000, rating: 5.0,
            memoKo: "강렬한 피트 향 뒤로 달콤한 바닐라가 느껴진다",
            memoEn: "Bold peat smoke with a surprisingly sweet vanilla finish",
            dishKo: "다크 초콜릿, 훈제 치즈",
            dishEn: "Dark chocolate, smoked cheese",
            aromas: [("피트", 5), ("과일", 2), ("우디", 3)],
            tastes: [("단맛", 3), ("쓴맛", 2)],
            mouthfeels: [("무거움", 4), ("오일", 3)],
            finishes: [("긴", 5), ("따뜻한", 3)],
            daysAgo: 1
        ),
        NoteSpec(
            name: "Glenfiddich 18yr",
            category: WhiskeyCategory.singleMalt.rawValue,
            abv: 40.0, age: 18, price: 120000, rating: 4.0,
            memoKo: "건과일과 오크 향이 조화롭고 여운이 길다",
            memoEn: "Dried fruit and oak in perfect harmony, long finish",
            dishKo: "호두 타르트, 블루치즈",
            dishEn: "Walnut tart, blue cheese",
            aromas: [("과일", 4), ("꽃", 3), ("견과류", 2)],
            tastes: [("단맛", 4), ("감칠맛", 2)],
            mouthfeels: [("중간", 3), ("부드러움", 4)],
            finishes: [("긴", 4), ("드라이", 2)],
            daysAgo: 5
        ),
        NoteSpec(
            name: "Yamazaki 12yr",
            category: WhiskeyCategory.japanese.rawValue,
            abv: 43.0, age: 12, price: 150000, rating: 5.0,
            memoKo: "섬세한 꽃 향과 과일 향이 인상적인 균형미",
            memoEn: "Delicate floral and fruit notes, beautifully balanced",
            dishKo: "화과자, 녹차 초콜릿",
            dishEn: "Wagashi, matcha chocolate",
            aromas: [("꽃", 5), ("과일", 3), ("와인", 2)],
            tastes: [("단맛", 3), ("신맛", 2)],
            mouthfeels: [("부드러움", 5), ("중간", 2)],
            finishes: [("긴", 3), ("따뜻한", 2)],
            daysAgo: 10
        ),
        NoteSpec(
            name: "Maker's Mark",
            category: WhiskeyCategory.bourbon.rawValue,
            abv: 45.0, age: nil, price: 65000, rating: 3.0,
            memoKo: "바닐라와 캐러멜 향이 진하고 부드럽다",
            memoEn: "Rich vanilla and caramel, smooth and approachable",
            dishKo: "바비큐, 버번 피칸",
            dishEn: "BBQ ribs, bourbon pecans",
            aromas: [("곡물", 4), ("견과류", 3), ("스파이시", 2)],
            tastes: [("단맛", 5), ("감칠맛", 2)],
            mouthfeels: [("중간", 3), ("드라이", 2)],
            finishes: [("중간", 3), ("스파이시", 2)],
            daysAgo: 15
        ),
        NoteSpec(
            name: "Jameson",
            category: WhiskeyCategory.irish.rawValue,
            abv: 40.0, age: nil, price: 45000, rating: 4.0,
            memoKo: "가볍고 달콤하며 입문용으로 완벽하다",
            memoEn: "Light, sweet, and perfectly easy-drinking",
            dishKo: "아이리시 스튜, 체다 치즈",
            dishEn: "Irish stew, cheddar cheese",
            aromas: [("과일", 3), ("꽃", 2), ("곡물", 2)],
            tastes: [("단맛", 3), ("신맛", 1)],
            mouthfeels: [("가벼움", 4), ("부드러움", 3)],
            finishes: [("짧은", 3), ("따뜻한", 2)],
            daysAgo: 20
        )
    ]

    static func seed(into context: ModelContext) {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"
        let now = Date()

        for spec in specs {
            let note = WhiskeyNote(name: spec.name, category: spec.category)
            note.abv = spec.abv
            note.age = spec.age
            note.price = spec.price
            note.rating = spec.rating
            note.memo = isKorean ? spec.memoKo : spec.memoEn
            note.dish = isKorean ? spec.dishKo : spec.dishEn
            note.createdAt = Calendar.current.date(byAdding: .day, value: -spec.daysAgo, to: now) ?? now
            context.insert(note)

            let flavors: [(FlavorType, [(String, Int)])] = [
                (.aroma, spec.aromas),
                (.taste, spec.tastes),
                (.mouthfeel, spec.mouthfeels),
                (.finish, spec.finishes)
            ]
            for (type, items) in flavors {
                for (name, intensity) in items {
                    let fi = FlavorIntensity(flavorType: type, name: name, intensity: intensity)
                    fi.note = note
                    note.flavorIntensities.append(fi)
                    context.insert(fi)
                }
            }
        }
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild build \
  -project "/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/whiskey-note.xcodeproj" \
  -scheme "whiskey-note" \
  -destination "platform=iOS Simulator,id=45814CE3-4945-400E-821C-DA83CA889C3D" \
  2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
git add "whiskey note/Screenshot/ScreenshotSeedData.swift"
git commit -m "feat(screenshot): add ScreenshotSeedData with 5 demo whiskey notes"
```

---

### Task 6: ScreenshotTests.swift 생성

**Files:**
- Create: `whiskey noteUITests/ScreenshotTests.swift`

슬라이더 조작 노트:
- FlavorSliderRow는 range 0...5의 Slider 사용
- `adjust(toNormalizedSliderPosition:)` 값 = intensity / 5.0
  - 예: intensity 3 → 0.6, intensity 5 → 1.0, intensity 2 → 0.4

StarRatingView 조작 노트:
- HStack의 accessibilityIdentifier "starRating" 사용
- 4번째 별(오른쪽 반 = rating 4.0)을 coordinate tap으로 선택
- 5개 별이 균등 배치 → dx=0.85 (5번째 별 왼쪽 반 근방)

HomeView 노트 탭:
- `recentSection`의 NavigationLink는 `.buttonStyle(.plain)` → staticTexts로 접근 가능
- "Laphroaig 10yr" 텍스트를 탭

- [ ] **Step 1: ScreenshotTests.swift 생성**

```swift
import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments = ["-SCREENSHOT_MODE"]
        app.launch()
        // 시드 데이터 반영 대기
        sleep(2)
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    @MainActor
    func testTakeScreenshots() throws {
        // ── 01 홈 ────────────────────────────────────────────────────────────
        snapshot("01_홈")

        // ── 02 노트 상세 ─────────────────────────────────────────────────────
        // HomeView recentSection의 첫 번째 노트 탭
        app.staticTexts["Laphroaig 10yr"].tap()
        sleep(1)
        snapshot("02_노트_상세")

        // ── 03 통계 ──────────────────────────────────────────────────────────
        app.navigationBars.buttons.firstMatch.tap()   // 뒤로
        sleep(0.5)
        app.tabBars.buttons["통계"].tap()
        sleep(1)
        snapshot("03_통계")

        // ── 04 위스키 추가 Step 1 ─────────────────────────────────────────────
        app.tabBars.buttons["홈"].tap()
        sleep(0.5)
        app.buttons["fab"].tap()
        sleep(0.5)

        // 이름 입력
        let nameField = app.textFields["예: Laphroaig 10yr"]
        nameField.tap()
        nameField.typeText("Ardbeg 10yr")

        // 도수 입력
        let abvField = app.textFields["예: 43.0"]
        abvField.tap()
        abvField.typeText("46.0")

        // 연수 입력
        let ageField = app.textFields["예: 10"]
        ageField.tap()
        ageField.typeText("10")

        // 가격 입력
        let priceField = app.textFields["예: 80000"]
        priceField.tap()
        priceField.typeText("95000")

        snapshot("04_위스키_추가_1")

        // ── 05 위스키 추가 Step 2 (아로마) ────────────────────────────────────
        app.buttons["다음"].tap()
        sleep(0.5)

        // 슬라이더 조작 (과일=2, 꽃=3, 견과류=4, 피트=5)
        // Step2 슬라이더 순서: 과일(0), 꽃(1), 곡물(2), 견과류(3), 스파이시(4), 우디(5), 피트(6), 와인(7), 페인티(8)
        let s2 = app.sliders
        if s2.count > 0 { s2.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.4) }  // 과일 2
        if s2.count > 1 { s2.element(boundBy: 1).adjust(toNormalizedSliderPosition: 0.6) }  // 꽃 3
        if s2.count > 3 { s2.element(boundBy: 3).adjust(toNormalizedSliderPosition: 0.8) }  // 견과류 4
        if s2.count > 6 { s2.element(boundBy: 6).adjust(toNormalizedSliderPosition: 1.0) }  // 피트 5

        snapshot("05_위스키_추가_2")

        // ── 06 위스키 추가 Step 3 (맛·질감·마무리) ───────────────────────────
        app.buttons["다음"].tap()
        sleep(0.5)

        // Step3 슬라이더 순서: taste(단맛0, 짠맛1, 신맛2, 쓴맛3, 감칠맛4),
        //                      mouthfeel(가벼움5, 중간6, 무거움7, 부드러움8, 거침9, 오일10, 드라이11),
        //                      finish(짧은12, 중간13, 긴14, 따뜻한15, 스파이시16, 드라이17)
        let s3 = app.sliders
        if s3.count > 0 { s3.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.6) }  // 단맛 3
        if s3.count > 3 { s3.element(boundBy: 3).adjust(toNormalizedSliderPosition: 0.4) }  // 쓴맛 2
        if s3.count > 7 { s3.element(boundBy: 7).adjust(toNormalizedSliderPosition: 0.8) }  // 무거움 4
        if s3.count > 8 { s3.element(boundBy: 8).adjust(toNormalizedSliderPosition: 1.0) }  // 부드러움 5
        if s3.count > 14 { s3.element(boundBy: 14).adjust(toNormalizedSliderPosition: 0.8) } // 긴 4

        snapshot("06_위스키_추가_3")

        // ── 07 위스키 추가 Step 4 (총평) ─────────────────────────────────────
        app.buttons["다음"].tap()
        sleep(0.5)

        // 별점 4개: starRating HStack의 약 80% 지점 탭 (4번째 별 오른쪽 반)
        let starRating = app.otherElements["starRating"]
        if starRating.exists {
            starRating.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5)).tap()
            // dx=0.75 → 4번째 별(index 3)의 오른쪽 반 → rating 4.0
            // 각 별은 HStack 너비의 0.2 차지: star4 오른쪽 반 = 0.70~0.80
        }

        // 메모 입력
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"
        let memoText = isKorean
            ? "바닷바람과 피트가 압도적이지만 뒷맛이 놀랍도록 달콤하다"
            : "Overwhelming sea breeze and peat, yet the finish is surprisingly sweet"

        let memoEditor = app.textViews["memoEditor"]
        memoEditor.tap()
        memoEditor.typeText(memoText)

        // 키보드 내리기 — 화면 상단 네비게이션 바 탭
        app.navigationBars.staticTexts["총평"].tap()
        sleep(0.5)

        snapshot("07_위스키_추가_4")
    }
}
```

- [ ] **Step 2: UITest 빌드 확인**

```bash
xcodebuild build-for-testing \
  -project "/Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/whiskey-note.xcodeproj" \
  -scheme "whiskey-note" \
  -destination "platform=iOS Simulator,id=45814CE3-4945-400E-821C-DA83CA889C3D" \
  2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
git add "whiskey noteUITests/ScreenshotTests.swift"
git commit -m "feat(screenshot): add ScreenshotTests navigating 7 screens"
```

---

### Task 7: 실행 스크립트 생성 및 검증

**Files:**
- Create: `scripts/screenshots.sh`

- [ ] **Step 1: scripts/ 디렉토리 생성 및 스크립트 작성**

```bash
mkdir -p /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/scripts
```

`scripts/screenshots.sh` 생성:

```bash
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
```

- [ ] **Step 2: 실행 권한 부여**

```bash
chmod +x /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/scripts/screenshots.sh
```

- [ ] **Step 3: 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
git add scripts/screenshots.sh
git commit -m "feat(screenshot): add screenshots.sh runner for ko/en"
```

---

### Task 8: 스크린샷 실행 및 검증

- [ ] **Step 1: bash 4 설치 확인**

```bash
/opt/homebrew/bin/bash --version
```

Expected: `GNU bash, version 5.x` 또는 `4.x`
없으면: `brew install bash`

- [ ] **Step 2: iPhone 16 Pro Max 시뮬레이터 확인**

```bash
xcrun simctl list devices available | grep "iPhone 16 Pro Max"
```

Expected: `iPhone 16 Pro Max` 1개 이상 표시

- [ ] **Step 3: 스크린샷 실행 (한국어 먼저)**

먼저 한국어만 실행해 검증:

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
LANG=ko
mkdir -p screenshots/ko
xcodebuild test \
  -project "whiskey-note.xcodeproj" \
  -scheme "whiskey-note" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
  -only-testing:"whiskey noteUITests/ScreenshotTests/testTakeScreenshots" \
  -testLanguage ko \
  -testRegion ko_KR \
  -testEnvironmentVariable SCREENSHOT_OUTPUT_DIR="$(pwd)/screenshots/ko" \
  2>&1 | grep -E "snapshot|error:|TEST SUCCEEDED|TEST FAILED"
```

Expected: `TEST SUCCEEDED`, `snapshot` 로그 7회

- [ ] **Step 4: 결과 확인**

```bash
ls -la /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/screenshots/ko/
```

Expected: `01_홈.png`, `02_노트_상세.png`, ..., `07_위스키_추가_4.png` 7개 파일

- [ ] **Step 5: 이미지 크기 확인**

```bash
for f in /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation/screenshots/ko/*.png; do
  echo "$(basename $f): $(magick identify -format '%wx%h' "$f")"
done
```

Expected: 모두 `1320x2868` (iPhone 16 Pro Max @3x: 440pt × 956pt)

- [ ] **Step 6: 영어 포함 전체 실행**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
/opt/homebrew/bin/bash scripts/screenshots.sh
```

Expected: `ko/` 7장 + `en/` 7장 = 14장 생성

- [ ] **Step 7: 최종 커밋**

```bash
cd /Users/sumin/dev/ios/whiskey-note/.worktrees/feature/screenshot-automation
# screenshots/ 폴더는 .gitignore에 추가
echo "screenshots/" >> .gitignore
git add .gitignore
git commit -m "chore: ignore generated screenshots folder"
```
