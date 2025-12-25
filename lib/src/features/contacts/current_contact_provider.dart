import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

/// 현재 보고 있는 연락처를 관리하는 Provider
/// ContactDetailScreen에서 설정되고, ScaffoldWithNav에서 사용됨
final currentContactProvider = StateProvider<Contact?>((ref) => null);
