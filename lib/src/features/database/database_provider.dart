import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// 앱 전체에서 사용하는 데이터베이스 Provider
/// keepAlive: true 와 동일하게 동작하도록 Provider 사용 (AutoDispose 아님)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
