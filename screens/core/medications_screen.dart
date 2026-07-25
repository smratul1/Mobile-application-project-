import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/medications_provider.dart';
import '../../widgets/medication_card.dart';
import '../medication_management/add_medication_screen.dart';
import '../medication_management/medication_detail_screen.dart';

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
                const Text('Medications',
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

          Expanded(
            child: meds.medications.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medication_rounded, size: 64, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      const Text('Manage your meds',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 8),
                      const Text('Add your meds to be reminded on time and track your health',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const AddMedicationScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        ),
                        child: const Text('Add a med', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  )
                : meds.medications.isEmpty
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medication_rounded, size: 64, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          const Text('Manage your meds',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                          const SizedBox(height: 8),
                          const Text('Add your meds to be reminded on time and track your health',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context, MaterialPageRoute(builder: (_) => const AddMedicationScreen())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            ),
                            child: const Text('Add a med', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              'Inactive meds',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MedicationDetailScreen(medicationId: medication.id),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
