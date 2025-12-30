import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'src/app.dart';
import 'src/utils/ad_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Release 빌드에서 모든 debugPrint 출력 비활성화
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  
  // Lock Portrait Mode (Mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Desktop Window Config
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(450, 850),
      center: true,
      title: 'Heart Connect',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      try {
        await windowManager.setIcon('assets/icons/app_icon.png');
      } catch (e) {
        debugPrint("Failed to set icon: $e");
      }
    });
  }
  
  // Initialize AdMob (Mobile only)
  if (Platform.isAndroid || Platform.isIOS) {
    await AdHelper().initialize();
  }
  
  // Release 빌드에서 모든 print 출력도 차단 (외부 라이브러리 로그 포함)
  if (kReleaseMode) {
    runZoned(
      () => runApp(const ProviderScope(child: MyApp())),
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          // Release 모드에서는 print 출력을 무시
        },
      ),
    );
  } else {
    runApp(const ProviderScope(child: MyApp()));
  }
}
