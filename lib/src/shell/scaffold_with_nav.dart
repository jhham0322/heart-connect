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
            color: Colors.transparent, 
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.heart,
                          color: AppTheme.accentCoral,
                          size: LayoutConstraints.logoHeight,
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
                          icon: const Icon(FontAwesomeIcons.bell, size: 24, color: AppTheme.textPrimary),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.gear, size: 24, color: AppTheme.textPrimary),
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
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
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
          elevation: 4,
          backgroundColor: AppTheme.accentCoral, // Use theme color directly
          shape: const CircleBorder(),
          child: const Icon(FontAwesomeIcons.penNib, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: 100, 
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
             // 배경 이미지 (유지)
             Positioned.fill(
                child: SafeImage(
                  assetPath: $assets.navBarBg,
                  fit: BoxFit.fill, 
                ),
             ),
             // 실제 버튼들
             Padding(
               padding: const EdgeInsets.only(bottom: 15), 
               child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavItem(
                          icon: FontAwesomeIcons.house,
                          label: ref.watch(appStringsProvider).navHome,
                          isSelected: navigationShell.currentIndex == 0,
                          onTap: () => _goBranch(0),
                        ),
                        _NavItem(
                          icon: FontAwesomeIcons.addressBook,
                          label: ref.watch(appStringsProvider).navContacts,
                          isSelected: navigationShell.currentIndex == 1,
                          onTap: () => _goBranch(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 80), // FAB 공간
                  Expanded(
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                        _NavItem(
                          icon: FontAwesomeIcons.image,
                          label: ref.watch(appStringsProvider).navGallery,
                          isSelected: navigationShell.currentIndex == 2,
                          onTap: () => _goBranch(2),
                        ),
                        _NavItem(
                          icon: FontAwesomeIcons.envelope,
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
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon; 
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
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
             Icon(icon, color: color, size: 28),
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
