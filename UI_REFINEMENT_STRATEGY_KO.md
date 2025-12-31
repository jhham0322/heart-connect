# UI 자산(Asset) 개선 전략

이 문서는 이미지 자산의 불필요한 투명 여백으로 인해 발생하는 UI 레이아웃 문제를 해결하기 위해 사용된 전략을 설명합니다.

## 문제점 (The Problem)
AI로 생성된 이미지 자산은 종종 눈에 보이지 않는 넓은 투명 여백을 포함하고 있습니다. Flutter에서 이러한 이미지를 사용할 때, 이 여백은 실제 공간을 차지하므로 버튼이나 아이콘이 작게 보이거나, 의도한 위치에서 밀려나고 정렬이 어긋나는 문제가 발생합니다.

## 전략 A: "그린 스크린" 기법 (크로마키 & 트림)
이 방법은 복잡한 질감이나 특유의 예술적 느낌이 있어 벡터 아이콘으로 대체하기 어려운 이미지(예: 종이 질감 카드 배경, 특수 버튼 등)에 가장 적합합니다.

### 1. 생성 (Generation)
AI에게 투명 배경을 요청하는 대신(완벽하게 투명하지 않을 때가 많음), **완벽한 밝은 녹색(`#00FF00`)** 배경으로 이미지를 생성하도록 요청합니다.
*   **프롬프트 예시:** "Extract the card background. Set background to SOLID BRIGHT GREEN (#00FF00). No shadows."

### 2. 가공 (Processing)
커스텀 파이썬 스크립트(`process_green_images.py`)를 사용하여 이 원본 이미지를 처리합니다.
*   **기능:**
    1.  `#00FF00` 색상의 픽셀을 찾아 완전 투명(Transparent)으로 변환합니다.
    2.  **자동 트림(Auto-Trim):** 실제 콘텐츠가 있는 영역의 경계박스(Bounding Box)를 감지하여, 불필요한 여백을 자동으로 잘라(Crop)냅니다.
*   **명령어:**
    ```powershell
    python process_green_images.py "path/to/green_asset.png"
    ```

### 3. 적용 (Integration)
처리가 완료되어 여백이 제거된 깔끔한 이미지를 `assets/` 경로에 복사하여 기존의 문제 있는 이미지를 덮어씁니다.

---

## 전략 B: 벡터 아이콘 교체 (Vector Icon Replacement)
이 방법은 단순한 UI 요소(아이콘, 내비게이션 탭, 단순한 원형 버튼 등)에 가장 적합하며, 안정성과 품질 측면에서 권장되는 방법입니다.

### 1. 식별 (Identification)
단순한 기호나 상징(예: 하트, 펜, 집 모양 아이콘 등)으로 대체 가능한 자산을 식별합니다.

### 2. 리팩토링 (Refactoring)
Flutter 코드 내의 `Image.asset(...)` 위젯을 네이티브 `Icon(...)` 또는 `FaIcon(...)` (FontAwesome) 위젯으로 교체합니다.
*   **장점:**
    *   **여백 없음 (Zero Padding):** 아이콘이 지정된 프레임 안에 정확히 꽉 차게 렌더링됩니다.
    *   **확장성 (Scalability):** 크기를 조절해도 이미지가 깨지지 않습니다.
    *   **테마 적용 (Theming):** 코드를 통해 색상을 동적으로 변경할 수 있습니다 (`AppTheme.primaryColor` 등).

### 3. 변경 예시
**변경 전 (여백 문제가 있는 이미지):**
```dart
SafeImage(
  assetPath: $assets.heartIcon,
  width: 24, height: 24,
)
```

**변경 후 (깔끔한 벡터 아이콘):**
```dart
Icon(
  FontAwesomeIcons.heart,
  color: AppTheme.accentCoral,
  size: 24,
)
```

## 요약
복잡한 이미지는 **그린 스크린 스크립트**로 여백을 제거하고, 단순 심볼은 **벡터 아이콘**으로 교체하는 두 가지 전략을 병행하여, 보이지 않는 이미지 경계로 인한 레이아웃 틀어짐 없이 픽셀 단위로 정확한 디자인을 구현합니다.
