import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../providers/appointments_provider.dart';
import '../../models/appointment_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;
  bool _isSaving = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final provider = context.read<AppointmentsProvider>();
      final timeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      await provider.addAppointment(
        title: _titleController.text.trim(),
        date: _selectedDate,
        time: timeStr,
        doctor: _doctorController.text.trim().isNotEmpty ? _doctorController.text.trim() : null,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        reminderEnabled: _reminderEnabled,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment saved')),
        );
        _titleController.clear();
        _doctorController.clear();
        _locationController.clear();
        _notesController.clear();
        setState(() => _showForm = false);
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

  void _toggleComplete(AppointmentModel appointment) {
    final provider = context.read<AppointmentsProvider>();
    provider.completeAppointment(appointment.id);
  }

  void _delete(AppointmentModel appointment) {
    final provider = context.read<AppointmentsProvider>();
    provider.removeAppointment(appointment.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentsProvider>();
    final appointments = provider.appointments;
    final formatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Appointments', style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                setState(() => _showForm = !_showForm);
              },
              icon: Icon(
                _showForm ? Icons.close : Icons.add,
                color: AppColors.primary,
              ),
              label: Text(
                _showForm ? 'Cancel' : 'New',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showForm) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Appointment',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Appointment title',
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatter.format(_selectedDate),
                                        style: const TextStyle(fontSize: 14, color: AppColors.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 18, color: AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        TimeOfDay(hour: _selectedTime.hour, minute: _selectedTime.minute)
                                            .format(context),
                                        style: const TextStyle(fontSize: 14, color: AppColors.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: _reminderEnabled,
                              onChanged: (v) =>
                                  setState(() => _reminderEnabled = v ?? true),
                              activeColor: AppColors.primary,
                            ),
                            const Expanded(
                              child: Text(
                                'Set reminder on appointment day',
                                style: TextStyle(fontSize: 14, color: AppColors.text),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _doctorController,
                          decoration: const InputDecoration(
                            labelText: 'Doctor (optional)',
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location (optional)',
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            labelStyle: TextStyle(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                : const Text(
                                    'Save Appointment',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              appointments.isEmpty && !_showForm
                  ? _EmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appointments.length,
                      itemBuilder: (context, i) {
                        final appointment = appointments[i];
                        final timeStr = appointment.time != null
                            ? TimeOfDay(
                                hour: int.tryParse(appointment.time!.split(':')[0]) ?? 0,
                                minute: int.tryParse(appointment.time!.split(':')[1]) ?? 0,
                              ).format(context)
                            : 'All day';
                        return Dismissible(
                          key: ValueKey(appointment.id),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              _delete(appointment);
                              return false;
                            }
                            return false;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: appointment.isCompleted
                                    ? AppColors.success
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: appointment.isCompleted
                                        ? AppColors.success.withOpacity(0.15)
                                        : AppColors.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: appointment.isCompleted
                                        ? AppColors.success
                                        : AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: appointment.isCompleted
                                              ? AppColors.textSecondary
                                              : AppColors.text,
                                          decoration: appointment.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$timeStr • ${formatter.format(appointment.date)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: appointment.isCompleted
                                              ? AppColors.textSecondary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _toggleComplete(appointment),
                                  icon: Icon(
                                    appointment.isCompleted
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: appointment.isCompleted
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No appointments yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap New to schedule your next appointment',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
