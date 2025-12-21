import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request permissions after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    // In a real app, use a provider to avoid repeated requests or show a proper dialog first
    // import permission service
    // await PermissionService().requestInitialPermissions(); 
    // For now, just a placeholder print as I haven't injected the service
    print("Checking permissions...");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
         Padding(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                     // Simple Heart Icons for logo
                    Icon(FontAwesomeIcons.heart, color: Color(0xFFFF7043), size: 20),
                    SizedBox(width: 4),
                    Text("Heart-Connect", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.bell),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.gear),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Warmth Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Warmth", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text("2/5 Sent", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppTheme.textPrimary.withOpacity(0.1)),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppTheme.accentYellow,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text("40%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // Cards Carousel (Placeholder)
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: index == 0 ? AppTheme.cardBg : AppTheme.white,
                    borderRadius: BorderRadius.circular(24),
                    border: index == 0 
                      ? Border.all(color: AppTheme.accentCoral, width: 2)
                      : Border.all(color: AppTheme.grayBtn),
                    boxShadow: index == 0 
                      ? [BoxShadow(color: AppTheme.textPrimary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))] 
                      : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🎂", style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        index == 0 ? "Kim (Birthday)" : "Event $index",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/write'),
                              icon: const Icon(FontAwesomeIcons.pen, size: 16, color: Colors.white),
                              label: const Text("Write", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentCoral,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.grayBtn,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Icon(FontAwesomeIcons.xmark, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Upcoming Events
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Upcoming Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _buildEventItem(FontAwesomeIcons.tree, Colors.green, "Tomorrow", "Mom (Hiking)"),
                _buildEventItem(FontAwesomeIcons.sun, Colors.orange, "D-7", "Sunday Picnic"),
                _buildEventItem(FontAwesomeIcons.gift, Colors.blue, "01/11", "Anniversary"),
              ],
            ),
          ),
          
          // Padding for Bottom Nav
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEventItem(IconData icon, Color color, String date, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Icon(icon, color: color, size: 18)),
          ),
          const SizedBox(width: 16),
          Container(width: 2, height: 24, color: AppTheme.grayLight),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentCoral)),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
