# Whiskey Note 앱 리뉴얼 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 Whiskey Note 앱을 SwiftUI + SwiftData 기반으로 완전히 재작성하여 슬라이더 기반 강도 입력, 3탭 네비게이션(홈/노트/통계), 4단계 위자드 작성 흐름을 갖춘 앱으로 리뉴얼한다.

**Architecture:** 단일 `WhiskeyNote` 모델과 `FlavorIntensity` cascade 관계. SwiftUI TabView로 3탭 구성. 노트 생성/수정은 단일 `NoteWizardView`가 처리.

**Tech Stack:** SwiftUI, SwiftData, PhotosUI, XCTest (iOS 17.0+, Xcode 15+)

---

## 파일 구조

```
whiskey note/
├── Models/
│   ├── WhiskeyNote.swift          — @Model, 전체 필드
│   └── FlavorIntensity.swift      — @Model, cascade 관계
├── Constants/
│   ├── FlavorConstants.swift      — FlavorItem 배열 27개 + 이모지
│   └── AppColors.swift            — 디자인 컬러 상수
├── Views/
│   ├── ContentView.swift          — TabView 루트 (기존 교체)
│   ├── Home/
│   │   └── HomeView.swift         — 프로필 요약 + 최근 기록 5개
│   ├── NoteList/
│   │   ├── NoteListView.swift     — 검색 + 카드 리스트
│   │   └── NoteCardView.swift     — 카드 한 줄
│   ├── Stats/
│   │   └── StatsView.swift        — 향 TOP5 차트 + 분포
│   ├── Detail/
│   │   └── NoteDetailView.swift   — 상세 읽기 + 수정/삭제
│   ├── Wizard/
│   │   ├── NoteWizardView.swift   — 4단계 오케스트레이터 + 저장 로직
│   │   ├── WizardStep1View.swift  — 사진 & 기본 정보
│   │   ├── WizardStep2View.swift  — 향 슬라이더
│   │   ├── WizardStep3View.swift  — 맛·질감·마무리 슬라이더
│   │   └── WizardStep4View.swift  — 별점·메모·안주
│   └── Components/
│       ├── StarRatingView.swift   — 0.5 단위 별점 입력/표시
│       ├── FlavorSliderRow.swift  — 이모지+이름 + 슬라이더 + 값
│       └── LaunchView.swift       — 스플래시 (기존 유지)
└── whiskey_noteApp.swift          — ModelContainer 설정 (수정)

whiskey noteTests/
└── WhiskeyNoteTests.swift         — 비즈니스 로직 단위 테스트
```

> **Xcode 파일 추가 방법:** 새 Swift 파일은 Xcode에서 File → New → Swift File로 생성하고 "whiskey note" 타겟에 추가해야 빌드에 포함된다. 파일을 탐색기 밖에서 생성한 경우 Xcode Navigator에 드래그해서 추가할 것.

---

## Task 1: 기존 파일 정리 & 디렉토리 구조 생성

**Files:**
- Delete: `whiskey note/TasteNote.swift`
- Delete: `whiskey note/Aroma.swift`
- Delete: `whiskey note/Taste.swift`
- Delete: `whiskey note/Mouthfeel.swift`
- Delete: `whiskey note/Finish.swift`
- Delete: `whiskey note/CreateView.swift`
- Delete: `whiskey note/UpdateView.swift`
- Modify: `whiskey note/ContentView.swift` — 임시 플레이스홀더로 교체
- Modify: `whiskey note/whiskey_noteApp.swift` — 기존 TasteNote ModelContainer 제거

- [ ] **Step 1: Xcode에서 삭제할 파일 7개를 선택하고 "Move to Trash"로 삭제**

  삭제 대상: TasteNote.swift, Aroma.swift, Taste.swift, Mouthfeel.swift, Finish.swift, CreateView.swift, UpdateView.swift

- [ ] **Step 2: ContentView.swift를 빌드 에러 없는 플레이스홀더로 교체**

  ```swift
  import SwiftUI

  struct ContentView: View {
      var body: some View {
          Text("리뉴얼 중...")
      }
  }
  ```

- [ ] **Step 3: whiskey_noteApp.swift에서 기존 ModelContainer 제거**

  ```swift
  import SwiftUI

  @main
  struct whiskey_noteApp: App {
      var body: some Scene {
          WindowGroup {
              ContentView()
          }
      }
  }
  ```

- [ ] **Step 4: Xcode에서 빌드(Cmd+B) — 에러 없이 통과 확인**

- [ ] **Step 5: Xcode Navigator에서 새 그룹 생성**

  "whiskey note" 타겟 아래: Models, Constants, Views/Home, Views/NoteList, Views/Stats, Views/Detail, Views/Wizard, Views/Components 그룹 생성

- [ ] **Step 6: 커밋**

  ```bash
  git add -A
  git commit -m "chore: 기존 파일 삭제 및 디렉토리 구조 준비"
  ```

---

## Task 2: Enums & FlavorConstants

**Files:**
- Create: `whiskey note/Constants/FlavorConstants.swift`
- Test: `whiskey noteTests/WhiskeyNoteTests.swift`

- [ ] **Step 1: 테스트 파일에 FlavorConstants 테스트 작성**

  `whiskey noteTests/WhiskeyNoteTests.swift` 기존 내용을 아래로 교체:

  ```swift
  import Testing
  @testable import whiskey_note

  @Suite("FlavorConstants")
  struct FlavorConstantsTests {
      @Test func totalCount() {
          #expect(FlavorConstants.all.count == 27)
      }

      @Test func aromaCount() {
          let aromas = FlavorConstants.all.filter { $0.type == .aroma }
          #expect(aromas.count == 9)
      }

      @Test func tasteCount() {
          let tastes = FlavorConstants.all.filter { $0.type == .taste }
          #expect(tastes.count == 5)
      }

      @Test func mouthfeelCount() {
          let mouthfeels = FlavorConstants.all.filter { $0.type == .mouthfeel }
          #expect(mouthfeels.count == 7)
      }

      @Test func finishCount() {
          let finishes = FlavorConstants.all.filter { $0.type == .finish }
          #expect(finishes.count == 6)
      }

      @Test func noDuplicateNames() {
          let names = FlavorConstants.all.map { $0.name }
          #expect(Set(names).count == names.count)
      }

      @Test func noEmptyEmoji() {
          for item in FlavorConstants.all {
              #expect(!item.emoji.isEmpty)
          }
      }
  }
  ```

- [ ] **Step 2: 테스트 실행 — FAIL 확인 (FlavorConstants 없음)**

  Product → Test (Cmd+U). `FlavorConstants` 타입 없음 오류 예상.

- [ ] **Step 3: FlavorConstants.swift 구현**

  ```swift
  import Foundation

  enum WhiskeyCategory: String, CaseIterable, Codable {
      case singleMalt = "Single Malt"
      case blended    = "Blended"
      case bourbon    = "Bourbon"
      case irish      = "Irish"
      case japanese   = "Japanese"
      case other      = "Other"
  }

  enum FlavorType: String, CaseIterable, Codable {
      case aroma     = "aroma"
      case taste     = "taste"
      case mouthfeel = "mouthfeel"
      case finish    = "finish"
  }

  struct FlavorItem {
      let name: String
      let emoji: String
      let type: FlavorType
  }

  enum FlavorConstants {
      static let all: [FlavorItem] = [
          // Aroma (9)
          FlavorItem(name: "과일",   emoji: "🍎", type: .aroma),
          FlavorItem(name: "꽃",     emoji: "🌸", type: .aroma),
          FlavorItem(name: "곡물",   emoji: "🌾", type: .aroma),
          FlavorItem(name: "견과류", emoji: "🌰", type: .aroma),
          FlavorItem(name: "스파이시", emoji: "🌶️", type: .aroma),
          FlavorItem(name: "우디",   emoji: "🪵", type: .aroma),
          FlavorItem(name: "피트",   emoji: "🔥", type: .aroma),
          FlavorItem(name: "와인",   emoji: "🍷", type: .aroma),
          FlavorItem(name: "페인티", emoji: "🍯", type: .aroma),
          // Taste (5)
          FlavorItem(name: "단맛",   emoji: "🍬", type: .taste),
          FlavorItem(name: "짠맛",   emoji: "🧂", type: .taste),
          FlavorItem(name: "신맛",   emoji: "🍋", type: .taste),
          FlavorItem(name: "쓴맛",   emoji: "☕", type: .taste),
          FlavorItem(name: "감칠맛", emoji: "🫒", type: .taste),
          // Mouthfeel (7)
          FlavorItem(name: "가벼움",  emoji: "🪶", type: .mouthfeel),
          FlavorItem(name: "중간",    emoji: "⚖️", type: .mouthfeel),
          FlavorItem(name: "무거움",  emoji: "🏋️", type: .mouthfeel),
          FlavorItem(name: "부드러움", emoji: "🧈", type: .mouthfeel),
          FlavorItem(name: "거침",    emoji: "🪨", type: .mouthfeel),
          FlavorItem(name: "오일",    emoji: "💧", type: .mouthfeel),
          FlavorItem(name: "드라이",  emoji: "🏜️", type: .mouthfeel),
          // Finish (6)
          FlavorItem(name: "짧은",   emoji: "⚡", type: .finish),
          FlavorItem(name: "중간",   emoji: "⏳", type: .finish),
          FlavorItem(name: "긴",     emoji: "🌊", type: .finish),
          FlavorItem(name: "따뜻한", emoji: "🔆", type: .finish),
          FlavorItem(name: "스파이시", emoji: "🌶️", type: .finish),
          FlavorItem(name: "드라이", emoji: "🏜️", type: .finish),
      ]

      static func items(for type: FlavorType) -> [FlavorItem] {
          all.filter { $0.type == type }
      }
  }
  ```

  > Xcode에서 Constants 그룹에 FlavorConstants.swift 파일 생성 후 위 코드 입력. "whiskey note" 타겟 체크.

- [ ] **Step 4: 테스트 실행 — PASS 확인 (Cmd+U)**

- [ ] **Step 5: 커밋**

  ```bash
  git add -A
  git commit -m "feat: FlavorConstants, WhiskeyCategory, FlavorType 정의"
  ```

---

## Task 3: AppColors

**Files:**
- Create: `whiskey note/Constants/AppColors.swift`

- [ ] **Step 1: AppColors.swift 생성**

  ```swift
  import SwiftUI

  enum AppColors {
      static let background    = Color(hex: "#faf8f5")
      static let accent        = Color(hex: "#9b6a2f")
      static let tagBackground = Color(hex: "#f0e8d8")
      static let textPrimary   = Color(hex: "#2d2d2d")
      static let textSecondary = Color(hex: "#888888")
      static let star          = Color(hex: "#e8a838")
  }

  extension Color {
      init(hex: String) {
          let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
          var int: UInt64 = 0
          Scanner(string: hex).scanHexInt64(&int)
          let r = Double((int >> 16) & 0xFF) / 255
          let g = Double((int >> 8)  & 0xFF) / 255
          let b = Double(int         & 0xFF) / 255
          self.init(red: r, green: g, blue: b)
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: AppColors 디자인 컬러 상수 추가"
  ```

---

## Task 4: 데이터 모델

**Files:**
- Create: `whiskey note/Models/WhiskeyNote.swift`
- Create: `whiskey note/Models/FlavorIntensity.swift`
- Modify: `whiskey note/whiskey_noteApp.swift`

- [ ] **Step 1: WhiskeyNote.swift 생성**

  ```swift
  import Foundation
  import SwiftData

  @Model final class WhiskeyNote {
      @Attribute(.unique) var id: UUID = UUID()
      var name: String = ""
      var category: String = WhiskeyCategory.singleMalt.rawValue
      var age: Int?
      var abv: Double?
      var price: Int?
      var rating: Double = 0.0
      var photoData: Data?
      var memo: String = ""
      var dish: String = ""
      var createdAt: Date = Date()

      @Relationship(deleteRule: .cascade, inverse: \FlavorIntensity.note)
      var flavorIntensities: [FlavorIntensity] = []

      init(name: String = "",
           category: String = WhiskeyCategory.singleMalt.rawValue) {
          self.name = name
          self.category = category
      }
  }
  ```

- [ ] **Step 2: FlavorIntensity.swift 생성**

  ```swift
  import Foundation
  import SwiftData

  @Model final class FlavorIntensity {
      @Attribute(.unique) var id: UUID = UUID()
      var flavorType: String = FlavorType.aroma.rawValue
      var name: String = ""
      var intensity: Int = 0
      var note: WhiskeyNote?

      init(flavorType: FlavorType, name: String, intensity: Int) {
          self.flavorType = flavorType.rawValue
          self.name = name
          self.intensity = intensity
      }
  }
  ```

- [ ] **Step 3: whiskey_noteApp.swift에 ModelContainer 추가**

  ```swift
  import SwiftUI
  import SwiftData

  @main
  struct whiskey_noteApp: App {
      var body: some Scene {
          WindowGroup {
              ContentView()
          }
          .modelContainer(for: [WhiskeyNote.self, FlavorIntensity.self])
      }
  }
  ```

- [ ] **Step 4: 빌드 확인 (Cmd+B) — 에러 없이 통과**

- [ ] **Step 5: 커밋**

  ```bash
  git add -A
  git commit -m "feat: WhiskeyNote, FlavorIntensity 데이터 모델 추가"
  ```

---

## Task 5: StarRatingView 컴포넌트

**Files:**
- Create: `whiskey note/Views/Components/StarRatingView.swift`
- Test: `whiskey noteTests/WhiskeyNoteTests.swift` (테스트 추가)

- [ ] **Step 1: 별점 계산 로직 테스트 추가**

  `WhiskeyNoteTests.swift`에 아래 Suite 추가:

  ```swift
  @Suite("StarRating Logic")
  struct StarRatingTests {
      // 각 별의 왼쪽 반 탭 → x < 0.5 → 해당 별 인덱스 * 1 - 0.5
      // 각 별의 오른쪽 반 탭 → x >= 0.5 → 해당 별 인덱스 * 1.0
      func ratingForTap(starIndex: Int, isLeftHalf: Bool) -> Double {
          let base = Double(starIndex + 1)
          return isLeftHalf ? base - 0.5 : base
      }

      @Test func leftHalfOfFirstStar() {
          #expect(ratingForTap(starIndex: 0, isLeftHalf: true) == 0.5)
      }

      @Test func rightHalfOfFirstStar() {
          #expect(ratingForTap(starIndex: 0, isLeftHalf: false) == 1.0)
      }

      @Test func leftHalfOfFifthStar() {
          #expect(ratingForTap(starIndex: 4, isLeftHalf: true) == 4.5)
      }

      @Test func rightHalfOfFifthStar() {
          #expect(ratingForTap(starIndex: 4, isLeftHalf: false) == 5.0)
      }
  }
  ```

- [ ] **Step 2: 테스트 실행 — PASS 확인**

- [ ] **Step 3: StarRatingView.swift 구현**

  ```swift
  import SwiftUI

  struct StarRatingView: View {
      @Binding var rating: Double
      var isEditable: Bool = true
      var starSize: CGFloat = 28

      var body: some View {
          HStack(spacing: 4) {
              ForEach(0..<5, id: \.self) { index in
                  starImage(for: index)
                      .font(.system(size: starSize))
                      .foregroundStyle(AppColors.star)
                      .overlay(
                          GeometryReader { geo in
                              if isEditable {
                                  HStack(spacing: 0) {
                                      // 왼쪽 반: 0.5 단위
                                      Color.clear
                                          .contentShape(Rectangle())
                                          .onTapGesture {
                                              rating = Double(index) + 0.5
                                          }
                                      // 오른쪽 반: 1.0 단위
                                      Color.clear
                                          .contentShape(Rectangle())
                                          .onTapGesture {
                                              rating = Double(index) + 1.0
                                          }
                                  }
                              }
                          }
                      )
              }
          }
      }

      private func starImage(for index: Int) -> Image {
          let fullThreshold = Double(index) + 1.0
          let halfThreshold = Double(index) + 0.5
          if rating >= fullThreshold {
              return Image(systemName: "star.fill")
          } else if rating >= halfThreshold {
              return Image(systemName: "star.leadinghalf.filled")
          } else {
              return Image(systemName: "star")
          }
      }
  }

  #Preview {
      @Previewable @State var rating = 3.5
      StarRatingView(rating: $rating)
          .padding()
  }
  ```

- [ ] **Step 4: 빌드 확인 (Cmd+B)**

- [ ] **Step 5: 커밋**

  ```bash
  git add -A
  git commit -m "feat: StarRatingView 컴포넌트 (0.5 단위 별점)"
  ```

---

## Task 6: FlavorSliderRow 컴포넌트

**Files:**
- Create: `whiskey note/Views/Components/FlavorSliderRow.swift`

- [ ] **Step 1: FlavorSliderRow.swift 구현**

  ```swift
  import SwiftUI

  struct FlavorSliderRow: View {
      let item: FlavorItem
      @Binding var intensity: Int   // 0~5

      var body: some View {
          HStack(spacing: 12) {
              Text(item.emoji)
                  .font(.title3)
                  .frame(width: 28)

              Text(item.name)
                  .font(.subheadline)
                  .foregroundStyle(AppColors.textPrimary)
                  .frame(width: 60, alignment: .leading)

              Slider(
                  value: Binding(
                      get: { Double(intensity) },
                      set: { intensity = Int($0.rounded()) }
                  ),
                  in: 0...5,
                  step: 1
              )
              .tint(AppColors.accent)

              Text(intensity == 0 ? "–" : "\(intensity)")
                  .font(.subheadline.monospacedDigit())
                  .foregroundStyle(intensity == 0 ? AppColors.textSecondary : AppColors.accent)
                  .frame(width: 20, alignment: .trailing)
          }
          .padding(.vertical, 4)
      }
  }

  #Preview {
      @Previewable @State var intensity = 3
      FlavorSliderRow(
          item: FlavorItem(name: "피트", emoji: "🔥", type: .aroma),
          intensity: $intensity
      )
      .padding()
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: FlavorSliderRow 컴포넌트"
  ```

---

## Task 7: 위자드 Step 1 — 사진 & 기본 정보

**Files:**
- Create: `whiskey note/Views/Wizard/WizardStep1View.swift`

- [ ] **Step 1: WizardStep1View.swift 구현**

  ```swift
  import SwiftUI
  import PhotosUI

  struct WizardStep1View: View {
      @Binding var name: String
      @Binding var category: String
      @Binding var abv: String          // TextField용 String (저장 시 Double? 변환)
      @Binding var age: String          // TextField용 String (저장 시 Int? 변환)
      @Binding var price: String        // TextField용 String (저장 시 Int? 변환)
      @Binding var selectedPhoto: PhotosPickerItem?
      @Binding var photoData: Data?

      var body: some View {
          ScrollView {
              VStack(spacing: 16) {
                  // 사진 영역
                  PhotosPicker(selection: $selectedPhoto, matching: .images) {
                      Group {
                          if let photoData, let uiImage = UIImage(data: photoData) {
                              Image(uiImage: uiImage)
                                  .resizable()
                                  .scaledToFill()
                                  .frame(maxWidth: .infinity)
                                  .frame(height: 200)
                                  .clipShape(RoundedRectangle(cornerRadius: 12))
                          } else {
                              RoundedRectangle(cornerRadius: 12)
                                  .fill(AppColors.tagBackground)
                                  .frame(maxWidth: .infinity)
                                  .frame(height: 120)
                                  .overlay {
                                      VStack(spacing: 8) {
                                          Image(systemName: "camera.fill")
                                              .font(.largeTitle)
                                              .foregroundStyle(AppColors.accent)
                                          Text("사진 추가 (선택)")
                                              .font(.subheadline)
                                              .foregroundStyle(AppColors.textSecondary)
                                      }
                                  }
                          }
                      }
                  }
                  .onChange(of: selectedPhoto) { _, newItem in
                      Task {
                          if let data = try? await newItem?.loadTransferable(type: Data.self) {
                              photoData = compressImage(data)
                          }
                      }
                  }

                  // 기본 정보 폼
                  VStack(spacing: 12) {
                      formField(label: "위스키 이름 *") {
                          TextField("예: Laphroaig 10yr", text: $name)
                      }

                      formField(label: "종류") {
                          Picker("종류", selection: $category) {
                              ForEach(WhiskeyCategory.allCases, id: \.rawValue) { cat in
                                  Text(cat.rawValue).tag(cat.rawValue)
                              }
                          }
                          .pickerStyle(.menu)
                          .tint(AppColors.accent)
                          .frame(maxWidth: .infinity, alignment: .leading)
                      }

                      HStack(spacing: 12) {
                          formField(label: "도수 (%)") {
                              TextField("예: 43.0", text: $abv)
                                  .keyboardType(.decimalPad)
                          }
                          formField(label: "숙성 연수") {
                              TextField("예: 10", text: $age)
                                  .keyboardType(.numberPad)
                          }
                      }

                      formField(label: "가격 (원)") {
                          TextField("예: 80000", text: $price)
                              .keyboardType(.numberPad)
                      }
                  }
              }
              .padding()
          }
      }

      @ViewBuilder
      private func formField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
          VStack(alignment: .leading, spacing: 6) {
              Text(label)
                  .font(.caption)
                  .foregroundStyle(AppColors.textSecondary)
              content()
                  .padding(.horizontal, 12)
                  .padding(.vertical, 10)
                  .background(Color.white)
                  .clipShape(RoundedRectangle(cornerRadius: 8))
                  .overlay(
                      RoundedRectangle(cornerRadius: 8)
                          .stroke(AppColors.tagBackground, lineWidth: 1)
                  )
          }
      }

      private func compressImage(_ data: Data) -> Data {
          guard let uiImage = UIImage(data: data) else { return data }
          let maxSize: CGFloat = 800
          let scale = min(maxSize / uiImage.size.width, maxSize / uiImage.size.height, 1.0)
          let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)
          let renderer = UIGraphicsImageRenderer(size: newSize)
          let resized = renderer.image { _ in uiImage.draw(in: CGRect(origin: .zero, size: newSize)) }
          return resized.jpegData(compressionQuality: 0.8) ?? data
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: WizardStep1View - 사진 & 기본 정보"
  ```

---

## Task 8: 위자드 Step 2 — 향 슬라이더

**Files:**
- Create: `whiskey note/Views/Wizard/WizardStep2View.swift`

- [ ] **Step 1: WizardStep2View.swift 구현**

  ```swift
  import SwiftUI

  struct WizardStep2View: View {
      // key: FlavorItem.name, value: 0~5
      @Binding var intensities: [String: Int]

      private let aromaItems = FlavorConstants.items(for: .aroma)

      var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 8) {
                  Text("향을 얼마나 강하게 느꼈나요?")
                      .font(.subheadline)
                      .foregroundStyle(AppColors.textSecondary)
                      .padding(.bottom, 8)

                  ForEach(aromaItems, id: \.name) { item in
                      FlavorSliderRow(
                          item: item,
                          intensity: Binding(
                              get: { intensities[item.name] ?? 0 },
                              set: { intensities[item.name] = $0 }
                          )
                      )
                      Divider()
                  }
              }
              .padding()
          }
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: WizardStep2View - 향 슬라이더"
  ```

---

## Task 9: 위자드 Step 3 — 맛·질감·마무리 슬라이더

**Files:**
- Create: `whiskey note/Views/Wizard/WizardStep3View.swift`

- [ ] **Step 1: WizardStep3View.swift 구현**

  ```swift
  import SwiftUI

  struct WizardStep3View: View {
      @Binding var intensities: [String: Int]

      private let sections: [(title: String, items: [FlavorItem])] = [
          ("맛 (Taste)",         FlavorConstants.items(for: .taste)),
          ("질감 (Mouthfeel)",   FlavorConstants.items(for: .mouthfeel)),
          ("마무리 (Finish)",    FlavorConstants.items(for: .finish)),
      ]

      var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 20) {
                  ForEach(sections, id: \.title) { section in
                      VStack(alignment: .leading, spacing: 8) {
                          Text(section.title)
                              .font(.headline)
                              .foregroundStyle(AppColors.accent)

                          ForEach(section.items, id: \.name) { item in
                              FlavorSliderRow(
                                  item: item,
                                  intensity: Binding(
                                      get: { intensities[item.name] ?? 0 },
                                      set: { intensities[item.name] = $0 }
                                  )
                              )
                              Divider()
                          }
                      }
                  }
              }
              .padding()
          }
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: WizardStep3View - 맛·질감·마무리 슬라이더"
  ```

---

## Task 10: 위자드 Step 4 — 총평

**Files:**
- Create: `whiskey note/Views/Wizard/WizardStep4View.swift`

- [ ] **Step 1: WizardStep4View.swift 구현**

  ```swift
  import SwiftUI

  struct WizardStep4View: View {
      @Binding var rating: Double
      @Binding var memo: String
      @Binding var dish: String

      var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 20) {
                  // 별점
                  VStack(alignment: .leading, spacing: 8) {
                      Text("전체 평점")
                          .font(.headline)
                          .foregroundStyle(AppColors.accent)
                      HStack {
                          StarRatingView(rating: $rating)
                          Spacer()
                          Text(rating == 0 ? "평가 없음" : String(format: "%.1f", rating))
                              .font(.subheadline)
                              .foregroundStyle(AppColors.textSecondary)
                      }
                  }

                  Divider()

                  // 메모
                  VStack(alignment: .leading, spacing: 8) {
                      Text("메모")
                          .font(.headline)
                          .foregroundStyle(AppColors.accent)
                      ZStack(alignment: .topLeading) {
                          TextEditor(text: $memo)
                              .frame(minHeight: 120)
                              .padding(8)
                              .background(Color.white)
                              .clipShape(RoundedRectangle(cornerRadius: 8))
                              .overlay(
                                  RoundedRectangle(cornerRadius: 8)
                                      .stroke(AppColors.tagBackground, lineWidth: 1)
                              )
                          if memo.isEmpty {
                              Text("자유롭게 기록해보세요")
                                  .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                                  .font(.body)
                                  .padding(.horizontal, 12)
                                  .padding(.vertical, 16)
                                  .allowsHitTesting(false)
                          }
                      }
                  }

                  // 안주
                  VStack(alignment: .leading, spacing: 8) {
                      Text("같이 먹은 안주")
                          .font(.headline)
                          .foregroundStyle(AppColors.accent)
                      TextField("같이 먹은 안주", text: $dish)
                          .padding(.horizontal, 12)
                          .padding(.vertical, 10)
                          .background(Color.white)
                          .clipShape(RoundedRectangle(cornerRadius: 8))
                          .overlay(
                              RoundedRectangle(cornerRadius: 8)
                                  .stroke(AppColors.tagBackground, lineWidth: 1)
                          )
                  }
              }
              .padding()
          }
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: WizardStep4View - 별점·메모·안주"
  ```

---

## Task 11: NoteWizardView — 오케스트레이터

**Files:**
- Create: `whiskey note/Views/Wizard/NoteWizardView.swift`
- Test: `whiskey noteTests/WhiskeyNoteTests.swift` (dirty check 테스트 추가)

- [ ] **Step 1: dirty check 테스트 추가**

  ```swift
  @Suite("WizardDirtyCheck")
  struct WizardDirtyCheckTests {
      func isDirtyCreate(name: String = "", photoData: Data? = nil,
                         abv: String = "", age: String = "", price: String = "",
                         intensities: [String: Int] = [:],
                         memo: String = "", dish: String = "") -> Bool {
          !name.isEmpty
          || photoData != nil
          || !abv.isEmpty || !age.isEmpty || !price.isEmpty
          || intensities.values.contains { $0 > 0 }
          || !memo.isEmpty || !dish.isEmpty
      }

      @Test func emptyStateIsNotDirty() {
          #expect(!isDirtyCreate())
      }

      @Test func nameInputIsDirty() {
          #expect(isDirtyCreate(name: "Laphroaig"))
      }

      @Test func intensityZeroIsNotDirty() {
          #expect(!isDirtyCreate(intensities: ["피트": 0]))
      }

      @Test func intensityAboveZeroIsDirty() {
          #expect(isDirtyCreate(intensities: ["피트": 3]))
      }
  }
  ```

- [ ] **Step 2: 테스트 실행 — PASS 확인**

- [ ] **Step 3: NoteWizardView.swift 구현**

  ```swift
  import SwiftUI
  import PhotosUI
  import SwiftData

  struct NoteWizardView: View {
      // 수정 모드: 기존 note 주입. nil이면 새로 만들기 모드.
      var existingNote: WhiskeyNote?

      @Environment(\.modelContext) private var modelContext
      @Environment(\.dismiss) private var dismiss

      @State private var currentStep = 1
      @State private var showCancelAlert = false

      // Step 1
      @State private var name = ""
      @State private var category = WhiskeyCategory.singleMalt.rawValue
      @State private var abvText = ""
      @State private var ageText = ""
      @State private var priceText = ""
      @State private var selectedPhoto: PhotosPickerItem?
      @State private var photoData: Data?

      // Step 2 & 3: key = FlavorItem.name
      @State private var intensities: [String: Int] = [:]

      // Step 4
      @State private var rating: Double = 0.0
      @State private var memo = ""
      @State private var dish = ""

      // 수정 모드 초기값 스냅샷 (dirty check용)
      @State private var initialSnapshot: EditSnapshot?

      var isEditMode: Bool { existingNote != nil }

      var body: some View {
          NavigationStack {
              VStack(spacing: 0) {
                  progressBar
                  stepContent
              }
              .background(AppColors.background.ignoresSafeArea())
              .navigationTitle(stepTitle)
              .navigationBarTitleDisplayMode(.inline)
              .toolbar { toolbarContent }
              .alert("저장하지 않고 나가시겠어요?", isPresented: $showCancelAlert) {
                  Button("나가기", role: .destructive) { dismiss() }
                  Button("계속 작성", role: .cancel) {}
              }
              .onAppear { loadExistingNote() }
          }
      }

      // MARK: - Progress Bar

      private var progressBar: some View {
          HStack(spacing: 4) {
              ForEach(1...4, id: \.self) { step in
                  RoundedRectangle(cornerRadius: 2)
                      .fill(step <= currentStep ? AppColors.accent : AppColors.tagBackground)
                      .frame(height: 4)
              }
          }
          .padding(.horizontal)
          .padding(.top, 8)
      }

      // MARK: - Step Content

      @ViewBuilder
      private var stepContent: some View {
          switch currentStep {
          case 1:
              WizardStep1View(name: $name, category: $category,
                              abv: $abvText, age: $ageText, price: $priceText,
                              selectedPhoto: $selectedPhoto, photoData: $photoData)
          case 2:
              WizardStep2View(intensities: $intensities)
          case 3:
              WizardStep3View(intensities: $intensities)
          default:
              WizardStep4View(rating: $rating, memo: $memo, dish: $dish)
          }
      }

      // MARK: - Toolbar

      @ToolbarContentBuilder
      private var toolbarContent: some ToolbarContent {
          ToolbarItem(placement: .cancellationAction) {
              Button(currentStep == 1 ? "취소" : "이전") {
                  if currentStep == 1 {
                      handleCancel()
                  } else {
                      currentStep -= 1
                  }
              }
          }
          ToolbarItem(placement: .confirmationAction) {
              if currentStep < 4 {
                  Button("다음") { currentStep += 1 }
                      .disabled(currentStep == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty)
              } else {
                  Button("저장") { saveNote() }
                      .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                      .fontWeight(.bold)
              }
          }
      }

      private var stepTitle: String {
          switch currentStep {
          case 1: "사진 & 기본 정보"
          case 2: "향 (Aroma)"
          case 3: "맛·질감·마무리"
          default: "총평"
          }
      }

      // MARK: - Cancel Logic

      private func handleCancel() {
          if isDirty { showCancelAlert = true } else { dismiss() }
      }

      private var isDirty: Bool {
          if isEditMode {
              guard let snap = initialSnapshot else { return false }
              return name != snap.name
                  || category != snap.category
                  || abvText != snap.abvText
                  || ageText != snap.ageText
                  || priceText != snap.priceText
                  || photoData != snap.photoData
                  || intensities != snap.intensities
                  || rating != snap.rating
                  || memo != snap.memo
                  || dish != snap.dish
          } else {
              return !name.isEmpty
                  || photoData != nil
                  || !abvText.isEmpty || !ageText.isEmpty || !priceText.isEmpty
                  || intensities.values.contains { $0 > 0 }
                  || !memo.isEmpty || !dish.isEmpty
          }
      }

      // MARK: - Load Existing Note

      private func loadExistingNote() {
          guard let note = existingNote else { return }
          name = note.name
          category = note.category
          abvText = note.abv.map { String($0) } ?? ""
          ageText = note.age.map { String($0) } ?? ""
          priceText = note.price.map { String($0) } ?? ""
          photoData = note.photoData
          rating = note.rating
          memo = note.memo
          dish = note.dish

          // FlavorIntensity → [name: intensity] 딕셔너리
          var dict: [String: Int] = [:]
          for item in FlavorConstants.all { dict[item.name] = 0 }
          for fi in note.flavorIntensities { dict[fi.name] = fi.intensity }
          intensities = dict

          initialSnapshot = EditSnapshot(
              name: name, category: category,
              abvText: abvText, ageText: ageText, priceText: priceText,
              photoData: photoData, intensities: intensities,
              rating: rating, memo: memo, dish: dish
          )
      }

      // MARK: - Save

      private func saveNote() {
          let note = existingNote ?? WhiskeyNote()

          note.name = name.trimmingCharacters(in: .whitespaces)
          note.category = category
          note.abv = {
              let v = Double(abvText)
              return (v != nil && v! >= 0 && v! <= 99.9) ? v : nil
          }()
          note.age = Int(ageText)
          note.price = Int(priceText)
          note.photoData = photoData
          note.rating = rating
          note.memo = memo
          note.dish = dish
          note.createdAt = existingNote?.createdAt ?? Date()

          // FlavorIntensity 업데이트: intensity > 0인 항목만 저장
          if isEditMode {
              for fi in note.flavorIntensities { modelContext.delete(fi) }
          }
          for (name, intensity) in intensities where intensity > 0 {
              guard let flavorItem = FlavorConstants.all.first(where: { $0.name == name }) else { continue }
              let fi = FlavorIntensity(flavorType: flavorItem.type, name: name, intensity: intensity)
              fi.note = note
              note.flavorIntensities.append(fi)
              modelContext.insert(fi)
          }

          if !isEditMode { modelContext.insert(note) }
          dismiss()
      }
  }

  // MARK: - Edit Snapshot

  private struct EditSnapshot {
      var name, category, abvText, ageText, priceText: String
      var photoData: Data?
      var intensities: [String: Int]
      var rating: Double
      var memo, dish: String
  }
  ```

- [ ] **Step 4: 빌드 확인 (Cmd+B)**

- [ ] **Step 5: 커밋**

  ```bash
  git add -A
  git commit -m "feat: NoteWizardView - 4단계 위자드 오케스트레이터"
  ```

---

## Task 12: NoteDetailView

**Files:**
- Create: `whiskey note/Views/Detail/NoteDetailView.swift`

- [ ] **Step 1: NoteDetailView.swift 구현**

  ```swift
  import SwiftUI
  import SwiftData

  struct NoteDetailView: View {
      let note: WhiskeyNote

      @Environment(\.modelContext) private var modelContext
      @Environment(\.dismiss) private var dismiss
      @State private var showDeleteAlert = false
      @State private var showWizard = false

      private let priceFormatter: NumberFormatter = {
          let f = NumberFormatter()
          f.numberStyle = .decimal
          return f
      }()

      private static let dateFormatter: DateFormatter = {
          let f = DateFormatter()
          f.dateFormat = "yyyy.MM.dd"
          return f
      }()

      var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 20) {
                  // 사진
                  if let data = note.photoData, let uiImage = UIImage(data: data) {
                      Image(uiImage: uiImage)
                          .resizable()
                          .scaledToFill()
                          .frame(maxWidth: .infinity)
                          .frame(height: 220)
                          .clipped()
                  }

                  VStack(alignment: .leading, spacing: 16) {
                      // 기본 정보
                      basicInfoSection

                      Divider()

                      // 별점
                      StarRatingView(rating: .constant(note.rating), isEditable: false)

                      // 날짜 — 스펙: "yyyy.MM.dd" 고정 형식
                      Text(Self.dateFormatter.string(from: note.createdAt))
                          .font(.caption)
                          .foregroundStyle(AppColors.textSecondary)

                      Divider()

                      // 향·맛·질감·마무리
                      flavorSections

                      // 메모
                      if !note.memo.isEmpty {
                          Divider()
                          sectionHeader("메모")
                          Text(note.memo)
                              .font(.body)
                              .foregroundStyle(AppColors.textPrimary)
                      }

                      // 안주
                      if !note.dish.isEmpty {
                          Divider()
                          sectionHeader("같이 먹은 안주")
                          Text(note.dish)
                              .font(.body)
                              .foregroundStyle(AppColors.textPrimary)
                      }

                      // 삭제 버튼
                      Button(role: .destructive) {
                          showDeleteAlert = true
                      } label: {
                          Label("노트 삭제", systemImage: "trash")
                              .frame(maxWidth: .infinity)
                      }
                      .buttonStyle(.bordered)
                      .padding(.top, 8)
                  }
                  .padding(.horizontal)
              }
          }
          .background(AppColors.background.ignoresSafeArea())
          .navigationTitle(note.name)
          .navigationBarTitleDisplayMode(.large)
          .toolbar {
              ToolbarItem(placement: .primaryAction) {
                  Button("수정") { showWizard = true }
              }
          }
          .fullScreenCover(isPresented: $showWizard) {
              NoteWizardView(existingNote: note)
          }
          .alert("정말 삭제할까요?", isPresented: $showDeleteAlert) {
              Button("삭제", role: .destructive) {
                  modelContext.delete(note)
                  dismiss()
              }
              Button("취소", role: .cancel) {}
          }
      }

      private var basicInfoSection: some View {
          VStack(alignment: .leading, spacing: 4) {
              Text(note.name)
                  .font(.title2.bold())
                  .foregroundStyle(AppColors.textPrimary)
              HStack(spacing: 8) {
                  Text(note.category)
                  if let age = note.age { Text("·"); Text("\(age)yr") }
                  if let abv = note.abv { Text("·"); Text(String(format: "%.1f%%", abv)) }
                  if let price = note.price,
                     let formatted = priceFormatter.string(from: NSNumber(value: price)) {
                      Text("·"); Text("\(formatted)원")
                  }
              }
              .font(.subheadline)
              .foregroundStyle(AppColors.accent)
          }
      }

      @ViewBuilder
      private var flavorSections: some View {
          let sections: [(title: String, type: FlavorType)] = [
              ("향 (Aroma)", .aroma), ("맛 (Taste)", .taste),
              ("질감 (Mouthfeel)", .mouthfeel), ("마무리 (Finish)", .finish)
          ]
          ForEach(sections, id: \.title) { section in
              let items = note.flavorIntensities
                  .filter { $0.flavorType == section.type.rawValue && $0.intensity > 0 }
                  .sorted { $0.intensity > $1.intensity }
              if !items.isEmpty {
                  sectionHeader(section.title)
                  ForEach(items, id: \.id) { fi in
                      if let flavorItem = FlavorConstants.all.first(where: { $0.name == fi.name }) {
                          HStack {
                              Text("\(flavorItem.emoji) \(fi.name)")
                                  .font(.subheadline)
                                  .foregroundStyle(AppColors.textPrimary)
                              Spacer()
                              HStack(spacing: 2) {
                                  ForEach(1...5, id: \.self) { i in
                                      Circle()
                                          .fill(i <= fi.intensity ? AppColors.accent : AppColors.tagBackground)
                                          .frame(width: 8, height: 8)
                                  }
                              }
                          }
                      }
                  }
                  Divider()
              }
          }
      }

      private func sectionHeader(_ title: String) -> some View {
          Text(title)
              .font(.headline)
              .foregroundStyle(AppColors.accent)
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: NoteDetailView"
  ```

---

## Task 13: NoteCardView & NoteListView

**Files:**
- Create: `whiskey note/Views/NoteList/NoteCardView.swift`
- Create: `whiskey note/Views/NoteList/NoteListView.swift`

- [ ] **Step 1: NoteCardView.swift 구현**

  ```swift
  import SwiftUI

  struct NoteCardView: View {
      let note: WhiskeyNote

      private var topAromaTags: [FlavorIntensity] {
          let aromaItems = note.flavorIntensities
              .filter { $0.flavorType == FlavorType.aroma.rawValue && $0.intensity > 0 }
          let sorted = aromaItems.sorted { lhs, rhs in
              if lhs.intensity != rhs.intensity { return lhs.intensity > rhs.intensity }
              // 동점이면 FlavorConstants 정의 순서
              let lhsIdx = FlavorConstants.all.firstIndex(where: { $0.name == lhs.name }) ?? 999
              let rhsIdx = FlavorConstants.all.firstIndex(where: { $0.name == rhs.name }) ?? 999
              return lhsIdx < rhsIdx
          }
          return Array(sorted.prefix(3))
      }

      var body: some View {
          VStack(alignment: .leading, spacing: 6) {
              HStack {
                  Text(note.name)
                      .font(.headline)
                      .foregroundStyle(AppColors.textPrimary)
                  Spacer()
                  StarRatingView(rating: .constant(note.rating), isEditable: false, starSize: 14)
              }

              HStack(spacing: 4) {
                  Text(note.category)
                  if let abv = note.abv { Text("·"); Text(String(format: "%.1f%%", abv)) }
                  if let age = note.age { Text("·"); Text("\(age)yr") }
              }
              .font(.caption)
              .foregroundStyle(AppColors.accent)

              if !topAromaTags.isEmpty {
                  HStack(spacing: 6) {
                      ForEach(topAromaTags, id: \.id) { fi in
                          if let item = FlavorConstants.all.first(where: { $0.name == fi.name }) {
                              Text("\(item.emoji) \(fi.name)")
                                  .font(.caption2)
                                  .padding(.horizontal, 8)
                                  .padding(.vertical, 3)
                                  .background(AppColors.tagBackground)
                                  .foregroundStyle(AppColors.accent)
                                  .clipShape(Capsule())
                          }
                      }
                  }
              }
          }
          .padding()
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
      }
  }
  ```

- [ ] **Step 2: NoteListView.swift 구현**

  ```swift
  import SwiftUI
  import SwiftData

  struct NoteListView: View {
      @Environment(\.modelContext) private var modelContext
      @Query(sort: \WhiskeyNote.createdAt, order: .reverse) private var notes: [WhiskeyNote]

      @State private var searchText = ""
      @State private var showWizard = false

      private var filteredNotes: [WhiskeyNote] {
          guard !searchText.isEmpty else { return notes }
          return notes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
      }

      var body: some View {
          NavigationStack {
              Group {
                  if notes.isEmpty {
                      ContentUnavailableView("아직 기록이 없어요.", systemImage: "wineglass")
                  } else {
                      // List를 사용해야 .onDelete 스와이프 삭제가 동작함
                      List {
                          ForEach(filteredNotes) { note in
                              NavigationLink(value: note) {
                                  NoteCardView(note: note)
                              }
                              .listRowBackground(AppColors.background)
                              .listRowSeparator(.hidden)
                          }
                          .onDelete(perform: deleteNotes)
                      }
                      .listStyle(.plain)
                      .background(AppColors.background)
                      .scrollContentBackground(.hidden)
                  }
              }
              .background(AppColors.background.ignoresSafeArea())
              .searchable(text: $searchText, prompt: "위스키 이름 검색")
              .navigationTitle("테이스팅 노트")
              .toolbar {
                  ToolbarItem(placement: .primaryAction) {
                      Button { showWizard = true } label: {
                          Image(systemName: "plus")
                      }
                  }
              }
              .navigationDestination(for: WhiskeyNote.self) { note in
                  NoteDetailView(note: note)
              }
              .fullScreenCover(isPresented: $showWizard) {
                  NoteWizardView()
              }
          }
      }

      private func deleteNotes(at offsets: IndexSet) {
          for index in offsets {
              modelContext.delete(filteredNotes[index])
          }
      }
  }
  ```

- [ ] **Step 3: 빌드 확인 (Cmd+B)**

- [ ] **Step 4: 커밋**

  ```bash
  git add -A
  git commit -m "feat: NoteCardView & NoteListView"
  ```

---

## Task 14: StatsView

**Files:**
- Create: `whiskey note/Views/Stats/StatsView.swift`
- Test: `whiskey noteTests/WhiskeyNoteTests.swift` (통계 로직 테스트 추가)

- [ ] **Step 1: 통계 계산 로직 테스트 추가**

  ```swift
  @Suite("StatsCalculations")
  struct StatsCalculationsTests {
      // TOP5 향: intensity > 0인 노트만 포함하여 평균
      func topAromaAverages(from data: [(name: String, intensity: Int)]) -> [(name: String, avg: Double)] {
          var sums: [String: Int] = [:]
          var counts: [String: Int] = [:]
          for (name, intensity) in data where intensity > 0 {
              sums[name, default: 0] += intensity
              counts[name, default: 0] += 1
          }
          return sums.map { name, sum in
              (name: name, avg: Double(sum) / Double(counts[name]!))
          }
          .sorted { $0.avg > $1.avg }
      }

      @Test func averageExcludesZero() {
          let data: [(String, Int)] = [("피트", 5), ("피트", 0), ("과일", 3)]
          let result = topAromaAverages(from: data)
          let peat = result.first { $0.name == "피트" }!
          // 5 + 0 → 0 제외 → 5/1 = 5.0
          #expect(peat.avg == 5.0)
      }

      @Test func averageWithMultipleNotes() {
          let data: [(String, Int)] = [("피트", 4), ("피트", 2)]
          let result = topAromaAverages(from: data)
          let peat = result.first { $0.name == "피트" }!
          #expect(peat.avg == 3.0)
      }

      @Test func topIsSortedDescending() {
          let data: [(String, Int)] = [("피트", 2), ("과일", 5)]
          let result = topAromaAverages(from: data)
          #expect(result[0].name == "과일")
      }
  }
  ```

- [ ] **Step 2: 테스트 실행 — PASS 확인**

- [ ] **Step 3: StatsView.swift 구현**

  ```swift
  import SwiftUI
  import SwiftData

  struct StatsView: View {
      @Query private var notes: [WhiskeyNote]

      var body: some View {
          NavigationStack {
              Group {
                  if notes.isEmpty {
                      ContentUnavailableView(
                          "기록이 쌓이면 통계가 표시됩니다.",
                          systemImage: "chart.bar"
                      )
                  } else {
                      ScrollView {
                          VStack(spacing: 24) {
                              topAromaChart
                              categoryDistribution
                              ratingDistribution
                          }
                          .padding()
                      }
                  }
              }
              .background(AppColors.background.ignoresSafeArea())
              .navigationTitle("통계")
          }
      }

      // MARK: - Top Aroma Chart

      private var topAromaData: [(name: String, emoji: String, avg: Double)] {
          var sums: [String: Int] = [:]
          var counts: [String: Int] = [:]
          for note in notes {
              for fi in note.flavorIntensities where fi.flavorType == FlavorType.aroma.rawValue && fi.intensity > 0 {
                  sums[fi.name, default: 0] += fi.intensity
                  counts[fi.name, default: 0] += 1
              }
          }
          return sums
              .map { name, sum -> (name: String, emoji: String, avg: Double) in
                  let emoji = FlavorConstants.all.first { $0.name == name }?.emoji ?? ""
                  return (name: name, emoji: emoji, avg: Double(sum) / Double(counts[name]!))
              }
              .sorted { $0.avg > $1.avg }
              .prefix(5)
              .map { $0 }
      }

      private var topAromaChart: some View {
          VStack(alignment: .leading, spacing: 12) {
              Text("선호 향 TOP 5")
                  .font(.headline)
                  .foregroundStyle(AppColors.accent)

              if topAromaData.isEmpty {
                  Text("향 데이터가 없어요.")
                      .font(.subheadline)
                      .foregroundStyle(AppColors.textSecondary)
              } else {
                  let maxAvg = topAromaData.first?.avg ?? 1
                  ForEach(topAromaData, id: \.name) { item in
                      HStack(spacing: 8) {
                          Text("\(item.emoji) \(item.name)")
                              .font(.subheadline)
                              .frame(width: 90, alignment: .leading)
                          GeometryReader { geo in
                              RoundedRectangle(cornerRadius: 4)
                                  .fill(AppColors.accent)
                                  .frame(width: geo.size.width * (item.avg / maxAvg))
                                  .frame(height: 12)
                          }
                          .frame(height: 12)
                          Text(String(format: "%.1f", item.avg))
                              .font(.caption.monospacedDigit())
                              .foregroundStyle(AppColors.textSecondary)
                              .frame(width: 28, alignment: .trailing)
                      }
                  }
              }
          }
          .padding()
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }

      // MARK: - Category Distribution

      private var categoryCounts: [(category: String, count: Int, pct: Double)] {
          var counts: [String: Int] = [:]
          for note in notes { counts[note.category, default: 0] += 1 }
          let total = Double(notes.count)
          return counts
              .map { (category: $0.key, count: $0.value, pct: Double($0.value) / total * 100) }
              .sorted { $0.count > $1.count }
      }

      private var categoryDistribution: some View {
          VStack(alignment: .leading, spacing: 12) {
              Text("카테고리 분포")
                  .font(.headline)
                  .foregroundStyle(AppColors.accent)
              FlowLayout(spacing: 8) {
                  ForEach(categoryCounts, id: \.category) { item in
                      Text("\(item.category) \(Int(item.pct.rounded()))%")
                          .font(.caption)
                          .padding(.horizontal, 10)
                          .padding(.vertical, 5)
                          .background(AppColors.tagBackground)
                          .foregroundStyle(AppColors.accent)
                          .clipShape(Capsule())
                  }
              }
          }
          .padding()
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }

      // MARK: - Rating Distribution

      private var ratingBuckets: [(label: String, count: Int)] {
          let buckets: [Double] = stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }
          return buckets.compactMap { value in
              let count = notes.filter { $0.rating == value }.count
              return count > 0 ? (label: String(format: "%.1f", value), count: count) : nil
          }
      }

      private var ratingDistribution: some View {
          VStack(alignment: .leading, spacing: 12) {
              Text("별점 분포")
                  .font(.headline)
                  .foregroundStyle(AppColors.accent)
              if ratingBuckets.isEmpty {
                  Text("별점 데이터가 없어요.")
                      .font(.subheadline)
                      .foregroundStyle(AppColors.textSecondary)
              } else {
                  let maxCount = ratingBuckets.map { $0.count }.max() ?? 1
                  HStack(alignment: .bottom, spacing: 6) {
                      ForEach(ratingBuckets, id: \.label) { bucket in
                          VStack(spacing: 4) {
                              Text("\(bucket.count)")
                                  .font(.caption2)
                                  .foregroundStyle(AppColors.textSecondary)
                              RoundedRectangle(cornerRadius: 4)
                                  .fill(AppColors.accent)
                                  .frame(height: CGFloat(bucket.count) / CGFloat(maxCount) * 60)
                              Text(bucket.label)
                                  .font(.caption2)
                                  .foregroundStyle(AppColors.textSecondary)
                          }
                          .frame(maxWidth: .infinity)
                      }
                  }
              }
          }
          .padding()
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
  }

  // 간단한 FlowLayout (태그 줄바꿈용)
  struct FlowLayout: Layout {
      var spacing: CGFloat = 8
      func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
          let width = proposal.width ?? 0
          var x: CGFloat = 0; var y: CGFloat = 0; var rowH: CGFloat = 0
          for v in subviews {
              let s = v.sizeThatFits(.unspecified)
              if x + s.width > width && x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
              rowH = max(rowH, s.height); x += s.width + spacing
          }
          return CGSize(width: width, height: y + rowH)
      }
      func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
          var x = bounds.minX; var y = bounds.minY; var rowH: CGFloat = 0
          for v in subviews {
              let s = v.sizeThatFits(.unspecified)
              if x + s.width > bounds.maxX && x > bounds.minX { y += rowH + spacing; x = bounds.minX; rowH = 0 }
              v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
              rowH = max(rowH, s.height); x += s.width + spacing
          }
      }
  }
  ```

- [ ] **Step 4: 빌드 확인 (Cmd+B)**

- [ ] **Step 5: 커밋**

  ```bash
  git add -A
  git commit -m "feat: StatsView - 향 TOP5, 카테고리 분포, 별점 분포"
  ```

---

## Task 15: HomeView

**Files:**
- Create: `whiskey note/Views/Home/HomeView.swift`

- [ ] **Step 1: HomeView.swift 구현**

  ```swift
  import SwiftUI
  import SwiftData

  struct HomeView: View {
      @Environment(\.modelContext) private var modelContext
      @Query(sort: \WhiskeyNote.createdAt, order: .reverse) private var notes: [WhiskeyNote]
      @State private var showWizard = false

      private var recentNotes: [WhiskeyNote] { Array(notes.prefix(5)) }

      private var averageRating: String {
          let rated = notes.filter { $0.rating > 0 }
          guard !rated.isEmpty else { return "-" }
          let avg = rated.map { $0.rating }.reduce(0, +) / Double(rated.count)
          return String(format: "%.1f", avg)
      }

      private var topAromaName: String {
          var sums: [String: Int] = [:]
          for note in notes {
              for fi in note.flavorIntensities where fi.flavorType == FlavorType.aroma.rawValue {
                  sums[fi.name, default: 0] += fi.intensity
              }
          }
          guard !sums.isEmpty else { return "-" }
          let sorted = sums.sorted { lhs, rhs in
              if lhs.value != rhs.value { return lhs.value > rhs.value }
              let li = FlavorConstants.all.firstIndex { $0.name == lhs.key } ?? 999
              let ri = FlavorConstants.all.firstIndex { $0.name == rhs.key } ?? 999
              return li < ri
          }
          let name = sorted.first!.key
          let emoji = FlavorConstants.all.first { $0.name == name }?.emoji ?? ""
          return "\(emoji) \(name)"
      }

      var body: some View {
          NavigationStack {
              ZStack(alignment: .bottomTrailing) {
                  Group {
                      if notes.isEmpty {
                          ContentUnavailableView(
                              "아직 기록이 없어요.",
                              systemImage: "wineglass",
                              description: Text("아래 + 버튼으로 첫 노트를 추가해보세요!")
                          )
                      } else {
                          ScrollView {
                              VStack(spacing: 16) {
                                  profileCard
                                  recentSection
                              }
                              .padding()
                          }
                      }
                  }
                  .background(AppColors.background.ignoresSafeArea())

                  // FAB
                  Button { showWizard = true } label: {
                      Image(systemName: "plus")
                          .font(.title2.bold())
                          .foregroundStyle(.white)
                          .frame(width: 56, height: 56)
                          .background(AppColors.accent)
                          .clipShape(Circle())
                          .shadow(radius: 4, y: 2)
                  }
                  .padding(20)
              }
              .navigationTitle("위스키 노트")
              .fullScreenCover(isPresented: $showWizard) { NoteWizardView() }
          }
      }

      private var profileCard: some View {
          HStack(spacing: 0) {
              statCell(label: "기록", value: "\(notes.count)개")
              Divider().frame(height: 40)
              statCell(label: "평균 별점", value: averageRating)
              Divider().frame(height: 40)
              statCell(label: "대표 향", value: topAromaName)
          }
          .padding()
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
      }

      private func statCell(label: String, value: String) -> some View {
          VStack(spacing: 4) {
              Text(value).font(.headline).foregroundStyle(AppColors.textPrimary)
              Text(label).font(.caption).foregroundStyle(AppColors.textSecondary)
          }
          .frame(maxWidth: .infinity)
      }

      private var recentSection: some View {
          VStack(alignment: .leading, spacing: 8) {
              Text("최근 기록")
                  .font(.headline)
                  .foregroundStyle(AppColors.accent)

              ForEach(recentNotes) { note in
                  NavigationLink(value: note) {
                      HStack {
                          VStack(alignment: .leading, spacing: 2) {
                              Text(note.name).font(.subheadline.bold()).foregroundStyle(AppColors.textPrimary)
                              StarRatingView(rating: .constant(note.rating), isEditable: false, starSize: 12)
                          }
                          Spacer()
                          Text(note.createdAt, format: .dateTime.month().day())
                              .font(.caption)
                              .foregroundStyle(AppColors.textSecondary)
                      }
                      .padding(.vertical, 8)
                  }
                  .buttonStyle(.plain)
                  Divider()
              }
          }
          .padding()
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
          .navigationDestination(for: WhiskeyNote.self) { note in
              NoteDetailView(note: note)
          }
      }
  }
  ```

- [ ] **Step 2: 빌드 확인 (Cmd+B)**

- [ ] **Step 3: 커밋**

  ```bash
  git add -A
  git commit -m "feat: HomeView - 프로필 요약 카드 + 최근 기록"
  ```

---

## Task 16: ContentView (TabView 루트) & 최종 통합

**Files:**
- Modify: `whiskey note/ContentView.swift`

- [ ] **Step 1: ContentView.swift를 TabView로 교체**

  ```swift
  import SwiftUI

  struct ContentView: View {
      var body: some View {
          TabView {
              HomeView()
                  .tabItem { Label("홈", systemImage: "house.fill") }

              NoteListView()
                  .tabItem { Label("노트", systemImage: "note.text") }

              StatsView()
                  .tabItem { Label("통계", systemImage: "chart.bar.fill") }
          }
          .tint(AppColors.accent)
      }
  }
  ```

- [ ] **Step 2: 전체 빌드 확인 (Cmd+B) — 에러 없이 통과**

- [ ] **Step 3: 시뮬레이터에서 실행 (Cmd+R) — 동작 확인**

  확인 항목:
  - 3탭 (홈/노트/통계) 전환 동작
  - + FAB → 위자드 4단계 흐름
  - 노트 저장 후 홈/노트 탭에 반영
  - 노트 상세 → 수정 → 저장
  - 노트 삭제

- [ ] **Step 4: 전체 테스트 실행 (Cmd+U) — PASS 확인**

- [ ] **Step 5: 최종 커밋**

  ```bash
  git add -A
  git commit -m "feat: ContentView TabView 통합 - 앱 리뉴얼 완료"
  ```
