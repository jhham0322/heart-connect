import 'package:flutter_riverpod/flutter_riverpod.dart';

// 현재 선택된 그룹 태그를 저장하는 Provider
// contacts_screen.dart에서 그룹 선택 시 설정, 
// ScaffoldWithNav에서 FAB 클릭 시 확인
final selectedGroupTagProvider = StateProvider<String?>((ref) => null);
