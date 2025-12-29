# 수익화 구현 가이드: 보상형 광고 및 인앱 결제

이 문서는 앱의 수익화를 위해 **보상형 광고(Rewarded Ads)**와 **인앱 결제(In-App Purchase)**를 설정하고 구현하는 방법을 설명합니다.

---

## 🏗️ 1. 보상형 광고 (Google AdMob)

사용자가 동영상 광고를 끝까지 시청하면 보상(예: 프리미엄 이미지 팩 잠금 해제)을 제공하는 방식입니다. 현재 앱 코드는 이 기능을 이미 지원하도록 구현되어 있습니다.

### 1단계: AdMob 설정
1. [Google AdMob](https://admob.google.com/)에 접속하여 로그인합니다.
2. **앱 > 앱 추가**를 클릭하여 앱을 등록합니다. (플레이 스토어 등록 전이라면 '플레이 스토어에 등록되지 않음' 선택)
3. **광고 단위 > 광고 단위 추가**를 클릭합니다.
4. **보상형(Rewarded)** 형식을 선택합니다.
5. 광고 단위 이름을 입력합니다 (예: `Gallery_Unlock_Reward`).
6. **보상 설정**:
   - 보상 수량: `1`
   - 보상 항목: `Unlock` (또는 원하는 이름)
   - *팁: 서버 측 인증(SSV)은 필수가 아니며, 현재 앱은 로컬 콜백으로 처리합니다.*
7. 생성된 **광고 단위 ID** (예: `ca-app-pub-xxxxxxxxxxxxxxxx/vvvvvvvvvv`)를 복사합니다.

### 2단계: 코드에 ID 적용
현재 `lib/src/utils/ad_helper.dart` 파일에는 테스트용 ID가 설정되어 있습니다. 실제 출시를 위해서는 이 ID를 교체해야 합니다.

1. `lib/src/utils/ad_helper.dart` 파일을 엽니다.
2. `rewardedAdUnitId` getter를 찾아 실제 ID로 변경합니다.

```dart
// lib/src/utils/ad_helper.dart

String get rewardedAdUnitId {
  if (kReleaseMode) {
    // TODO: 여기에 실제 AdMob 광고 단위 ID를 입력하세요.
    return 'ca-app-pub-xxxxxxxxxxxxxxxx/vvvvvvvvvv'; 
  } else {
    // 테스트용 ID (변경하지 마세요)
    return 'ca-app-pub-3940256099942544/5224354917';
  }
}
```

### 3단계: 테스트 및 배포
- **개발 중**: 반드시 **테스트 ID**를 사용해야 합니다. 실제 광고를 클릭하거나 자주 시청하면 계정이 정지될 수 있습니다.
- **배포 전**: `kReleaseMode` 분기 안에 실제 ID를 넣고, AdMob 콘솔에서 앱을 스토어와 연결합니다.

---

## 🛒 2. 인앱 결제 (In-App Purchase)

사용자가 금액을 지불하고 영구적으로 프리미엄 기능을 구매하는 방식입니다. (예: "모든 이미지 잠금 해제 팩 - 3,000원")

> **참고**: 현재 프로젝트에는 인앱 결제 코드가 포함되어 있지 않습니다. 구현하려면 다음 단계를 따르세요.

### 1단계: 패키지 추가
터미널에서 다음 명령어를 실행하여 플러그인을 추가합니다.
```bash
flutter pub add in_app_purchase
```

### 2단계: Google Play Console 설정
1. [Google Play Console](https://play.google.com/console)에 로그인합니다.
2. 앱을 선택하고 왼쪽 메뉴의 **수익 창출(Monetize) > 제품(Products) > 인앱 상품(In-app products)**으로 이동합니다.
3. **상품 만들기(Create product)**를 클릭합니다.
4. **제품 ID(Product ID)**를 입력합니다. (예: `premium_image_pack_2026`)
   - *이 ID는 코드에서 제품을 식별하는 데 사용됩니다.*
5. 제품 세부 정보(이름, 설명)와 **가격**을 설정하고 **저장** 및 **활성화**합니다.

### 3단계: 코드 구현 구현 (예시)
`InAppPurchaseService` 같은 클래스를 만들어 결제 로직을 처리합니다.

**구현 1: 상품 목록 로드** (예제 코드)
```dart
final Set<String> _kIds = {'premium_image_pack_2026'};
final ProductDetailsResponse response = 
    await InAppPurchase.instance.queryProductDetails(_kIds);

if (response.notFoundIDs.isNotEmpty) {
    // 상품 ID 오류 처리
}

List<ProductDetails> products = response.productDetails;
```

**구현 2: 구매 요청 (UI 버튼 연결)**
```dart
final PurchaseParam purchaseParam = PurchaseParam(productDetails: products[0]);
InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
```

**구현 3: 구매 결과 처리 (Stream 리스너)**
앱 시작 시 리스너를 등록해야 합니다.
```dart
// main.dart 또는 초기화 로직
final Stream<List<PurchaseDetails>> purchaseUpdated =
    InAppPurchase.instance.purchaseStream;
    
_subscription = purchaseUpdated.listen((purchaseDetailsList) {
  _listenToPurchaseUpdated(purchaseDetailsList);
}, onDone: () {
  _subscription.cancel();
}, onError: (error) {
  // 오류 처리
});

void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  for (var purchaseDetails in purchaseDetailsList) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // 결제 대기 중 UI 표시
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        // 오류 처리
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        
        // ★ 여기서 프리미엄 기능 해제 로직 실행 (UnlockProvider 호출 등)
        deliverProduct(purchaseDetails);
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }
}
```

### 4단계: 테스트
- 실제 결제를 테스트하려면 **라이선스 테스터** 계정이 필요합니다.
- Play Console 설정 > 라이선스 테스트에서 테스터 이메일을 등록하면, 실제 과금 없이 테스트 결제가 가능합니다.

---

## 🎯 추천 전략

현재 구현된 **보상형 광고** 모델을 먼저 출시하여 사용자 반응을 살피는 것을 추천합니다. 

1. **보상형 광고**: 사용자의 금전적 부담이 없어 접근성이 좋음.
2. **추후 업데이트**: 사용자가 많아지면 "광고 제거" 또는 "모든 팩 영구 구매" 기능을 인앱 결제로 추가하여 수익 모델을 다각화합니다.
