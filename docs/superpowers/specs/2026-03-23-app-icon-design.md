# App Icon Design Spec
Date: 2026-03-23

## 결정된 디자인: T-2 (딥 브라운 + 크림 라인 글렌케언)

### 컨셉
미니멀하고 감각적인 위스키 앱 아이콘. 복잡한 요소 없이 글렌케언 글라스의 실루엣과 앱 컬러 팔레트만으로 표현.

### 색상
| 요소 | 색상 | 값 |
|------|------|-----|
| 아이콘 배경 | 딥 웜 브라운 | `#2d1e0a` |
| 글라스 아웃라인 | 크림 (앱 배경색) | `#faf8f5`, opacity 75% |
| 액체 (위스키) | 골드 앰버 (앱 star 색) | `#e8a838`, opacity 90% |
| 액체 표면 라인 | 크림 | `#faf8f5`, opacity 45% |

### 글라스 형태
- **종류**: 글렌케언(Glencairn) — 위스키 테이스팅 전용 잔
- **특징**: 넓은 입구(림) → 더 넓은 볼 → 짧은 스템 → 평평한 베이스
- **액체 레벨**: 볼의 하단 약 55% 채움 (72px 기준: y=38 지점)
- **스타일**: 아웃라인만, 내부 fill 없음 (투명 유리 표현)
- **주의**: PNG 출력 시 corners는 iOS 시스템이 자동 마스킹 — 소스 SVG에 corner radius 적용 불필요

### SVG 마스터 소스 (72×72 캔버스 기준)

완전한 SVG 스니펫 (clipPath 포함):

```svg
<svg width="72" height="72" viewBox="0 0 72 72" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="glassClip">
      <path d="M20,8 C16,14 14,24 14,38 C14,48 22,54 30,55 L30,60 L22,60 L22,66 L50,66 L50,60 L42,60 L42,55 C50,54 58,48 58,38 C58,24 56,14 52,8 Z"/>
    </clipPath>
  </defs>

  <!-- 배경 -->
  <rect width="72" height="72" fill="#2d1e0a"/>

  <!-- 액체 (글라스 내부에만 클리핑) -->
  <rect x="0" y="38" width="72" height="30" fill="#e8a838" fill-opacity="0.9" clip-path="url(#glassClip)"/>

  <!-- 액체 표면 라인 -->
  <path d="M15,38 Q36,35 57,38" stroke="#faf8f5" stroke-width="1.2" stroke-opacity="0.45" fill="none" clip-path="url(#glassClip)"/>

  <!-- 글라스 아웃라인 (stroke-width는 72px 기준 1.8, 해상도별 비례 조정) -->
  <path d="M20,8 C16,14 14,24 14,38 C14,48 22,54 30,55 L30,60 L22,60 L22,66 L50,66 L50,60 L42,60 L42,55 C50,54 58,48 58,38 C58,24 56,14 52,8 Z"
        fill="none"
        stroke="#faf8f5"
        stroke-opacity="0.75"
        stroke-width="1.8"
        stroke-linejoin="round"/>
</svg>
```

**stroke-width 스케일 기준**: 72px 캔버스에서 1.8px → 1024px 캔버스로 변환 시 `1.8 × (1024/72) ≈ 25.6px`으로 비례 조정.

### 출력 파일 목록 (Contents.json 기준)

| 파일명 | 픽셀 크기 | 용도 |
|--------|----------|------|
| `1024.png` | 1024×1024 | App Store |
| `180.png` | 180×180 | iPhone 60pt @3x |
| `120.png` | 120×120 | iPhone 60pt @2x / 40pt @3x (공유) |
| `87.png` | 87×87 | iPhone 29pt @3x |
| `80.png` | 80×80 | iPhone 40pt @2x |
| `60.png` | 60×60 | iPhone 20pt @3x |
| `58.png` | 58×58 | iPhone 29pt @2x |
| `57.png` | 57×57 | iPhone 57pt @1x |
| `40.png` | 40×40 | iPhone 20pt @2x |
| `29.png` | 29×29 | iPhone 29pt @1x |
| `114.png` | 114×114 | iPhone 57pt @2x |

### 구현 방법

1024×1024 SVG를 마스터로 생성 후 각 해상도로 변환:

```bash
# rsvg-convert 사용 (brew install librsvg)
for size in 1024 180 120 87 80 60 58 57 40 29 114; do
  rsvg-convert -w $size -h $size icon-master.svg -o ${size}.png
done
```

또는 Figma / Sketch에서 SVG 임포트 후 각 해상도 Export.

### 레퍼런스
- 참조 앱: 위스키키 (id6692628905) — 미니멀 + 고대비 스타일
- 앱 컬러셋: `whiskey note/Constants/AppColors.swift`
- 기존 아이콘 위치: `whiskey note/Assets.xcassets/AppIcon.appiconset/`
