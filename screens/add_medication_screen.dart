import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/medication_model.dart';
import '../providers/medications_provider.dart';

const _frequencies = [
  {
    'key': 'daily',
    'label': 'Daily',
    'times': ['09:00']
  },
  {
    'key': 'twice_daily',
    'label': 'Twice Daily',
    'times': ['09:00', '21:00']
  },
  {
    'key': 'three_times_daily',
    'label': '3× Daily',
    'times': ['09:00', '13:00', '18:00']
  },
  {
    'key': 'four_times_daily',
    'label': '4× Daily',
    'times': ['06:00', '12:00', '18:00', '22:00']
  },
  {
    'key': 'weekly',
    'label': 'Weekly',
    'times': ['09:00']
  },
];

const _pillColors = [
  Color(0xFFE91E8C),
  Color(0xFFAB47BC),
  Color(0xFF7B1FA2),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
];

const _colorHex = [
  '#E91E8C',
  '#AB47BC',
  '#7B1FA2',
  '#1E88E5',
  '#43A047',
  '#FB8C00',
];

class AddMedicationScreen extends StatefulWidget {
  final MedicationModel? medication;
  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _pillCount = 1;
  String _frequency = 'daily';
  int _colorIdx = 0;
  late List<String> _times;
  String? _error;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final med = widget.medication!;
      _nameCtrl.text = med.name;
      _dosageCtrl.text = med.dosage;
      _notesCtrl.text = med.notes ?? '';
      _pillCount = med.pillCount;
      _frequency = med.frequency;
      _colorIdx = _colorHex.indexOf(med.color).clamp(0, _colorHex.length - 1);
      _times = [...med.times];
    } else {
      _times = List<String>.from(_frequencies
          .firstWhere((f) => f['key'] == _frequency)['times'] as List<String>);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({int? index}) async {
    final initial = index != null
        ? TimeOfDay(
            hour: int.parse(_times[index].split(':')[0]),
            minute: int.parse(_times[index].split(':')[1]))
        : const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      final formatted = _formatTimeOfDay(picked);
      if (index != null) {
        _times[index] = formatted;
      } else {
        if (!_times.contains(formatted)) _times.add(formatted);
      }
      _times.sort();
    });
  }

  void _removeTime(int index) {
    if (_times.length <= 1) return;
    setState(() {
      _times.removeAt(index);
    });
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a medication name');
      return;
    }
    if (_dosageCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the dosage');
      return;
    }
    if (_times.isEmpty) {
      setState(() => _error = 'Please choose at least one dose time');
      return;
    }

    final med = MedicationModel(
      id: widget.medication?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequency,
      times: List<String>.from(_times),
      pillCount: _pillCount,
      color: _colorHex[_colorIdx],
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (_isEditing) {
      context.read<MedicationsProvider>().updateMedication(med);
    } else {
      context.read<MedicationsProvider>().addMedication(med);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              bottom: 20,
            ),
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
                const Text('Add Medication',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                TextButton(
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Color(0xFFD32F2F), fontSize: 14)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _fieldLabel('MEDICATION NAME'),
                  _textField(_nameCtrl, 'e.g. Aspirin'),
                  _fieldLabel('DOSAGE'),
                  _textField(_dosageCtrl, 'e.g. 81mg'),
                  _fieldLabel('TIMES'),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Tap a time to edit it, or add more times for mixed day and night doses.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ..._times.asMap().entries.map((entry) {
                        final index = entry.key;
                        final time = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            GestureDetector(
                              onTap: () => _pickTime(index: index),
                              child: Text(time,
                                  style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _pickTime(index: index),
                              child: const Icon(Icons.edit,
                                  size: 16, color: AppColors.textSecondary),
                            ),
                            if (_times.length > 1) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => _removeTime(index),
                                child: const Icon(Icons.close,
                                    size: 16, color: AppColors.destructive),
                              ),
                            ],
                          ]),
                        );
                      }),
                      GestureDetector(
                        onTap: () => _pickTime(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.primary, width: 1.5),
                          ),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add,
                                    size: 18, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text('Add time',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ),
                      ),
                    ],
                  ),
                  _fieldLabel('PILLS PER DOSE'),
                  Row(
                      children: [1, 2, 3, 4]
                          .map((n) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () => setState(() => _pillCount = n),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _pillCount == n
                                          ? AppColors.primary
                                          : AppColors.card,
                                      borderRadius: BorderRadius.circular(14),
                                      border: _pillCount == n
                                          ? null
                                          : Border.all(
                                              color: AppColors.border,
                                              width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text('$n',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _pillCount == n
                                                    ? Colors.white
                                                    : AppColors.text))),
                                  ),
                                ),
                              ))
                          .toList()),
                  _fieldLabel('FREQUENCY'),
                  ..._frequencies.map((f) => GestureDetector(
                        onTap: () => setState(() {
                          _frequency = f['key'] as String;
                          _times =
                              List<String>.from(f['times'] as List<String>);
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: _frequency == f['key']
                                ? AppColors.secondary
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _frequency == f['key']
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(f['label'] as String,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _frequency == f['key']
                                          ? AppColors.primary
                                          : AppColors.text)),
                              if (_frequency == f['key'])
                                const Icon(Icons.check,
                                    color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      )),
                  _fieldLabel('COLOR'),
                  Row(
                    children: List.generate(
                        _pillColors.length,
                        (i) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => setState(() => _colorIdx = i),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: _pillColors[i],
                                      shape: BoxShape.circle),
                                  child: _colorIdx == i
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 18)
                                      : null,
                                ),
                              ),
                            )),
                  ),
                  _fieldLabel('NOTES (OPTIONAL)'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      style:
                          const TextStyle(color: AppColors.text, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Any special instructions...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.textSecondary)),
      );

  Widget _textField(TextEditingController ctrl, String hint) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.text, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );
}
