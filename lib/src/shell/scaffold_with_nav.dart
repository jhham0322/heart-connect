import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../core/design_assets.dart';
import '../core/layout_constraints.dart';
import '../widgets/safe_image.dart';
import '../features/gallery/gallery_selection_provider.dart';
import '../features/contacts/current_contact_provider.dart';
import '../features/contacts/selected_group_provider.dart';
import '../features/database/database_provider.dart';
import '../l10n/app_strings.dart';

class ScaffoldWithNav extends ConsumerWidget {
  const ScaffoldWithNav({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SafeImage(
                        assetPath: $assets.heartIcon,
                        width: LayoutConstraints.logoHeight,
                        height: LayoutConstraints.logoHeight,
                        placeholder: Icon(
                          FontAwesomeIcons.heart,
                          color: AppTheme.accentCoral,
                          size: LayoutConstraints.logoHeight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ref.watch(appStringsProvider).appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: SafeImage(
                          assetPath: $assets.bellIcon,
                          width: 24,
                          height: 24,
                          placeholder: Icon(FontAwesomeIcons.bell, size: 20, color: AppTheme.textPrimary),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: SafeImage(
                          assetPath: $assets.settingsIcon,
                          width: 24,
                          height: 24,
                          placeholder: Icon(FontAwesomeIcons.gear, size: 20, color: AppTheme.textPrimary),
                        ),
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: navigationShell,
      extendBody: false,
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8A65).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'write-fab',
          onPressed: () async {
            final selectedImage = ref.read(currentSelectionProvider);
            final selectedGroupTag = ref.read(selectedGroupTagProvider);
            
            // 연락처 탭에서만 currentContact 사용
            final currentContact = navigationShell.currentIndex == 1 
                ? ref.read(currentContactProvider) 
                : null;
            
            // 그룹이 선택된 경우 (연락처 탭) - 그룹 멤버를 수신자로 설정
            if (navigationShell.currentIndex == 1 && selectedGroupTag != null) {
              final database = ref.read(appDatabaseProvider);
              final groupContacts = await database.getContactsByGroupTag(selectedGroupTag);
              
              if (groupContacts.isNotEmpty) {
                final recipients = groupContacts.map((c) => {'name': c.name, 'phone': c.phone}).toList();
                context.push('/write', extra: {'recipients': recipients});
                return;
              }
            }
            
            if (currentContact != null) {
              // 연락처 탭에서 FAB를 누른 경우 - 해당 연락처를 수신자로 설정
              context.push('/write', extra: currentContact);
            } else if (selectedImage != null) {
               // 갤러리에서 선택한 이미지가 있는 경우
               final categoryId = ref.read(currentCategoryProvider);
               final categoryImages = ref.read(currentCategoryImagesProvider);
               context.push('/write', extra: {
                 'image': selectedImage,
                 'categoryId': categoryId,
                 'categoryImages': categoryImages,
               });
            } else {
               // 홈/갤러리(이미지 미선택)에서 FAB - 수신자 없이 시작
               context.push('/write');
            }
          },
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          shape: const CircleBorder(),
          child: SafeImage(
            assetPath: $assets.fabIcon,
            width: 28,
            height: 28,
            placeholder: const Icon(FontAwesomeIcons.penNib, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          height: 85,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      imagePath: $assets.navHome,
                      fallbackIcon: FontAwesomeIcons.house,
                      label: ref.watch(appStringsProvider).navHome,
                      isSelected: navigationShell.currentIndex == 0,
                      onTap: () => _goBranch(0),
                    ),
                    _NavItem(
                      imagePath: $assets.navContacts,
                      fallbackIcon: FontAwesomeIcons.addressBook,
                      label: ref.watch(appStringsProvider).navContacts,
                      isSelected: navigationShell.currentIndex == 1,
                      onTap: () => _goBranch(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      imagePath: $assets.navGallery,
                      fallbackIcon: FontAwesomeIcons.image,
                      label: ref.watch(appStringsProvider).navGallery,
                      isSelected: navigationShell.currentIndex == 2,
                      onTap: () => _goBranch(2),
                    ),
                    _NavItem(
                      imagePath: $assets.navMessage,
                      fallbackIcon: FontAwesomeIcons.envelope,
                      label: ref.watch(appStringsProvider).navMessages,
                      isSelected: navigationShell.currentIndex == 3,
                      onTap: () => _goBranch(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String imagePath;  // 이미지 경로
  final IconData fallbackIcon;  // 이미지 없을 때 폴백 아이콘
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.imagePath,
    required this.fallbackIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.accentCoral : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: isSelected ? 1.0 : 0.5,
              child: SafeImage(
                assetPath: imagePath,
                width: 24,
                height: 24,
                placeholder: Icon(fallbackIcon, color: color, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
