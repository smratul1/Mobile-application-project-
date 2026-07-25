import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../providers/medications_provider.dart';

class DoseActionSheet extends StatelessWidget {
  final TodayDose dose;
  final VoidCallback? onSkip;
  final VoidCallback? onTake;
  final VoidCallback? onReschedule;
  final VoidCallback? onUndoTake;
  final VoidCallback? onUndoSkip;
  final VoidCallback? onUndoReschedule;

  const DoseActionSheet({
    super.key,
    required this.dose,
    this.onSkip,
    this.onTake,
    this.onReschedule,
    this.onUndoTake,
    this.onUndoSkip,
    this.onUndoReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final med = dose.medication;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dose.displayName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Scheduled for ${_fmt(dose.time)}, today',
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.medication_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Take ${med.dosage}',
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final actions = <Widget>[];

    if (dose.taken) {
      actions.add(_ActionButton(
        label: 'UNTAKEN',
        icon: Icons.undo_rounded,
        color: AppColors.destructive,
        onTap: onUndoTake,
        isGradient: false,
      ));
      if (dose.isRescheduled) {
        actions.add(_ActionButton(
          label: 'UNDO RESCHEDULE',
          icon: Icons.alarm_off_rounded,
          color: AppColors.warning,
          onTap: onUndoReschedule,
          isGradient: false,
        ));
      } else {
        actions.add(_ActionButton(
          label: 'RESCHEDULE',
          icon: Icons.alarm_rounded,
          color: AppColors.primary,
          onTap: onReschedule,
          isGradient: true,
        ));
      }
    } else if (dose.isRescheduled) {
      actions.add(_ActionButton(
        label: 'UNDO RESCHEDULE',
        icon: Icons.alarm_off_rounded,
        color: AppColors.warning,
        onTap: onUndoReschedule,
        isGradient: false,
      ));
      actions.add(_ActionButton(
        label: 'TAKE',
        icon: Icons.check_rounded,
        color: AppColors.primary,
        onTap: onTake,
        isGradient: true,
      ));
    } else if (dose.doseLogId != null) {
      actions.add(_ActionButton(
        label: 'UNSKIP',
        icon: Icons.undo_rounded,
        color: AppColors.warning,
        onTap: onUndoSkip,
        isGradient: false,
      ));
      actions.add(_ActionButton(
        label: 'TAKE',
        icon: Icons.check_rounded,
        color: AppColors.primary,
        onTap: onTake,
        isGradient: true,
      ));
      actions.add(_ActionButton(
        label: 'RESCHEDULE',
        icon: Icons.alarm_rounded,
        color: AppColors.primary,
        onTap: onReschedule,
        isGradient: true,
      ));
    } else {
      actions.add(_ActionButton(
        label: 'SKIP',
        icon: Icons.close_rounded,
        color: AppColors.textSecondary,
        onTap: onSkip,
        isGradient: false,
      ));
      actions.add(_ActionButton(
        label: 'TAKE',
        icon: Icons.check_rounded,
        color: AppColors.primary,
        onTap: onTake,
        isGradient: true,
      ));
      actions.add(_ActionButton(
        label: 'RESCHEDULE',
        icon: Icons.alarm_rounded,
        color: AppColors.primary,
        onTap: onReschedule,
        isGradient: true,
      ));
    }

    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(child: actions[0]),
          const SizedBox(width: 16),
          Expanded(child: actions[1]),
        ],
      );
    } else if (actions.length == 3) {
      return Row(
        children: [
          Expanded(child: actions[0]),
          const SizedBox(width: 12),
          Expanded(child: actions[1]),
          const SizedBox(width: 12),
          Expanded(child: actions[2]),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  String _fmt(String time) {
    final parts = time.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $period';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isGradient;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isGradient ? null : AppColors.card,
          gradient: isGradient ? AppColors.primaryGradientH : null,
          borderRadius: BorderRadius.circular(16),
          border: isGradient ? null : Border.all(color: AppColors.border, width: 1),
          boxShadow: isGradient
              ? [BoxShadow(color: AppColors.gradientStart.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isGradient ? Colors.white : color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isGradient ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
