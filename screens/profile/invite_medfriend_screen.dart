import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class InviteMedfriendScreen extends StatefulWidget {
  const InviteMedfriendScreen({super.key});

  @override
  State<InviteMedfriendScreen> createState() => _InviteMedfriendScreenState();
}

class _InviteMedfriendScreenState extends State<InviteMedfriendScreen> {
  final _firstNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _shareMeds = true;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite sent'), backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                  const Text('Invite Medfriend',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  TextButton(onPressed: _loading ? null : _send,
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('SEND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 20),
                    const Text('A Medfriend is a family member or a friend that helps you remember to take your meds in case you forget.',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 24),
                    _Field(controller: _firstNameCtrl, label: 'First name', icon: Icons.person_outline, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),
                    const SizedBox(height: 16),
                    _Field(controller: _phoneCtrl, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _Field(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Share my meds with this Medfriend',
                              style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                        ),
                        Switch(
                          value: _shareMeds,
                          onChanged: (v) => setState(() => _shareMeds = v),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
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
