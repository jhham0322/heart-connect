import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                      const Text("Set Time\n9:00 AM", textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Switch(value: true, activeThumbColor: const Color(0xFFA5D6A7), onChanged: (v){}),
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
                  action: Switch(value: true, activeThumbColor: const Color(0xFFA5D6A7), onChanged: (v){}),
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
                      const Row(children: [Icon(FontAwesomeIcons.fileExport, size: 14), SizedBox(width: 8), Icon(FontAwesomeIcons.fileImport, size: 14)]),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFF59D), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF5D4037))),
                        child: const Text("Backup", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                  action: TextButton(onPressed: (){}, child: const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, decoration: TextDecoration.underline))),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FooterItem(icon: FontAwesomeIcons.user, label: "Account"),
                  _FooterItem(icon: FontAwesomeIcons.globe, label: "Language"),
                  _FooterItem(icon: FontAwesomeIcons.arrowRightFromBracket, label: "Logout"),
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
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5D4037)),
        boxShadow: [BoxShadow(color: const Color(0xFF5D4037).withOpacity(0.05), offset: const Offset(0, 4))],
      ),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (descIcon != null) ...[Icon(descIcon, size: 12, color: const Color(0xFF795548)), const SizedBox(width: 4)],
                          Text(desc, style: const TextStyle(color: Color(0xFF795548), fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  if (action != null) action,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FooterItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: const Color(0xFF3E2723)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF795548))),
      ],
    );
  }
}
