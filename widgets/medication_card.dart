import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/medication_model.dart';

const _freqLabels = {
  'daily': 'Daily',
  'twice_daily': 'Twice daily',
  'three_times_daily': '3× daily',
  'weekly': 'Weekly',
};

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const MedicationCard({super.key, required this.medication, this.onDelete, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.circle, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(
                    '${medication.dosage}, ${_freqLabels[medication.frequency] ?? medication.frequency}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${medication.pillCount} pill${medication.pillCount != 1 ? "s" : ""}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.textSecondary, size: 20),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.destructive, size: 20),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
