import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AddDependentScreen extends StatefulWidget {
  const AddDependentScreen({super.key});

  @override
  State<AddDependentScreen> createState() => _AddDependentScreenState();
}

class _AddDependentScreenState extends State<AddDependentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  String _gender = 'Male';
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _birthDateCtrl.text = '${picked.day} ${_monthName(picked.month)} ${picked.year}');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dependent added'), backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 20),
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                    const Text('Add Dependent',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    TextButton(onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('DONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Manage meds for your family members',
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: const Icon(Icons.person, size: 44, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Field(controller: _firstNameCtrl, label: 'First name', icon: Icons.person_outline, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                    const SizedBox(height: 16),
                    _Field(controller: _lastNameCtrl, label: 'Last name', icon: Icons.person_outline),
                    const SizedBox(height: 16),
                    _GenderField(value: _gender, onChanged: (v) => setState(() => _gender = v)),
                    const SizedBox(height: 16),
                    _Field(
                      controller: _birthDateCtrl,
                      label: 'Birth date',
                      icon: Icons.cake_outlined,
                      readOnly: true,
                      onTap: _pickBirthDate,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.circle, size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(child: Text('Default color', style: TextStyle(fontSize: 15, color: AppColors.text))),
                          Container(width: 28, height: 28,
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'By clicking the "Done" button, you confirm that you received the consent of the dependent (when applicable) to the association of the dependent\'s personal information with their health information and confirm you have read and agreed to our Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      onTap: onTap,
      style: const TextStyle(fontSize: 16, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GenderField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.wc_rounded, size: 20, color: AppColors.textSecondary)),
          const SizedBox(width: 14),
          const Expanded(child: Text('Gender', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 15, color: AppColors.text),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ],
      ),
    );
  }
}
