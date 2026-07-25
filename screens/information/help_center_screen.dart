import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, String>> _faqs = [
    {'q': 'How do I add a medication?', 'a': 'Go to the Meds tab and tap the + button.'},
    {'q': 'How do I enable reminders?', 'a': 'Notifications are enabled by default. You can toggle them in App Settings.'},
    {'q': 'Can I share my data with family?', 'a': 'Yes, use the Invite Medfriend option from the drawer.'},
    {'q': 'How do I cancel my subscription?', 'a': 'Visit the Subscription page and follow the cancel flow.'},
  ];

  @override
  Widget build(BuildContext context) {
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
                  const Text('Help Center', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _faqs.length,
                itemBuilder: (ctx, i) {
                  final faq = _faqs[i];
                  return Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      backgroundColor: AppColors.card,
                      collapsedBackgroundColor: AppColors.card,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
                      title: Text(faq['q']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                      children: [Align(alignment: Alignment.centerLeft, child: Text(faq['a']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)))],
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
