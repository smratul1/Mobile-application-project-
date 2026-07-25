import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _zipCodeCtrl = TextEditingController();
  String _gender = 'Male';
  bool _loading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      final parts = user.name.split(' ');
      _firstNameCtrl.text = parts.isNotEmpty ? parts.first : '';
      _lastNameCtrl.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      if (user.birthDate != null) {
        _birthDateCtrl.text = user.birthDate!;
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthDateCtrl.dispose();
    _zipCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 80);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppColors.destructive),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final fullName = '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
      String? photoUrl = context.read<AuthProvider>().currentUser?.photoUrl;
      if (_imageFile != null) {
        photoUrl = _imageFile!.path;
      }
      final birthDate = _birthDateCtrl.text.trim().isEmpty ? null : _birthDateCtrl.text.trim();
      await context.read<AuthProvider>().updateProfile(name: fullName, photoUrl: photoUrl, birthDate: birthDate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: AppColors.destructive),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit profile image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 20),
              _ImageOptionButton(
                label: 'Choose avatar',
                icon: Icons.person_rounded,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 12),
              _ImageOptionButton(
                label: 'Choose from photos',
                icon: Icons.photo_library_rounded,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 12),
              _ImageOptionButton(
                label: 'Take photo',
                icon: Icons.camera_alt_rounded,
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
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
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Edit Profile',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    TextButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary,
                                border: Border.all(color: AppColors.border, width: 2),
                              ),
                              child: _imageFile != null
                                  ? ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover, width: 100, height: 100))
                                  : const Icon(Icons.person, size: 48, color: AppColors.textSecondary),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ProfileField(
                        label: 'First name',
                        controller: _firstNameCtrl,
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _ProfileField(
                        label: 'Last name',
                        controller: _lastNameCtrl,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _GenderField(value: _gender, onChanged: (v) => setState(() => _gender = v)),
                      const SizedBox(height: 16),
                      _ProfileField(
                        label: 'Birth date',
                        controller: _birthDateCtrl,
                        icon: Icons.cake_outlined,
                        readOnly: true,
                        onTap: () async {
                          final now = DateTime.now();
                          DateTime initial = now;
                          if (_birthDateCtrl.text.isNotEmpty) {
                            try {
                              final parts = _birthDateCtrl.text.split(' ');
                              if (parts.length == 3) {
                                final day = int.parse(parts[0]);
                                final month = _monthIndex(parts[1]);
                                final year = int.parse(parts[2]);
                                initial = DateTime(year, month, day);
                              }
                            } catch (_) {}
                          }
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime(1900),
                            lastDate: now,
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: AppColors.primary,
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              _birthDateCtrl.text = '${picked.day} ${_monthName(picked.month)} ${picked.year}';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _ProfileField(
                        label: 'Zip code',
                        controller: _zipCodeCtrl,
                        icon: Icons.location_on_outlined,
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
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.circle, size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text('Default color',
                                  style: TextStyle(fontSize: 15, color: AppColors.text)),
                            ),
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'By clicking the "Save" button, you confirm that you received the consent of the dependent (when applicable) to the association of the dependent\'s personal information with their health information and confirm you have read and agreed to our Terms and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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

  int _monthIndex(String name) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months.indexOf(name) + 1;
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    required this.controller,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
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
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wc_rounded, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text('Gender', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
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

class _ImageOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ImageOptionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
           color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
