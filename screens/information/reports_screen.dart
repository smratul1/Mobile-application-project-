import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Map<String, String>> _reports = [
    {'title': 'Weekly Medication Adherence', 'period': 'Jul 18 - Jul 24, 2026', 'value': '94%'},
    {'title': 'Blood Pressure Trend', 'period': 'Last 30 days', 'value': 'Normal'},
    {'title': 'Monthly Health Summary', 'period': 'June 2026', 'value': 'Good'},
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
                  const Text('Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  IconButton(onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report exported'), backgroundColor: AppColors.success));
                  }, icon: const Icon(Icons.download, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reports.length,
                itemBuilder: (ctx, i) {
                  final r = _reports[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.insert_chart_outlined, color: AppColors.textSecondary)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                          Text(r['period']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ])),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)), child: Text(r['value']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))),
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
