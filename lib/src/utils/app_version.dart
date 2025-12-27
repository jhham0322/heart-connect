// ???뚯씪? 鍮뚮뱶 ?ㅽ겕由쏀듃???섑빐 ?먮룞 ?앹꽦?⑸땲??
// ?섎룞?쇰줈 ?섏젙?섏? 留덉꽭??
// ?앹꽦: 2025-12-27

class AppVersion {
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  
  // Git/SVN 由щ퉬???뺣낫 (鍮뚮뱶 ???먮룞 ?낅뜲?댄듃)
  static const String revision = '36a8b85';
  
  // 鍮뚮뱶 ?좎쭨
  static const String buildDate = '2025-12-27';
  
  // ?꾩껜 踰꾩쟾 臾몄옄??
  static String get fullVersion => '$version+$buildNumber ($revision)';
  
  // 吏㏃? 踰꾩쟾 臾몄옄??
  static String get shortVersion => 'v$version ($revision)';
}
