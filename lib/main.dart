import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'src/app.dart';
import 'src/utils/ad_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  runApp(const ProviderScope(child: MyApp()));
}
