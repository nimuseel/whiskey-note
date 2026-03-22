# Whiskey Note 앱 리뉴얼 설계 문서

**날짜:** 2026-03-22
**상태:** 승인됨

---

## 개요

기존 Whiskey Note 앱을 완전히 새로 작성한다. 현재 앱은 토글 스위치 기반의 불편한 입력 UX, CreateView/UpdateView 코드 중복, 제한된 데이터 모델(이름·종류·향·맛·질감·마무리·안주만 기록)이라는 문제를 갖고 있다. 이번 리뉴얼에서는 슬라이더 기반 강도 입력, 3탭 네비게이션, 4단계 위자드 작성 흐름, 확장된 데이터 필드를 갖춘 앱으로 완전히 재설계한다.

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

### WhiskeyNote (@Model)

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | 고유 식별자 |
| `name` | String | 위스키 이름 |
| `category` | String | 종류 (Single Malt, Blended, Bourbon, Irish, Japanese, Other) |
| `age` | Int? | 숙성 연수 (없을 수 있음) |
| `abv` | Double? | 도수 (%) |
| `price` | Int? | 가격 (원) |
| `rating` | Double | 별점 (0.0~5.0, 0.5 단위) |
| `photoData` | Data? | 병/잔 사진 (로컬 저장) |
| `memo` | String | 자유 메모 |
| `dish` | String | 같이 먹은 안주 |
| `createdAt` | Date | 기록 날짜 |
| `flavorIntensities` | [FlavorIntensity] | 향·맛·질감·마무리 강도 (cascade) |

### FlavorIntensity (@Model)

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | 고유 식별자 |
| `flavorType` | String | 카테고리: `"aroma"` \| `"taste"` \| `"mouthfeel"` \| `"finish"` |
| `name` | String | 향/맛 이름 (예: "피트", "단맛") |
| `intensity` | Int | 강도 0~5 (0 = 선택 안 함) |
| `note` | WhiskeyNote | 역관계 |

### 향/맛 목록

**향 (Aroma, 9가지)**
과일, 꽃, 곡물, 견과류, 스파이시, 우디, 피트, 와인, 페인티

**맛 (Taste, 5가지)**
단맛, 짠맛, 신맛, 쓴맛, 감칠맛

**질감 (Mouthfeel, 7가지)**
가벼움, 중간, 무거움, 부드러움, 거침, 오일, 드라이

**마무리 (Finish, 6가지)**
짧은, 중간, 긴, 따뜻한, 스파이시, 드라이

---

## 화면 구조

### 탭바 (3탭)

```
[ 🏠 홈 ]  [ 📋 노트 ]  [ 📊 통계 ]
```

---

### 홈 탭 (HomeView)

- **프로필 요약 카드**
  - 총 기록 수
  - 평균 별점
  - 가장 많이 기록한 향 (최다 intensity 합산)
- **최근 기록 목록** (최대 5개, 내림차순)
  - 각 행: 위스키 이름 + 별점 (왼쪽) / 기록 날짜 (오른쪽)
  - 탭 시 노트 상세로 이동
- **+ FAB 버튼** (우하단) → 위자드 시작

---

### 노트 탭 (NoteListView)

- **검색바**: 이름으로 실시간 필터
- **카드 리스트** (내림차순, 스와이프 삭제 가능)
  - 카드 내용: 이름, 종류·도수·숙성연수, 별점, 강도 1 이상인 향 태그 (최대 3개)
- **+ 버튼** (네비게이션 바 우측) → 위자드 시작

---

### 통계 탭 (StatsView)

- **선호 향 TOP 5**: 향별 intensity 평균 기준 가로 막대 차트
- **카테고리 분포**: 종류별 기록 수 비율
- **별점 분포**: 0.5 단위 히스토그램
- 기록이 없으면 빈 상태 안내 메시지 표시

---

### 노트 상세 (NoteDetailView)

- 사진 (있으면 상단 전체 너비로 표시)
- 기본 정보: 이름, 종류, 도수, 숙성연수, 가격
- 별점 표시
- 향·맛·질감·마무리 강도 (읽기 전용 막대, intensity 0인 항목은 숨김)
- 메모
- 안주
- 기록 날짜
- 수정 버튼 → 위자드로 이동 (기존 값 pre-fill)
- 삭제 버튼 (확인 Alert)

---

### 노트 작성/수정 위자드 (NoteWizardView)

단일 `NoteWizardView`가 생성과 수정을 모두 처리한다. 수정 시 기존 값을 초기값으로 주입한다.

**진행 표시줄**: 상단에 4칸 프로그레스 바

#### 1단계 — 사진 & 기본 정보
- 사진 추가 버튼 (PhotosPicker, 선택 사항)
- 위스키 이름 (TextField, 필수)
- 종류 (Picker: Single Malt / Blended / Bourbon / Irish / Japanese / Other)
- 도수 % (TextField, 숫자, 선택)
- 숙성 연수 (TextField, 숫자, 선택)
- 가격 원 (TextField, 숫자, 선택)

#### 2단계 — 향 (Aroma)
- 9가지 항목 각각 0~5 슬라이더
- 슬라이더 왼쪽: 이름 + 이모지
- 슬라이더 오른쪽: 현재 값 숫자 표시
- 0이면 "선택 안 함" 표시

#### 3단계 — 맛·질감·마무리
- 맛 5가지 + 질감 7가지 + 마무리 6가지 슬라이더
- 섹션 헤더로 구분

#### 4단계 — 총평
- 별점 (탭으로 0.5 단위 선택, StarRatingView 커스텀 컴포넌트)
- 메모 (TextEditor, 여러 줄)
- 안주 (TextField)
- **저장 버튼**: 이름이 비어있으면 비활성화

**뒤로가기/취소**: 입력 내용이 있으면 "저장하지 않고 나가시겠어요?" Alert

---

## 아키텍처

- **SwiftUI + SwiftData** (iOS 17+)
- **PhotosUI**: 사진 선택 (PHPickerViewController)
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
│       ├── StarRatingView.swift
│       ├── FlavorSliderRow.swift
│       └── LaunchView.swift
├── Constants/
│   └── FlavorConstants.swift   // 향·맛·질감·마무리 목록 및 이모지
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

1. 기존 앱 대비 노트 작성 시간 단축 (위자드 흐름으로 집중도 향상)
2. 향/맛 강도를 직관적으로 기록 가능
3. 통계 화면에서 본인의 취향 패턴을 한눈에 파악 가능
4. CreateView/UpdateView 코드 중복 없이 단일 위자드로 처리
