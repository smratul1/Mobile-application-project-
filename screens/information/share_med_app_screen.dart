import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ShareMedAppScreen extends StatelessWidget {
  const ShareMedAppScreen({super.key});

  Future<void> _invite(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite link copied to clipboard'), backgroundColor: AppColors.success));
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
                  const Text('Share Med_App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: Column(
                        children: [
                          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.workspace_premium_rounded, size: 32, color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          const Text('Share Med_App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
                          const SizedBox(height: 8),
                          const Text('Invite friends and family to manage medications together.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
                            _ShareOption(label: 'WhatsApp', icon: Icons.chat, color: const Color(0xFF25D366), onTap: () => _invite(context)),
                            _ShareOption(label: 'Messages', icon: Icons.message, color: AppColors.accent, onTap: () => _invite(context)),
                            _ShareOption(label: 'Email', icon: Icons.email_outlined, color: AppColors.primary, onTap: () => _invite(context)),
                            _ShareOption(label: 'Copy Link', icon: Icons.link, color: AppColors.textSecondary, onTap: () => _invite(context)),
                          ]),
                        ],
                      ),
                    ),
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

class _ShareOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ShareOption({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
