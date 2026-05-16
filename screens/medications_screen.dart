import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/medications_provider.dart';
import '../widgets/medication_card.dart';
import 'add_medication_screen.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meds = context.watch<MedicationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20, right: 8, bottom: 24,
            ),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('My Medications',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                IconButton(
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25), shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AddMedicationScreen())),
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: meds.medications.isEmpty
                ? const Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.medication_rounded, size: 56, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text('No medications yet',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                      SizedBox(height: 8),
                      Text('Tap + to add your first medication',
                          style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: meds.medications.length,
                    itemBuilder: (context, i) {
                      final medication = meds.medications[i];
                      return MedicationCard(
                        medication: medication,
                        onDelete: () => meds.removeMedication(medication.id),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMedicationScreen(medication: medication),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
