import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlarmScreen extends StatelessWidget {
  final String? message;

  const AlarmScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알람'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
             if (context.canPop()) {
               context.pop();
             } else {
               context.go('/');
             }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active, size: 64, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                message ?? '새로운 알림이 없습니다.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                   if (context.canPop()) {
                     context.pop();
                   } else {
                     context.go('/');
                   }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
