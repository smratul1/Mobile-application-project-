import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class HealthContactsScreen extends StatefulWidget {
  const HealthContactsScreen({super.key});

  @override
  State<HealthContactsScreen> createState() => _HealthContactsScreenState();
}

class _HealthContactsScreenState extends State<HealthContactsScreen> {
  final List<Map<String, String>> _contacts = [
    {'name': 'Dr. Rahman', 'type': 'Cardiologist', 'phone': '+880 1711-000001'},
    {'name': 'City Hospital', 'type': 'Emergency', 'phone': '+880 2-9123456'},
  ];
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _addContact() {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() {
      _contacts.insert(0, {'name': _nameCtrl.text.trim(), 'type': _typeCtrl.text.trim(), 'phone': _phoneCtrl.text.trim()});
      _nameCtrl.clear();
      _typeCtrl.clear();
      _phoneCtrl.clear();
      _adding = false;
    });
  }

  void _deleteContact(int index) {
    setState(() => _contacts.removeAt(index));
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
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white)),
                  const Text('Health Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  IconButton(onPressed: _adding ? null : () => setState(() => _adding = !_adding), icon: const Icon(Icons.add, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_adding) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Column(
                          children: [
                            _InputField(controller: _nameCtrl, hint: 'Name'),
                            const SizedBox(height: 10),
                            _InputField(controller: _typeCtrl, hint: 'Specialty / Type'),
                            const SizedBox(height: 10),
                            _InputField(controller: _phoneCtrl, hint: 'Phone Number'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: ElevatedButton(onPressed: _addContact, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Save'))),
                                const SizedBox(width: 12),
                                Expanded(child: ElevatedButton(onPressed: () => setState(() => _adding = false), style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.text), child: const Text('Cancel'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ..._contacts.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_outlined, color: AppColors.textSecondary)),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.value['name']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                            Text(e.value['type']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            Text(e.value['phone']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ])),
                          IconButton(visualDensity: VisualDensity.compact, onPressed: () => _deleteContact(e.key), icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 18)),
                        ],
                      ),
                    )),
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _InputField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.textSecondary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
  }
}
