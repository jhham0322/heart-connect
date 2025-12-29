import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// AdMob 광고 관리 헬퍼 클래스
class AdHelper {
  // 싱글톤 패턴
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  // 초기화 상태
  bool _isInitialized = false;
  
  // Interstitial Ad 인스턴스
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Rewarded Ad 인스턴스
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  /// AdMob SDK 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('[AdHelper] MobileAds SDK initialized');
    
    // 전면 광고 미리 로드
    loadInterstitialAd();
    // 보상형 광고 미리 로드
    loadRewardedAd();
  }

  /// 배너 광고 ID
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // kReleaseMode: 앱이 릴리즈(배포) 모드로 빌드되었는지 확인
      if (kReleaseMode) {
        return 'ca-app-pub-0898435964439351/2052163203'; // 실제 배너 ID
      } else {
        return 'ca-app-pub-3940256099942544/6300978111'; // 테스트 ID
      }
    } else if (Platform.isIOS) {
      // iOS Test Banner ID (실제 ID가 없으므로 테스트 ID 유지)
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 전면 광고 ID
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-0898435964439351/7684420372'; // 실제 전면 ID
      } else {
        return 'ca-app-pub-3940256099942544/1033173712'; // 테스트 ID
      }
    } else if (Platform.isIOS) {
      // iOS Test Interstitial ID
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 보상형 광고 ID
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        // TODO: 실제 Rewarded Ad ID로 교체 필요
        return 'ca-app-pub-0898435964439351/1234567890'; // 임시 ID
      } else {
        return 'ca-app-pub-3940256099942544/5224354917'; // 테스트 ID
      }
    } else if (Platform.isIOS) {
      // iOS Test Rewarded ID
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 전면 광고 로드
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('[AdHelper] Interstitial ad loaded');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('[AdHelper] Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              // 다음 광고 미리 로드
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdHelper] Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdHelper] Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// 보상형 광고 로드
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('[AdHelper] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdHelper] Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// 전면 광고 표시
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      debugPrint('[AdHelper] Interstitial ad not ready');
      return false;
    }
    
    await _interstitialAd!.show();
    return true;
  }

  /// 보상형 광고 표시
  /// [onRewarded] 콜백은 사용자가 광고를 끝까지 시청했을 때 호출됩니다.
  Future<bool> showRewardedAd({required Function() onRewarded}) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('[AdHelper] Rewarded ad not ready');
      return false;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdHelper] Rewarded ad dismissed');
        ad.dispose();
        _isRewardedAdReady = false;
        // 다음 광고 미리 로드
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdHelper] Rewarded ad failed to show: $error');
        ad.dispose();
        _isRewardedAdReady = false;
        loadRewardedAd();
      },
    );
    
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdHelper] User earned reward: ${reward.amount} ${reward.type}');
        onRewarded();
      },
    );
    return true;
  }

  /// 전면 광고 준비 상태
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// 보상형 광고 준비 상태
  bool get isRewardedAdReady => _isRewardedAdReady;

  /// 리소스 해제
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}
