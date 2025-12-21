import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/home_screen.dart';
import '../features/contacts/contacts_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/card_editor/write_card_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shell/scaffold_with_nav.dart';

// Private navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorContactsKey = GlobalKey<NavigatorState>(debugLabel: 'shellContacts');
final _shellNavigatorGalleryKey = GlobalKey<NavigatorState>(debugLabel: 'shellGallery');
final _shellNavigatorMailboxKey = GlobalKey<NavigatorState>(debugLabel: 'shellMailbox');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorContactsKey,
            routes: [
              GoRoute(
                path: '/contacts',
                pageBuilder: (context, state) => const NoTransitionPage(child: ContactsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorGalleryKey,
            routes: [
              GoRoute(
                path: '/gallery',
                pageBuilder: (context, state) => const NoTransitionPage(child: GalleryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMailboxKey,
            routes: [
              GoRoute(
                path: '/mailbox',
                pageBuilder: (context, state) => const NoTransitionPage(child: Scaffold(body: Center(child: Text("Mailbox Construction")))),
              ),
            ],
          ),
        ],
      ),
      // Fullscreen routes
      GoRoute(
        path: '/write',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WriteCardScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
