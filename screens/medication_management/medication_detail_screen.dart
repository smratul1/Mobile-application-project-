import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/medications_provider.dart';
import '../../models/medication_model.dart';
import 'add_medication_screen.dart';

class MedicationDetailScreen extends StatefulWidget {
  final String medicationId;

  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  MedicationModel? _medication;
  bool _loading = true;
  String? _lastTaken;
  bool _remindersSuspended = false;

  @override
  void initState() {
    super.initState();
    _loadMedication();
  }

  Future<void> _loadMedication() async {
    final meds = context.read<MedicationsProvider>();
    final med = meds.medications.firstWhere(
      (m) => m.id == widget.medicationId,
      orElse: () => meds.medications.isEmpty
          ? MedicationModel(
              id: widget.medicationId,
              name: '',
              dosage: '',
              frequency: 'daily',
              times: [],
              pillCount: 0,
              color: '#000000',
              startDate: DateTime.now(),
              frequencyPerDay: 1)
          : meds.medications.first,
    );

    final doseLogs = meds.doseLogs
        .where((l) => l.medicationId == widget.medicationId && l.taken)
        .toList();

    doseLogs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    final lastLog = doseLogs.isNotEmpty ? doseLogs.first : null;

    String? lastTakenStr;
    if (lastLog != null) {
      final dateParts = (lastLog.date ?? '').split('-');
      final timeParts = (lastLog.time ?? '').split(':');
      if (dateParts.length == 3 && timeParts.length == 2) {
        const monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final month = int.tryParse(dateParts[1]) ?? 1;
        final day = int.tryParse(dateParts[2]) ?? 1;
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = timeParts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour % 12 == 0 ? 12 : hour % 12;
        lastTakenStr = 'Today, ${monthNames[month - 1]} $day, $displayHour:$minute $period';
      }
    }

    setState(() {
      _medication = med;
      _lastTaken = lastTakenStr;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final med = _medication;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              med?.name ?? 'Medication',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () async {
                  if (med == null) return;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.card,
                      title: const Text('Delete', style: TextStyle(color: AppColors.text)),
                      content: Text('Delete ${med.name}?', style: const TextStyle(color: AppColors.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('DELETE', style: TextStyle(color: AppColors.destructive)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) {
                    final meds = context.read<MedicationsProvider>();
                    await meds.removeMedication(med.id);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  if (med == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMedicationScreen(medication: med),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : med == null
              ? const Center(child: Text('Medication not found', style: TextStyle(color: AppColors.text)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSection(
                      title: 'Reminders are suspended',
                      trailing: TextButton(
                        onPressed: () {
                          setState(() => _remindersSuspended = !_remindersSuspended);
                        },
                        child: Text(
                          _remindersSuspended ? 'RESUME' : 'SUSPEND',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow('Last taken', _lastTaken ?? 'Never'),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Reminders',
                      '${med.frequencyPerDay > 1 ? '${med.frequencyPerDay}x ' : ''}${med.frequency}\n${med.times.map((t) => '$t take ${med.dosage}').join('\n')}',
                    ),
                    const SizedBox(height: 16),
                    if (med.notes != null && med.notes!.isNotEmpty)
                      _buildInfoRow('Condition', med.notes!),
                    const SizedBox(height: 16),
                    _buildRefillRow(med),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Prescription Refill',
                      'No refill reminder',
                    ),
                  ],
                ),
    );
  }

  Widget _buildSection({required String title, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildRefillRow(MedicationModel med) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prescription Refill',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'No refill reminder',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.text,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('REFILL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}
