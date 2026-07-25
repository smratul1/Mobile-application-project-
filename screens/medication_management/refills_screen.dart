import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/medications_provider.dart';

class RefillsScreen extends StatefulWidget {
  const RefillsScreen({super.key});

  @override
  State<RefillsScreen> createState() => _RefillsScreenState();
}

class _RefillsScreenState extends State<RefillsScreen> {
  final List<Map<String, String>> _refills = [];
  MedicationsProvider? _meds;

  @override
  void initState() {
    super.initState();
    _meds = context.read<MedicationsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _refills.addAll(_meds!.medications.map((m) => {'name': m.name, 'dosage': m.dosage}).toList());
      });
    });
  }

  void _requestRefill(int index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Refill requested for ${_refills[index]['name']}'), backgroundColor: AppColors.success));
  }

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
                  const Text('Refills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: _refills.isEmpty
                  ? const Center(child: Text('No medications to refill', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _refills.length,
                      itemBuilder: (ctx, i) {
                        final item = _refills[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                          child: Row(
                            children: [
                              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.local_pharmacy_outlined, color: AppColors.textSecondary)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                                Text(item['dosage']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ])),
                              ElevatedButton(onPressed: () => _requestRefill(i), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Refill')),
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
