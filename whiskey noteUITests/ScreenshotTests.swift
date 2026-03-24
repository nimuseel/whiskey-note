import XCTest

final class ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    @MainActor
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
        app.staticTexts["Laphroaig 10yr"].firstMatch.tap()
        sleep(1)
        snapshot("02_노트_상세")

        // ── 03 통계 ──────────────────────────────────────────────────────────
        app.navigationBars.buttons.firstMatch.tap()   // 뒤로
        Thread.sleep(forTimeInterval: 0.5)
        app.tabBars.firstMatch.buttons.element(boundBy: 2).tap()   // 통계 탭 (3번째)
        sleep(1)
        snapshot("03_통계")

        // ── 04 위스키 추가 Step 1 ─────────────────────────────────────────────
        app.tabBars.firstMatch.buttons.element(boundBy: 0).tap()   // 홈 탭 (1번째)
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["fab"].tap()
        Thread.sleep(forTimeInterval: 0.5)

        let nameField = app.textFields["nameField"]
        nameField.tap()
        nameField.typeText("Ardbeg 10yr")

        let abvField = app.textFields["abvField"]
        abvField.tap()
        abvField.typeText("46.0")

        let ageField = app.textFields["ageField"]
        ageField.tap()
        ageField.typeText("10")

        let priceField = app.textFields["priceField"]
        priceField.tap()
        priceField.typeText("95000")

        snapshot("04_위스키_추가_1")

        // ── 05 위스키 추가 Step 2 (아로마) ────────────────────────────────────
        app.buttons["wizardNext"].tap()
        Thread.sleep(forTimeInterval: 0.5)

        let s2 = app.sliders
        if s2.count > 0 { s2.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.4) }  // 과일 2
        if s2.count > 1 { s2.element(boundBy: 1).adjust(toNormalizedSliderPosition: 0.6) }  // 꽃 3
        if s2.count > 3 { s2.element(boundBy: 3).adjust(toNormalizedSliderPosition: 0.8) }  // 견과류 4
        if s2.count > 6 { s2.element(boundBy: 6).adjust(toNormalizedSliderPosition: 1.0) }  // 피트 5

        snapshot("05_위스키_추가_2")

        // ── 06 위스키 추가 Step 3 (맛·질감·마무리) ───────────────────────────
        app.buttons["wizardNext"].tap()
        Thread.sleep(forTimeInterval: 0.5)

        let s3 = app.sliders
        if s3.count > 0  { s3.element(boundBy: 0).adjust(toNormalizedSliderPosition: 0.6) }  // 단맛 3
        if s3.count > 3  { s3.element(boundBy: 3).adjust(toNormalizedSliderPosition: 0.4) }  // 쓴맛 2
        if s3.count > 7  { s3.element(boundBy: 7).adjust(toNormalizedSliderPosition: 0.8) }  // 무거움 4
        if s3.count > 8  { s3.element(boundBy: 8).adjust(toNormalizedSliderPosition: 1.0) }  // 부드러움 5
        if s3.count > 14 { s3.element(boundBy: 14).adjust(toNormalizedSliderPosition: 0.8) } // 긴 4

        snapshot("06_위스키_추가_3")

        // ── 07 위스키 추가 Step 4 (총평) ─────────────────────────────────────
        app.buttons["wizardNext"].tap()
        Thread.sleep(forTimeInterval: 0.5)

        let starRating = app.otherElements["starRating"]
        if starRating.exists {
            starRating.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5)).tap()
        }

        // Snapshot.deviceLanguage는 setupSnapshot이 language.txt를 읽어 설정
        // 비어 있으면(fastlane 미사용 시) Locale.current로 폴백
        let lang = Snapshot.deviceLanguage.isEmpty
            ? (Locale.current.language.languageCode?.identifier ?? "ko")
            : Snapshot.deviceLanguage
        let memoText = (lang == "ko")
            ? "바닷바람과 피트가 압도적이지만 뒷맛이 놀랍도록 달콤하다"
            : "Overwhelming sea breeze and peat, yet the finish is surprisingly sweet"

        let memoEditor = app.textViews["memoEditor"]
        memoEditor.tap()
        memoEditor.typeText(memoText)

        app.navigationBars.firstMatch.tap()
        Thread.sleep(forTimeInterval: 0.5)

        snapshot("07_위스키_추가_4")
    }
}
