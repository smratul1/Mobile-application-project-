import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class RemindersTroubleshootingScreen extends StatelessWidget {
  const RemindersTroubleshootingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {'title': 'Enable permissions', 'desc': 'Make sure notification permissions are allowed for Med_App.'},
      {'title': 'Battery optimization', 'desc': 'Disable battery optimization for the app to ensure timely reminders.'},
      {'title': 'Check time settings', 'desc': 'Ensure your device time is set to automatic network time.'},
      {'title': 'Update app', 'desc': 'Keep the app updated for the latest reminder improvements.'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white)),
                  const Text('Reminders Troubleshooting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tips.length,
                itemBuilder: (ctx, i) {
                  final tip = tips[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.lightbulb_outlined, color: AppColors.textSecondary)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(tip['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                          Text(tip['desc']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ])),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
