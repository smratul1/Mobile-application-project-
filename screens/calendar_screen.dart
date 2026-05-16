import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/dose_log_model.dart';
import '../providers/medications_provider.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _year;
  late int _month;
  late String _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _selected = _fmt(now);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtStr(int y, int m, int d) =>
      '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  String _fmtTime(String t) {
    final p = t.split(':');
    final h = int.parse(p[0]);
    return '${h % 12 == 0 ? 12 : h % 12}:${p[1]} ${h >= 12 ? "PM" : "AM"}';
  }

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _showAddDoseDialog(
      BuildContext context, MedicationsProvider meds) async {
    if (meds.medications.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No medications yet'),
          content: const Text(
              'Please add a medication first before scheduling a dose.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      return;
    }

    String selectedMedId = meds.medications.first.id;
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final selectedMed =
              meds.medications.firstWhere((m) => m.id == selectedMedId);
          return AlertDialog(
            title: const Text('Schedule Dose'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMedId,
                  decoration: const InputDecoration(labelText: 'Medication'),
                  items: meds.medications
                      .map((med) => DropdownMenuItem(
                          value: med.id, child: Text(med.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedMedId = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: Text('Time: ${_formatTimeOfDay(selectedTime)}')),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                            context: context, initialTime: selectedTime);
                        if (picked != null)
                          setState(() => selectedTime = picked);
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                if (!selectedMed.times.contains(_formatTimeOfDay(selectedTime)))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(children: const [
                      Icon(Icons.star, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'This dose will be scheduled as a special dose.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary))),
                    ]),
                  ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final exists = meds.getDateDoses(_selected).any((dose) =>
                      dose.medication.id == selectedMedId &&
                      dose.time == _formatTimeOfDay(selectedTime));
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('A dose already exists for this time.')));
                    return;
                  }
                  meds.addDoseLog(DoseLogModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    medicationId: selectedMedId,
                    date: _selected,
                    time: _formatTimeOfDay(selectedTime),
                    taken: false,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Add Dose'),
              ),
            ],
          );
        });
      },
    );
  }

  String get _today => _fmt(DateTime.now());

  void _prevMonth() => setState(() {
        if (_month == 1) {
          _month = 12;
          _year--;
        } else {
          _month--;
        }
      });

  void _nextMonth() => setState(() {
        if (_month == 12) {
          _month = 1;
          _year++;
        } else {
          _month++;
        }
      });

  @override
  Widget build(BuildContext context) {
    final meds = context.watch<MedicationsProvider>();
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    int startOffset = firstDay.weekday - 1;

    final selectedDoses = meds.getDateDoses(_selected);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('Schedule',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  // ── Calendar card ────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      children: [
                        // Month nav
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    color: AppColors.text),
                                onPressed: _prevMonth),
                            Text('${_months[_month - 1]} $_year',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text)),
                            IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    color: AppColors.text),
                                onPressed: _nextMonth),
                          ],
                        ),
                        // Day headers
                        Row(
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                              .map((d) => Expanded(
                                    child: Center(
                                        child: Text(d,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    AppColors.textSecondary))),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        // Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7),
                          itemCount: startOffset + daysInMonth,
                          itemBuilder: (context, idx) {
                            if (idx < startOffset) return const SizedBox();
                            final day = idx - startOffset + 1;
                            final ds = _fmtStr(_year, _month, day);
                            final isSelected = ds == _selected;
                            final isToday = ds == _today;
                            final taken = meds.getTakenCount(ds);
                            final total = meds.getTotalCount(ds);
                            Color? dotColor;
                            if (total > 0) {
                              if (taken == total)
                                dotColor = AppColors.success;
                              else if (taken > 0)
                                dotColor = AppColors.gradientStart;
                              else if (ds.compareTo(_today) < 0)
                                dotColor = AppColors.destructive;
                              else
                                dotColor = AppColors.textSecondary;
                            }
                            return GestureDetector(
                              onTap: () => setState(() => _selected = ds),
                              child: Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: isToday && !isSelected
                                        ? Border.all(
                                            color: AppColors.primary, width: 2)
                                        : null,
                                  ),
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text('$day',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.text)),
                                        if (dotColor != null)
                                          Positioned(
                                            bottom: 3,
                                            child: Container(
                                                width: 4,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                    color: dotColor,
                                                    shape: BoxShape.circle)),
                                          ),
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Selected date doses ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selected == _today ? 'Today' : _selected,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text)),
                            TextButton.icon(
                              onPressed: () =>
                                  _showAddDoseDialog(context, meds),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(
                                  _selected == _today
                                      ? 'Add Dose'
                                      : 'Add Future Dose',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (selectedDoses.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.border, width: 1.5),
                            ),
                            child: const Center(
                                child: Text('No medications scheduled',
                                    style: TextStyle(
                                        color: AppColors.textSecondary))),
                          )
                        else
                          ...selectedDoses.map((dose) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.border, width: 1.5),
                                ),
                                child: Row(children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: dose.taken
                                              ? AppColors.success
                                              : AppColors.textSecondary,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(dose.medication.name,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text)),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          Expanded(
                                            child: Text(
                                                '${dose.medication.dosage} · ${_fmtTime(dose.time)}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors
                                                        .textSecondary)),
                                          ),
                                          if (dose.special)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text('Special',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.primary)),
                                            ),
                                        ]),
                                      ])),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: dose.taken
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFFFF3E0),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            dose.taken
                                                ? 'Taken'
                                                : _selected.compareTo(_today) <
                                                        0
                                                    ? 'Missed'
                                                    : 'Pending',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: dose.taken
                                                  ? const Color(0xFF388E3C)
                                                  : const Color(0xFFF57C00),
                                            ),
                                          ),
                                        ),
                                        if (dose.special &&
                                            dose.doseLogId != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 6),
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: AppColors.destructive,
                                                  size: 20),
                                              tooltip: 'Delete special dose',
                                              onPressed: () async {
                                                final confirmed =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        'Delete special dose'),
                                                    content: const Text(
                                                        'Remove this special dose from the selected date?'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: const Text(
                                                              'Cancel')),
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child: const Text(
                                                              'Delete')),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  meds.removeDoseLog(
                                                      dose.doseLogId!);
                                                }
                                              },
                                            ),
                                          ),
                                      ]),
                                ]),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
