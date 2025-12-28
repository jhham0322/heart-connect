import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:heart_connect/l10n/app_localizations.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'package:heart_connect/src/features/alarm/notification_service.dart';
import 'package:heart_connect/src/features/splash/splash_screen.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';
import 'package:heart_connect/src/providers/theme_provider.dart';

import 'dart:ui';


class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goRouter = ref.read(goRouterProvider);
      NotificationService.initialize(goRouter);
    });
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Heart Connect',
      debugShowCheckedModeBanner: false,
      // 테마 모드에 따라 라이트/다크 테마 적용
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
        Locale('it'),
        Locale('ru'),
        Locale('ar'),
        Locale('hi'),
        Locale('tr'),
        Locale('id'),
      ],
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
        },
      ),
      builder: (context, child) {
        return Stack(
          children: [
            // 메인 앱 콘텐츠
            if (child != null) child,
            
            // 스플래시 오버레이
            if (_showSplash)
              Positioned.fill(
                child: SplashScreen(
                  onInitComplete: _onSplashComplete,
                ),
              ),
          ],
        );
      },
    );
  }
}
