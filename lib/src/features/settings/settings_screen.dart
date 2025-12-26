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
import 'package:heart_connect/src/features/alarm/notification_service.dart';
import 'package:heart_connect/src/features/contacts/contact_service.dart';
import 'package:heart_connect/src/features/database/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _brandingEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _brandingEnabled = prefs.getBool('branding_enabled') ?? true;
      
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

  Future<void> _backupData() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final contacts = await db.getAllContacts();
      // Simple JSON export logic
      final List<Map<String, dynamic>> data = contacts.map((c) => {
        'name': c.name,
        'phone': c.phone,
        'group': c.groupTag,
        'birthday': c.birthday?.toIso8601String(),
      }).toList();

      final jsonString = jsonEncode(data);
      final fileName = 'connect_heart_backup_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';

      // For simplicity in this environment, save to documents
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('백업 완료: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('백업 실패: $e')),
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
      case 'naver':
        // 네이버 캘린더
        uri = Uri.parse('https://calendar.naver.com');
        appName = 'Naver Calendar';
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
            case 'naver':
              packageName = 'com.nhn.android.calendar';
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
                  title: "Notifications",
                  desc: "Receive Alerts",
                  descIcon: FontAwesomeIcons.moon,
                  action: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickTime,
                        child: Text(
                          "Set Time\n${_notificationTime.format(context)}",
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
                  title: "Design & Sending",
                  desc: "카드 하단 브랜딩",
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
                  title: "Data Management",
                  desc: "Sync Contacts",
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
                          const SizedBox(width: 8),
                          // Import/Export icons could be separate features, currently just decoration or placeholders
                          // const Icon(FontAwesomeIcons.fileExport, size: 14), 
                          // const SizedBox(width: 8), 
                          // const Icon(FontAwesomeIcons.fileImport, size: 14)
                        ]
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _backupData,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5D4037))),
                          child: const Text("Backup", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 16),
                // 캘린더 연동 카드
                _buildSettingCard(
                  iconBg: const Color(0xFFB3E5FC),
                  icon: FontAwesomeIcons.calendar,
                  title: "Calendar Sync",
                  desc: "외부 캘린더 앱 열기",
                  descIcon: FontAwesomeIcons.arrowUpRightFromSquare,
                  action: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 기본 캘린더 앱
                          _buildCalendarButton(
                            icon: FontAwesomeIcons.mobile,
                            label: "Phone",
                            color: const Color(0xFF4FC3F7),
                            onTap: () => _openCalendarApp('phone'),
                          ),
                          const SizedBox(width: 8),
                          // 구글 캘린더
                          _buildCalendarButton(
                            icon: FontAwesomeIcons.google,
                            label: "Google",
                            color: const Color(0xFFEF5350),
                            onTap: () => _openCalendarApp('google'),
                          ),
                          const SizedBox(width: 8),
                          // 네이버 캘린더
                          _buildCalendarButton(
                            icon: FontAwesomeIcons.n,
                            label: "Naver",
                            color: const Color(0xFF4CAF50),
                            onTap: () => _openCalendarApp('naver'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 16),
                _buildSettingCard(
                  iconBg: const Color(0xFFFFF59D),
                  icon: FontAwesomeIcons.circleInfo,
                  title: "App Info & Support",
                  desc: "Version v1.0.0",
                  action: TextButton(
                    onPressed: _contactUs,
                    child: const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, decoration: TextDecoration.underline)),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
                  const _FooterItem(icon: FontAwesomeIcons.user, label: "Account"),
                  const _FooterItem(icon: FontAwesomeIcons.globe, label: "Language"),
                  _FooterItem(
                    icon: FontAwesomeIcons.doorOpen, // Changed icon
                    label: "Exit", // Changed label
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: onDescTap,
                            child: Row(
                              children: [
                                if (descIcon != null) ...[Icon(descIcon, size: 12, color: const Color(0xFF795548)), const SizedBox(width: 4)],
                                Text(desc, style: const TextStyle(color: Color(0xFF795548), fontSize: 13, fontWeight: FontWeight.w600)),
                                if (onDescTap != null) ...[const SizedBox(width: 4), const Icon(Icons.help_outline, size: 12, color: Colors.grey)],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (action != null) action,
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
