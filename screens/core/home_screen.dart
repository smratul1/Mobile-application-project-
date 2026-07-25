import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medications_provider.dart';
import '../health_tracking/tracker_entry_screen.dart';
import '../medication_management/add_medication_screen.dart';
import '../profile_drawer.dart';
import '../dialogs/dose_action_sheet.dart';

String _monthShort(int m) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[m - 1];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _fabOpen = false;
  DateTime? _selectedDate;

  String _fmtTime(String t) {
    final p = t.split(':');
    final h = int.parse(p[0]);
    final m = p[1];
    return '${h % 12 == 0 ? 12 : h % 12}:$m ${h >= 12 ? "PM" : "AM"}';
  }

  Future<void> _showRescheduleSheet(TodayDose dose, String dateStr) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _RescheduleSheetContent(dose: dose, dateStr: dateStr),
    );
  }

  void _openDoseActions(TodayDose dose) {
    final dateStr = _dateStr(_selectedDate ?? DateTime.now());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DoseActionSheet(
        dose: dose,
        onTake: !dose.taken
            ? () {
                final meds = context.read<MedicationsProvider>();
                meds.markDoseTaken(dose.medication.id, dateStr, dose.time);
                Navigator.pop(context);
              }
            : null,
        onSkip: (!dose.taken && !dose.isRescheduled)
            ? () {
                final meds = context.read<MedicationsProvider>();
                meds.markDoseSkipped(dose.medication.id, dateStr, dose.time);
                Navigator.pop(context);
              }
            : null,
        onReschedule: !dose.isRescheduled
            ? () async {
                Navigator.pop(context);
                await _showRescheduleSheet(dose, dateStr);
              }
            : null,
        onUndoTake: dose.taken
            ? () {
                final meds = context.read<MedicationsProvider>();
                meds.undoDoseTake(dose.medication.id, dateStr, dose.time);
                Navigator.pop(context);
              }
            : null,
        onUndoSkip: (!dose.taken && dose.doseLogId != null && !dose.isRescheduled)
            ? () {
                final meds = context.read<MedicationsProvider>();
                meds.undoDoseSkip(dose.medication.id, dateStr, dose.time);
                Navigator.pop(context);
              }
            : null,
        onUndoReschedule: dose.isRescheduled
            ? () {
                final meds = context.read<MedicationsProvider>();
                meds.undoReschedule(dose.medication.id, dateStr, dose.time);
                Navigator.pop(context);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final meds = context.watch<MedicationsProvider>();
    final now = DateTime.now();
    final selectedDate = _selectedDate ?? now;
    final selectedDateStr = _dateStr(selectedDate);
    final doses = meds.getDateDoses(selectedDateStr);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Row(
                      children: [
                        Text(
                          auth.currentUser?.name ?? 'Ratul',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.text),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.destructive, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _buildSectionHeader(
                    context,
                    title: 'Today, ${_monthShort(selectedDate.month)} ${selectedDate.day}',
                    dotColor: AppColors.primary,
                    onViewAll: () {},
                  ),
                  const SizedBox(height: 12),
                  if (doses.isEmpty)
                    _EmptyState(onAdd: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicationScreen()));
                    })
                  else
                    ...doses.map((dose) => _doseCard(dose: dose, onTap: () => _openDoseActions(dose))),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: const ProfileDrawer(),
      floatingActionButton: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_fabOpen) ...[
              _FabMenuItem(label: 'Add Dose', icon: Icons.add_circle_outlined, color: AppColors.primary, onTap: () async {
                setState(() => _fabOpen = false);
                await _showAddDoseSheet(context);
              }),
              const SizedBox(height: 12),
              _FabMenuItem(label: 'Add Tracker Entry', icon: Icons.favorite_outline, color: AppColors.accent, onTap: () {
                setState(() => _fabOpen = false);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrackerEntryScreen(
                        type: 'weight',
                        title: 'Weight',
                      ),
                    ),
                  );
                }
              }),
              const SizedBox(height: 12),
              _FabMenuItem(label: 'Add Medication', icon: Icons.medication_outlined, color: AppColors.primary, onTap: () {
                setState(() => _fabOpen = false);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicationScreen()));
              }),
              const SizedBox(height: 12),
            ],
            FloatingActionButton(
              onPressed: () => setState(() => _fabOpen = !_fabOpen),
              backgroundColor: AppColors.primary,
              child: Icon(_fabOpen ? Icons.close : Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required Color dotColor, VoidCallback? onViewAll}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
          ),
        ),
        TextButton.icon(
          onPressed: onViewAll,
          icon: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          label: const Text('View all', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _doseCard({required TodayDose dose, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                dose.taken
                    ? Icons.check_rounded
                    : (dose.doseLogId != null && !dose.isRescheduled
                        ? Icons.close_rounded
                        : Icons.medication_outlined),
                color: dose.taken
                    ? AppColors.success
                    : (dose.doseLogId != null && !dose.isRescheduled
                        ? AppColors.textSecondary
                        : AppColors.text),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dose.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Take ${dose.medication.dosage}',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dose.taken
                        ? 'Taken at ${_fmtTime(dose.time)}, today, ${_monthShort(DateTime.now().month)} ${DateTime.now().day}'
                        : (dose.doseLogId != null && !dose.isRescheduled
                            ? 'Skipped at ${_fmtTime(dose.time)}, today, ${_monthShort(DateTime.now().month)} ${DateTime.now().day}'
                            : 'Med isn\'t near me'),
                    style: TextStyle(
                      fontSize: 12,
                      color: dose.taken
                          ? AppColors.success
                          : (dose.doseLogId != null && !dose.isRescheduled
                              ? AppColors.textSecondary
                              : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _showAddDoseSheet(BuildContext context) async {
    final meds = context.read<MedicationsProvider>();
    if (meds.medications.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a medication first')),
        );
      }
      return;
    }

    String? selectedMedId = meds.medications.first.id;
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    String? errorText;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
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
                  const Text(
                    'Add Dose',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 20),
                  if (errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(errorText!, style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 14)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: selectedMedId,
                    decoration: InputDecoration(
                      labelText: 'Medication',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    items: meds.medications
                        .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name, style: const TextStyle(color: AppColors.text))))
                        .toList(),
                    onChanged: (v) => setSheetState(() => selectedMedId = v),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.secondary,
                                surface: AppColors.card,
                                onSurface: AppColors.text,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setSheetState(() => selectedTime = picked);
                        errorText = null;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Time',
                            style: TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedMedId == null) {
                          setSheetState(() => errorText = 'Please select a medication');
                          return;
                        }
                        final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                        final messenger = ScaffoldMessenger.of(sheetContext);
                        await meds.addDoseLog(selectedMedId!, _dateStr(DateTime.now()), timeStr);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(sheetContext);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Dose added')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.text,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Add Dose', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_rounded,
                  size: 56, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manage your meds',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your meds to be reminded on time and track your health',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
              child: const Text('Add a med',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FabMenuItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

class _RescheduleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _RescheduleButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? null : AppColors.card,
          gradient: isPrimary ? AppColors.primaryGradientH : null,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary ? null : Border.all(color: AppColors.border, width: 1),
          boxShadow: isPrimary
              ? [BoxShadow(color: AppColors.gradientStart.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _RescheduleSheetContent extends StatefulWidget {
  final TodayDose dose;
  final String dateStr;

  const _RescheduleSheetContent({required this.dose, required this.dateStr});

  @override
  State<_RescheduleSheetContent> createState() => _RescheduleSheetContentState();
}

class _RescheduleSheetContentState extends State<_RescheduleSheetContent> {
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final parts = widget.dose.time.split(':');
    _selectedHour = int.parse(parts[0]);
    _selectedMinute = int.parse(parts[1]);
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
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
              const Text(
                'Reschedule for',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _hourController,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedHour = index);
                      },
                      children: List.generate(24, (hour) {
                        return Center(
                          child: Text(
                            hour.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20, color: AppColors.text),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text(':', style: TextStyle(fontSize: 24, color: AppColors.text)),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _minuteController,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedMinute = index);
                      },
                      children: List.generate(60, (minute) {
                        return Center(
                          child: Text(
                            minute.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20, color: AppColors.text),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Today, ${_monthShort(DateTime.now().month)} ${DateTime.now().day}',
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _RescheduleButton(
                      label: 'CANCEL',
                      onTap: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RescheduleButton(
                      label: 'OK',
                      onTap: () async {
                        final newTime = '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
                        final meds = context.read<MedicationsProvider>();
                        await meds.rescheduleDose(widget.dose.medication.id, widget.dateStr, widget.dose.time, newTime);
                        if (mounted) Navigator.pop(context);
                      },
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
