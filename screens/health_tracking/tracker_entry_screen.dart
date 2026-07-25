import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../providers/trackers_provider.dart';

class TrackerEntryScreen extends StatefulWidget {
  final String type;
  final String title;
  final List<String> questions;

  const TrackerEntryScreen({
    super.key,
    required this.type,
    required this.title,
    this.questions = const [],
  });

  @override
  State<TrackerEntryScreen> createState() => _TrackerEntryScreenState();
}

class _TrackerEntryScreenState extends State<TrackerEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _answers = {};
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _unitForType(String type) {
    switch (type) {
      case 'weight':
        return 'kg';
      case 'blood_pressure':
        return 'mmHg';
      case 'pain_level':
        return '/10';
      default:
        return '';
    }
  }

  String _formatLabel(String type) {
    switch (type) {
      case 'blood_pressure':
        return 'Systolic/Diastolic (e.g. 120/80)';
      default:
        return 'Value';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      _formKey.currentState!.save();
      final trackers = context.read<TrackersProvider>();
      await trackers.addEntry(
        type: widget.type,
        title: widget.title,
        value: _valueController.text.trim(),
        unit: _unitForType(widget.type),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : _answers.values.join(', '),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackers = context.watch<TrackersProvider>();
    final previousEntries = trackers.entries
        .where((e) => e.type == widget.type)
        .toList();
    final formatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.title, style: const TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconForType(widget.type),
                          color: AppColors.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Log your ${widget.title.toLowerCase()}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.questions.isNotEmpty) ...[
                  const Text(
                    'Questions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: widget.questions.map((q) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: q,
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Please answer' : null,
                          onSaved: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              _answers[q] = v.trim();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  Text(
                    'Enter ${widget.title.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: _formatLabel(widget.type),
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter a value' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                const Text(
                  'Notes (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Any additional notes...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save ${widget.title}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                if (previousEntries.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Text(
                    'Previous entries',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: previousEntries.length,
                    itemBuilder: (context, i) {
                      final entry = previousEntries[i];
                      final unit = (entry.unit ?? '').isNotEmpty ? entry.unit! : '';
                      return Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await trackers.removeEntry(entry.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Entry deleted')),
                            );
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.destructive,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _iconForType(entry.type),
                                  color: AppColors.accent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${entry.value}${unit.isNotEmpty ? ' $unit' : ''}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    if (entry.notes != null && entry.notes!.isNotEmpty)
                                      Text(
                                        entry.notes!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                formatter.format(entry.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'blood_pressure':
      return Icons.favorite_border;
    case 'pain_level':
      return Icons.show_chart;
    default:
      return Icons.monitor_weight_outlined;
  }
}
