import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:heart_connect/src/features/alarm/notification_service.dart';
import 'package:heart_connect/src/features/contacts/contact_service.dart';
import 'package:heart_connect/src/features/database/database_provider.dart';
import 'package:heart_connect/src/features/database/app_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:heart_connect/src/utils/app_version.dart';
import 'package:heart_connect/src/l10n/app_strings.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _brandingEnabled = true;
  String _userName = 'Heart-Connect';
  String _selectedLanguage = 'ko';
  
  // G20 언어 목록
  final Map<String, String> _languages = {
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'zh': '中文',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español',
    'pt': 'Português',
    'it': 'Italiano',
    'ru': 'Русский',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'tr': 'Türkçe',
    'id': 'Bahasa Indonesia',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 저장된 사용자 이름 가져오기
    String savedUserName = prefs.getString('user_name') ?? '';
    
    // 사용자 이름이 비어있거나 기본값이면 핸드폰 소유자 이름을 가져오기 시도
    if (savedUserName.isEmpty || savedUserName == 'Heart-Connect') {
      try {
        if (await fc.FlutterContacts.requestPermission()) {
          // 연락처에서 "나" 또는 소유자를 찾기 (통상적으로 첫 번째 연락처 또는 별도 API)
          // 안드로이드에서 기기 소유자 이름 가져오기는 제한적이므로
          // 여기서는 기본값 유지
        }
      } catch (e) {
        // 권한 없음 또는 오류 - 무시
      }
    }
    
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _brandingEnabled = prefs.getBool('branding_enabled') ?? true;
      _userName = savedUserName.isNotEmpty ? savedUserName : 'Heart-Connect';
      _selectedLanguage = prefs.getString('selected_language') ?? 'ko';
      
      final timeStr = prefs.getString('notification_time');
      if (timeStr != null) {
        final parts = timeStr.split(':');
        _notificationTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('branding_enabled', _brandingEnabled);
    await prefs.setString('user_name', _userName);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('notification_time', '${_notificationTime.hour}:${_notificationTime.minute}');
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      _saveSettings();
      NotificationService.updateSchedule(); // 스케줄 업데이트
    }
  }

  Future<void> _syncContacts() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
      
      await ref.read(contactServiceProvider.notifier).syncContacts();
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연락처 동기화가 완료되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동기화 실패: $e')),
        );
      }
    }
  }

  // 확장된 백업 - 연락처, 일정, 설정, 저장된 카드
  Future<void> _backupData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
      
      final db = ref.read(appDatabaseProvider);
      final prefs = await SharedPreferences.getInstance();
      
      // 1. 연락처 데이터
      final contacts = await db.getAllContacts();
      final List<Map<String, dynamic>> contactsData = contacts.map((c) => {
        'name': c.name,
        'phone': c.phone,
        'group': c.groupTag,
        'birthday': c.birthday?.toIso8601String(),
        'isFavorite': c.isFavorite,
      }).toList();
      
      // 2. 일정 데이터
      final plans = await db.getAllDailyPlans();
      final List<Map<String, dynamic>> plansData = plans.map((p) => {
        'id': p.id,
        'content': p.content,
        'date': p.date.toIso8601String(),
        'type': p.type,
        'recipients': p.recipients,
        'isCompleted': p.isCompleted,
      }).toList();
      
      // 3. 저장된 카드
      final cards = await db.getAllSavedCards();
      final List<Map<String, dynamic>> cardsData = cards.map((c) => {
        'id': c.id,
        'name': c.name,
        'imagePath': c.imagePath,
        'htmlContent': c.htmlContent,
        'footerText': c.footerText,
        'createdAt': c.createdAt.toIso8601String(),
      }).toList();
      
      // 4. 설정 값
      final Map<String, dynamic> settingsData = {
        'notifications_enabled': prefs.getBool('notifications_enabled') ?? true,
        'branding_enabled': prefs.getBool('branding_enabled') ?? true,
        'notification_time': prefs.getString('notification_time') ?? '9:0',
        'user_name': prefs.getString('user_name') ?? 'Heart-Connect',
        'selected_language': prefs.getString('selected_language') ?? 'ko',
      };
      
      // 전체 백업 데이터
      final backupData = {
        'version': '1.0',
        'createdAt': DateTime.now().toIso8601String(),
        'contacts': contactsData,
        'plans': plansData,
        'cards': cardsData,
        'settings': settingsData,
      };

      final jsonString = jsonEncode(backupData);
      final fileName = 'connect_heart_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      // 외부 저장소에 저장 (Downloads 폴더 등)
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        _showBackupResultDialog(file.path, contactsData.length, plansData.length, cardsData.length);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('백업 실패: $e')),
        );
      }
    }
  }
  
  // 백업 결과 다이얼로그
  void _showBackupResultDialog(String path, int contactCount, int planCount, int cardCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.check, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('백업 완료', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('다음 데이터가 백업되었습니다:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildBackupInfoRow(FontAwesomeIcons.addressBook, '연락처', '$contactCount명'),
            _buildBackupInfoRow(FontAwesomeIcons.calendar, '일정', '$planCount개'),
            _buildBackupInfoRow(FontAwesomeIcons.image, '저장된 카드', '$cardCount개'),
            _buildBackupInfoRow(FontAwesomeIcons.gear, '설정', '포함'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '저장 위치:\n$path',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackupInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.brown),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
  
  // 복원 기능
  Future<void> _restoreData() async {
    try {
      // 파일 선택 다이얼로그
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory(directory.path);
      
      // 백업 파일 목록 가져오기
      final files = backupDir.listSync().whereType<File>().where((f) => f.path.endsWith('.json') && f.path.contains('connect_heart_backup')).toList();
      
      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('백업 파일이 없습니다. 먼저 백업을 진행해주세요.'),
              action: SnackBarAction(label: '백업하기', onPressed: _backupData),
            ),
          );
        }
        return;
      }
      
      // 파일 정렬 (최신순)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      // 파일 선택 다이얼로그
      final selectedFile = await showDialog<File>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(FontAwesomeIcons.folderOpen, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('백업 파일 선택', style: TextStyle(fontSize: 18))),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.path.split('/').last;
                final stat = file.statSync();
                final modifiedDate = DateFormat('yyyy-MM-dd HH:mm').format(stat.modified);
                final fileSize = (stat.size / 1024).toStringAsFixed(1);
                
                return ListTile(
                  leading: const Icon(FontAwesomeIcons.fileCode, color: Colors.blue),
                  title: Text(fileName, style: const TextStyle(fontSize: 12)),
                  subtitle: Text('$modifiedDate | ${fileSize}KB', style: const TextStyle(fontSize: 10)),
                  onTap: () => Navigator.pop(context, file),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        ),
      );
      
      if (selectedFile == null) return;
      
      // 복원 확인 다이얼로그
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('데이터 복원'),
          content: const Text('기존 데이터가 백업 데이터로 교체됩니다.\n\n계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('복원', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      // 복원 진행
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
      
      final jsonString = await selectedFile.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final db = ref.read(appDatabaseProvider);
      final prefs = await SharedPreferences.getInstance();
      
      int restoredContacts = 0;
      int restoredPlans = 0;
      
      // 연락처 복원
      if (backupData['contacts'] != null) {
        final contacts = backupData['contacts'] as List;
        for (var c in contacts) {
          try {
            await db.upsertContact(ContactsCompanion(
              name: Value(c['name'] ?? ''),
              phone: Value(c['phone'] ?? ''),
              groupTag: Value(c['group']),
              birthday: Value(c['birthday'] != null ? DateTime.parse(c['birthday']) : null),
              isFavorite: Value(c['isFavorite'] ?? false),
            ));
            restoredContacts++;
          } catch (e) {
            print('연락처 복원 오류: $e');
          }
        }
      }
      
      // 설정 복원
      if (backupData['settings'] != null) {
        final settings = backupData['settings'] as Map<String, dynamic>;
        await prefs.setBool('notifications_enabled', settings['notifications_enabled'] ?? true);
        await prefs.setBool('branding_enabled', settings['branding_enabled'] ?? true);
        await prefs.setString('notification_time', settings['notification_time'] ?? '9:0');
        await prefs.setString('user_name', settings['user_name'] ?? 'Heart-Connect');
        await prefs.setString('selected_language', settings['selected_language'] ?? 'ko');
      }
      
      if (mounted) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 완료! 연락처 $restoredContacts명 복원됨')),
        );
        
        // 설정 다시 로드
        _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $e')),
        );
      }
    }
  }
  
  // 데이터 내보내기 (공유 기능 사용)
  Future<void> _exportData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
      
      final db = ref.read(appDatabaseProvider);
      final prefs = await SharedPreferences.getInstance();
      
      // 백업 데이터 생성 (기존 백업 로직 재사용)
      final contacts = await db.getAllContacts();
      final plans = await db.getAllDailyPlans();
      final cards = await db.getAllSavedCards();
      
      final backupData = {
        'version': '1.0',
        'createdAt': DateTime.now().toIso8601String(),
        'contacts': contacts.map((c) => {
          'name': c.name,
          'phone': c.phone,
          'group': c.groupTag,
          'birthday': c.birthday?.toIso8601String(),
          'isFavorite': c.isFavorite,
        }).toList(),
        'plans': plans.map((p) => {
          'id': p.id,
          'content': p.content,
          'date': p.date.toIso8601String(),
          'type': p.type,
          'recipients': p.recipients,
          'isCompleted': p.isCompleted,
        }).toList(),
        'cards': cards.map((c) => {
          'id': c.id,
          'name': c.name,
          'imagePath': c.imagePath,
          'htmlContent': c.htmlContent,
          'footerText': c.footerText,
          'createdAt': c.createdAt.toIso8601String(),
        }).toList(),
        'settings': {
          'notifications_enabled': prefs.getBool('notifications_enabled') ?? true,
          'branding_enabled': prefs.getBool('branding_enabled') ?? true,
          'notification_time': prefs.getString('notification_time') ?? '9:0',
          'user_name': prefs.getString('user_name') ?? 'Heart-Connect',
          'selected_language': prefs.getString('selected_language') ?? 'ko',
        },
      };

      final jsonString = jsonEncode(backupData);
      final fileName = 'connect_heart_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      // 임시 파일에 저장
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (mounted) {
        Navigator.pop(context);
        
        // 공유 다이얼로그 표시
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'ConnectHeart 데이터 백업',
          text: 'ConnectHeart 앱 데이터 백업 파일입니다.',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내보내기 실패: $e')),
        );
      }
    }
  }
  
  // 데이터 가져오기 (파일 선택)
  Future<void> _importData() async {
    try {
      // 파일 선택
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'JSON',
        extensions: ['json'],
      );
      
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      
      if (file == null) return;
      
      // 확인 다이얼로그
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('데이터 가져오기'),
          content: Text('선택한 파일: ${file.name}\n\n기존 데이터가 교체됩니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('가져오기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
      
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final db = ref.read(appDatabaseProvider);
      final prefs = await SharedPreferences.getInstance();
      
      int restoredContacts = 0;
      
      // 연락처 복원
      if (backupData['contacts'] != null) {
        final contacts = backupData['contacts'] as List;
        for (var c in contacts) {
          try {
            await db.upsertContact(ContactsCompanion(
              name: Value(c['name'] ?? ''),
              phone: Value(c['phone'] ?? ''),
              groupTag: Value(c['group']),
              birthday: Value(c['birthday'] != null ? DateTime.parse(c['birthday']) : null),
              isFavorite: Value(c['isFavorite'] ?? false),
            ));
            restoredContacts++;
          } catch (e) {
            print('연락처 가져오기 오류: $e');
          }
        }
      }
      
      // 설정 복원
      if (backupData['settings'] != null) {
        final settings = backupData['settings'] as Map<String, dynamic>;
        await prefs.setBool('notifications_enabled', settings['notifications_enabled'] ?? true);
        await prefs.setBool('branding_enabled', settings['branding_enabled'] ?? true);
        await prefs.setString('notification_time', settings['notification_time'] ?? '9:0');
        await prefs.setString('user_name', settings['user_name'] ?? 'Heart-Connect');
        await prefs.setString('selected_language', settings['selected_language'] ?? 'ko');
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가져오기 완료! 연락처 $restoredContacts명')),
        );
        _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가져오기 실패: $e')),
        );
      }
    }
  }

  Future<void> _contactUs() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'joenbympray@gmail.com',
      query: 'subject=ConnectHeart 문의&body=문의 내용을 입력해주세요.',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메일 앱을 열 수 없습니다.')),
        );
      }
    }
  }

  void _showBrandingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("카드 하단 브랜딩이란?"),
        content: const Text("카드를 보낼 때 이미지 하단에 'Sent via ConnectHeart' 문구와 로고가 작게 표시됩니다.\n\n이 기능을 끄면 문구가 표시되지 않습니다."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인")),
        ],
      ),
    );
  }
  
  void _showCalendarGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.calendarCheck, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('지원 캘린더 안내', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('✅ 지원되는 캘린더', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                  SizedBox(height: 8),
                  Text('• 구글 캘린더', style: TextStyle(fontSize: 13)),
                  Text('• 삼성 캘린더', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 8),
                  Text('위 캘린더에 일정을 등록하시면 앱에서 자동으로 표시됩니다.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('❌ 미지원 캘린더', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                  SizedBox(height: 8),
                  Text('• 네이버 캘린더', style: TextStyle(fontSize: 13)),
                  Text('• 카카오톡 캘린더', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 8),
                  Text('Android 표준 캘린더 동기화를 지원하지 않아 일정을 읽을 수 없습니다.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
  
  // Account 다이얼로그 - 이름/별명 설정
  void _showAccountDialog() {
    final controller = TextEditingController(text: _userName);
    final strings = ref.read(appStringsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.user, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(strings.settingsMyName, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: strings.settingsNameOrNickname,
                hintText: strings.settingsNameHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(FontAwesomeIcons.signature, size: 16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.circleInfo, size: 14, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.settingsNameUsageInfo,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = controller.text.trim().isNotEmpty ? controller.text.trim() : 'Heart-Connect';
              });
              _saveSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${strings.settingsName}: "$_userName"')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(strings.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  // Language 다이얼로그 - G20 언어 선택
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(FontAwesomeIcons.globe, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('언어 설정', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: ListView.builder(
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final entry = _languages.entries.elementAt(index);
              final isSelected = _selectedLanguage == entry.key;
              
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isSelected ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                title: Text(entry.value),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = entry.key;
                  });
                  _saveSettings();
                  // 즉시 언어 적용
                  ref.read(localeProvider.notifier).setLocale(entry.key);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('언어가 ${entry.value}로 변경되었습니다.')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  // 캘린더 앱 열기
  Future<void> _openCalendarApp(String type) async {
    Uri? uri;
    String appName = '';
    
    switch (type) {
      case 'phone':
        // Android 기본 캘린더
        uri = Uri.parse('content://com.android.calendar/time/');
        appName = '기본 캘린더';
        break;
      case 'google':
        // 구글 캘린더
        uri = Uri.parse('https://calendar.google.com');
        appName = 'Google Calendar';
        break;
      case 'samsung':
        // 삼성 캘린더
        uri = Uri.parse('content://com.samsung.android.calendar/time/');
        appName = 'Samsung Calendar';
        break;
    }
    
    if (uri != null) {
      try {
        // Android에서 앱 직접 실행 시도
        if (Platform.isAndroid) {
          String? packageName;
          switch (type) {
            case 'phone':
              packageName = 'com.android.calendar';
              break;
            case 'google':
              packageName = 'com.google.android.calendar';
              break;
            case 'samsung':
              packageName = 'com.samsung.android.calendar';
              break;
          }
          
          if (packageName != null) {
            final intent = Uri.parse('android-app://$packageName');
            if (await canLaunchUrl(intent)) {
              await launchUrl(intent);
              return;
            }
          }
        }
        
        // 앱이 없으면 웹으로 열기
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$appName 앱을 열 수 없습니다.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$appName 앱을 열 수 없습니다: $e')),
          );
        }
      }
    }
  }
  
  // 캘린더 버튼 위젯
  Widget _buildCalendarButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSettingCard(
                  iconBg: const Color(0xFFFFF59D),
                  icon: FontAwesomeIcons.bell,
                  title: strings.settingsNotifications,
                  desc: strings.settingsReceiveAlerts,
                  descIcon: FontAwesomeIcons.moon,
                  action: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickTime,
                        child: Text(
                          "${strings.settingsSetTime}\n${_notificationTime.format(context)}",
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              NotificationService.showNotification(
                                title: "테스트 알림",
                                body: "설정된 시간: ${_notificationTime.format(context)}",
                              );
                            },
                            child: const Text("Test", style: TextStyle(fontSize: 10)),
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            activeThumbColor: const Color(0xFFA5D6A7),
                            onChanged: (v) {
                              setState(() => _notificationsEnabled = v);
                              _saveSettings();
                              NotificationService.updateSchedule(); // 스케줄 업데이트
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  iconBg: const Color(0xFFFFAB91),
                  icon: FontAwesomeIcons.wandMagicSparkles,
                  title: strings.settingsDesignSending,
                  desc: strings.settingsCardBranding,
                  descIcon: FontAwesomeIcons.heart,
                  onDescTap: _showBrandingInfo, // Add info tap
                  action: Switch(
                    value: _brandingEnabled,
                    activeThumbColor: const Color(0xFFA5D6A7),
                    onChanged: (v) {
                      setState(() => _brandingEnabled = v);
                      _saveSettings();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  iconBg: const Color(0xFFFFF59D),
                  icon: FontAwesomeIcons.cloudArrowUp,
                  title: strings.settingsDataManage,
                  desc: strings.settingsSyncContacts,
                  descIcon: FontAwesomeIcons.rotate,
                  action: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.rotate, size: 14),
                            onPressed: _syncContacts,
                            tooltip: "연락처 동기화",
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ]
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _backupData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5D4037))),
                              child: Text(strings.settingsBackup, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _restoreData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFB3E5FC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5D4037))),
                              child: Text(strings.settingsRestore, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _exportData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5D4037))),
                              child: Text(strings.settingsExport, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _importData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5D4037))),
                              child: Text(strings.settingsImport, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 16),
                // 캘린더 연동 카드
                _buildSettingCard(
                  iconBg: const Color(0xFFB3E5FC),
                  icon: FontAwesomeIcons.calendar,
                  title: strings.settingsCalendarSync,
                  desc: strings.settingsOpenCalendar,
                  descIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                  action: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 구글 캘린더
                          _buildCalendarButton(
                            icon: FontAwesomeIcons.google,
                            label: "Google",
                            color: const Color(0xFFEF5350),
                            onTap: () => _openCalendarApp('google'),
                          ),
                          const SizedBox(width: 8),
                          // 삼성 캘린더
                          _buildCalendarButton(
                            icon: FontAwesomeIcons.s,
                            label: "Samsung",
                            color: const Color(0xFF1E88E5),
                            onTap: () => _openCalendarApp('samsung'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 지원 캘린더 안내 버튼
                      GestureDetector(
                        onTap: _showCalendarGuide,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(FontAwesomeIcons.circleInfo, size: 12, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(strings.settingsCalendarGuide, style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 16),
                _buildSettingCard(
                  iconBg: const Color(0xFFFFF59D),
                  icon: FontAwesomeIcons.circleInfo,
                  title: strings.settingsAppInfo,
                  desc: "${strings.settingsVersion} ${AppVersion.shortVersion}",
                  action: TextButton(
                    onPressed: _contactUs,
                    child: Text(strings.settingsContactUs, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, decoration: TextDecoration.underline)),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5D4037)),
                boxShadow: [BoxShadow(color: const Color(0xFF5D4037).withOpacity(0.1), offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FooterItem(icon: FontAwesomeIcons.user, label: strings.settingsAccount, onTap: _showAccountDialog),
                  _FooterItem(icon: FontAwesomeIcons.globe, label: strings.settingsLanguage, onTap: _showLanguageDialog),
                  _FooterItem(
                    icon: FontAwesomeIcons.doorOpen, // Changed icon
                    label: strings.settingsExit, // Changed label
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        // If it's the root, maybe minimize or close app?
                        // For now, assume it's pushed. If root, we can try SystemNavigator.pop()
                         if (Platform.isAndroid || Platform.isIOS) {
                            try {
                              SystemNavigator.pop();
                            } catch(e) { /* ignore */ }
                         }
                      }
                    },
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required Color iconBg,
    required IconData icon,
    required String title,
    required String desc,
    IconData? descIcon,
    Widget? action,
    VoidCallback? onDescTap,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5D4037)),
        boxShadow: [BoxShadow(color: const Color(0xFF5D4037).withOpacity(0.05), offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 70,
              decoration: const BoxDecoration(
                color: Colors.white, // In scan, it was transparent but here for layout
                border: Border(right: BorderSide(color: Color(0xFF5D4037), width: 2)),
              ),
              child: Container(
                color: iconBg, // Actually the whole left side has bg
                child: Center(child: Icon(icon, size: 28, color: const Color(0xFF3E2723))),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title, 
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: onDescTap,
                            child: Row(
                              children: [
                                if (descIcon != null) ...[Icon(descIcon, size: 10, color: const Color(0xFF795548)), const SizedBox(width: 3)],
                                Flexible(
                                  child: Text(
                                    desc, 
                                    style: const TextStyle(color: Color(0xFF795548), fontSize: 11, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (onDescTap != null) ...[const SizedBox(width: 3), const Icon(Icons.help_outline, size: 10, color: Colors.grey)],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (action != null) Flexible(flex: 4, child: action),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _FooterItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF3E2723)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF795548))),
        ],
      ),
    );
  }
}
