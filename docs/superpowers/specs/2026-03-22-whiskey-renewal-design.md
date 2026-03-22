# Whiskey Note 앱 리뉴얼 설계 문서

**날짜:** 2026-03-22
**상태:** 승인됨

---

## 개요

기존 Whiskey Note 앱을 완전히 새로 작성한다. 현재 앱은 토글 스위치 기반의 불편한 입력 UX, CreateView/UpdateView 코드 중복, 제한된 데이터 모델(이름·종류·향·맛·질감·마무리·안주만 기록)이라는 문제를 갖고 있다. 이번 리뉴얼에서는 슬라이더 기반 강도 입력, 3탭 네비게이션, 4단계 위자드 작성 흐름, 확장된 데이터 필드를 갖춘 앱으로 완전히 재설계한다.

**최소 배포 대상:** iOS 17.0+

---

## 디자인 방향

**클린 라이트 (Clean Light)**

- 배경: 크림색 (`#faf8f5`)
- 포인트 컬러: 브라운 (`#9b6a2f`)
- 선택 태그 배경: 연한 베이지 (`#f0e8d8`)
- 텍스트: 진한 차콜 (`#2d2d2d`), 보조 텍스트 그레이 (`#888`)
- 별점 컬러: 앰버 (`#e8a838`)
- 폰트: 시스템 폰트 (SF Pro)

---

## 데이터 모델

### 열거형 (Enums)

```swift
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
```

### WhiskeyNote (@Model)

```swift
@Model final class WhiskeyNote {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String                    // 필수, 비어있으면 저장 불가
    var category: String                // WhiskeyCategory.rawValue
    var age: Int?                       // 숙성 연수
    var abv: Double?                    // 도수 (0.0~99.9%)
    var price: Int?                     // 가격 (원)
    var rating: Double = 0.0            // 별점 (0.0~5.0, 0.5 단위)
    var photoData: Data?                // JPEG 압축 저장 (최대 800px, quality 0.8)
    var memo: String = ""               // 자유 메모 (빈 문자열 허용)
    var dish: String = ""               // 안주 (빈 문자열 허용)
    var createdAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \FlavorIntensity.note)
    var flavorIntensities: [FlavorIntensity] = []
}
```

### FlavorIntensity (@Model)

```swift
@Model final class FlavorIntensity {
    @Attribute(.unique) var id: UUID = UUID()
    var flavorType: String              // FlavorType.rawValue
    var name: String                    // 향/맛 이름 (예: "피트")
    var intensity: Int = 0             // 0~5 (0 = 선택 안 함)
    var note: WhiskeyNote?             // 역관계 (optional, SwiftData 요구사항)
}
```

### FlavorConstants (향/맛 목록 및 이모지)

```swift
struct FlavorItem {
    let name: String
    let emoji: String
    let type: FlavorType
}

// FlavorConstants.all 에서 전체 목록 제공
```

| 타입 | 이름 | 이모지 |
|------|------|--------|
| aroma | 과일 | 🍎 |
| aroma | 꽃 | 🌸 |
| aroma | 곡물 | 🌾 |
| aroma | 견과류 | 🌰 |
| aroma | 스파이시 | 🌶️ |
| aroma | 우디 | 🪵 |
| aroma | 피트 | 🔥 |
| aroma | 와인 | 🍷 |
| aroma | 페인티 | 🍯 |
| taste | 단맛 | 🍬 |
| taste | 짠맛 | 🧂 |
| taste | 신맛 | 🍋 |
| taste | 쓴맛 | ☕ |
| taste | 감칠맛 | 🫒 |
| mouthfeel | 가벼움 | 🪶 |
| mouthfeel | 중간 | ⚖️ |
| mouthfeel | 무거움 | 🏋️ |
| mouthfeel | 부드러움 | 🧈 |
| mouthfeel | 거침 | 🪨 |
| mouthfeel | 오일 | 💧 |
| mouthfeel | 드라이 | 🏜️ |
| finish | 짧은 | ⚡ |
| finish | 중간 | ⏳ |
| finish | 긴 | 🌊 |
| finish | 따뜻한 | 🔆 |
| finish | 스파이시 | 🌶️ |
| finish | 드라이 | 🏜️ |

---

## 화면 구조

### 탭바 (3탭)

```
[ 🏠 홈 ]  [ 📋 노트 ]  [ 📊 통계 ]
```

---

### 홈 탭 (HomeView)

**기록이 없을 때 (빈 상태):**
"아직 기록이 없어요. 아래 + 버튼으로 첫 노트를 추가해보세요!" 안내 메시지를 화면 중앙에 표시.

**기록이 있을 때:**

- **프로필 요약 카드**
  - 총 기록 수
  - 평균 별점 (rating > 0인 노트만 포함, 없으면 "-")
  - 대표 향: `flavorType == "aroma"`인 FlavorIntensity 중 전체 노트에 걸쳐 `intensity` 합산이 가장 높은 단일 항목 이름. 동점이면 FlavorConstants 정의 순서 우선. 기록이 없으면 "-"

- **최근 기록 목록** (createdAt 내림차순, 최대 5개)
  - 각 행: 위스키 이름 + 별점 (왼쪽) / 기록 날짜 "M월 d일" 형식 (오른쪽)
  - 탭 시 NoteDetailView로 이동 (NavigationStack push)

- **+ FAB 버튼** (우하단, Circle) → `NoteWizardView`를 `.fullScreenCover`로 표시

---

### 노트 탭 (NoteListView)

**빈 상태:** "아직 기록이 없어요." 텍스트를 화면 중앙에 표시.

- **검색바**: `name` 필드를 대소문자 무시(case-insensitive), 부분 일치로 실시간 필터
- **카드 리스트** (createdAt 내림차순, `.onDelete`로 스와이프 삭제)
  - 카드 내용: 이름, 종류·도수·숙성연수, 별점, intensity ≥ 1인 aroma 태그 (intensity 높은 순 최대 3개, 동점이면 FlavorConstants 정의 순서)
  - 탭 시 NoteDetailView로 이동
- **+ 버튼** (네비게이션 바 우측) → `NoteWizardView`를 `.fullScreenCover`로 표시

---

### 통계 탭 (StatsView)

**빈 상태:** "기록이 쌓이면 통계가 표시됩니다." 텍스트를 화면 중앙에 표시.

- **선호 향 TOP 5** (가로 막대 차트)
  - 대상: `flavorType == "aroma"` 항목 9가지
  - 값: 각 향에 대해 intensity > 0인 노트만 포함하여 intensity 평균 계산
  - 상위 5개를 내림차순으로 표시
- **카테고리 분포**: 종류(category)별 기록 수 비율 (%)
- **별점 분포**: rating 0.5 단위 히스토그램

---

### 노트 상세 (NoteDetailView)

- 사진 (photoData가 있으면 상단 전체 너비로 표시, 없으면 섹션 미표시)
- 기본 정보: 이름, 종류, 도수 (없으면 "-"), 숙성연수 (없으면 "-"), 가격 (없으면 "-", 있으면 "45,000원" 형식으로 천 단위 콤마)
- 별점 (StarRatingView 읽기 전용)
- 기록 날짜: "yyyy.MM.dd" 형식
- **향·맛·질감·마무리** 강도 (4개 섹션 헤더로 구분, intensity == 0인 항목은 섹션 내에서 숨김, 해당 섹션 내 모든 항목이 0이면 섹션 전체 숨김)
- 메모 (빈 문자열이면 섹션 미표시)
- 안주 (빈 문자열이면 섹션 미표시)
- **수정 버튼** → `NoteWizardView`를 기존 값 pre-fill한 채로 `.fullScreenCover`로 표시
- **삭제 버튼** → "정말 삭제할까요?" Alert → 확인 시 modelContext.delete 후 dismiss

---

### 노트 작성/수정 위자드 (NoteWizardView)

단일 `NoteWizardView`가 생성(새 WhiskeyNote 삽입)과 수정(기존 값 변경)을 모두 처리한다.

**수정 모드 FlavorIntensity 초기화:**
기존 `WhiskeyNote`를 로드할 때, FlavorConstants에 정의된 27개 항목 전체를 기준으로 위자드 로컬 State를 초기화한다. 기존 `flavorIntensities` 배열에 해당 항목이 존재하면 그 intensity 값을 사용하고, 없으면 0으로 초기화한다. 저장 시에는 intensity > 0인 항목만 `FlavorIntensity` 객체로 생성/업데이트하고, 나머지는 삭제한다.

**진행 표시줄**: 상단 4칸 프로그레스 바 (현재 단계 채워짐)

**네비게이션 버튼:**
- 이전 단계: "이전" 버튼 (1단계에서는 "취소" 버튼, 탭 시 dismiss)
- 다음 단계: "다음" 버튼 (4단계에서는 "저장" 버튼)

**취소/뒤로가기 Alert 조건:**
- **새로 만들기 모드**: 아래 조건 중 하나라도 해당하면 Alert 표시
  - name이 비어있지 않음
  - photoData가 선택됨
  - abv, age, price 중 하나라도 입력됨
  - 임의 FlavorIntensity의 intensity > 0
  - memo 또는 dish가 비어있지 않음
  - (기본 선택된 카테고리 변경 여부는 체크하지 않음 — 기본값과 동일해도 Alert 미표시)
- **수정 모드**: 현재 값이 초기 로드 값과 하나라도 다른 경우
- 조건 해당 시: "저장하지 않고 나가시겠어요?" Alert → "나가기" / "계속 작성"

#### 1단계 — 사진 & 기본 정보

- 사진 추가 버튼 (`PhotosPicker`, 선택 사항) → 선택 시 800px 이하로 리사이즈, JPEG quality 0.8으로 압축하여 State에 임시 저장
- 위스키 이름 (TextField, **필수** — 비어있으면 "다음" 비활성화)
- 종류 (Picker: WhiskeyCategory 전체 케이스)
- 도수 % (TextField, `.keyboardType(.decimalPad)`, 0.0~99.9 범위, 범위 초과 시 저장 시점에 무시하고 nil 처리 — 인라인 에러 메시지 없이 조용히 처리하는 것이 의도된 동작)
- 숙성 연수 (TextField, `.keyboardType(.numberPad)`)
- 가격 원 (TextField, `.keyboardType(.numberPad)`)

#### 2단계 — 향 (Aroma)

- `flavorType == .aroma` 항목 9가지를 FlavorConstants 순서로 나열
- 각 행: `FlavorSliderRow` (이모지 + 이름 / 0~5 Slider / 현재 값 표시, 0이면 "–")

#### 3단계 — 맛·질감·마무리

- 맛(5), 질감(7), 마무리(6) — 섹션 헤더(향/맛/질감/마무리 한글 레이블)로 구분
- 각 행: `FlavorSliderRow` (동일 컴포넌트)

#### 4단계 — 총평

- 별점 (`StarRatingView`: 별 5개, 각 별의 왼쪽 반 탭 = 0.5, 오른쪽 반 탭 = 1.0 단위 누적 선택)
- 메모 (`TextEditor`, 여러 줄, placeholder "자유롭게 기록해보세요")
- 안주 (TextField, placeholder "같이 먹은 안주")
- **저장 버튼**: name 비어있으면 비활성화. 탭 시 modelContext.insert(또는 기존 객체 수정) → dismiss

---

## 아키텍처

- **SwiftUI + SwiftData** (iOS 17.0+)
- **PhotosUI**: `PhotosPicker`로 사진 선택
- **단일 ModelContainer**: `WhiskeyNote`, `FlavorIntensity`
- **파일 구조**:

```
whiskey note/
├── Models/
│   ├── WhiskeyNote.swift
│   └── FlavorIntensity.swift
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── NoteList/
│   │   ├── NoteListView.swift
│   │   └── NoteCardView.swift
│   ├── Stats/
│   │   └── StatsView.swift
│   ├── Detail/
│   │   └── NoteDetailView.swift
│   ├── Wizard/
│   │   ├── NoteWizardView.swift
│   │   ├── WizardStep1View.swift
│   │   ├── WizardStep2View.swift
│   │   ├── WizardStep3View.swift
│   │   └── WizardStep4View.swift
│   └── Components/
│       ├── StarRatingView.swift       // 0.5 단위 별점 입력/표시
│       ├── FlavorSliderRow.swift      // 이모지+이름 + 슬라이더 + 값
│       └── LaunchView.swift
├── Constants/
│   └── FlavorConstants.swift          // FlavorItem 배열 전체 정의
└── whiskey_noteApp.swift
```

---

## 범위 제외 (향후 작업)

- AI 사진 자동입력 (Claude Vision API + 백엔드 서버 + 인앱결제)
- iCloud 동기화
- 소셜/공유 기능
- 위스키 검색 데이터베이스 연동

---

## 성공 기준

1. 기존 앱 대비 노트 작성 흐름이 위자드로 집중도 향상
2. 향/맛 강도를 슬라이더로 직관적으로 기록 가능
3. 통계 화면에서 본인의 취향 패턴을 한눈에 파악 가능
4. 단일 `NoteWizardView`로 생성/수정 처리 — 코드 중복 없음
