import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please fill all required fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().signup(
          _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      setState(() {
        final msg = e.toString();
        if (msg.contains('already_exists')) {
          _error = 'An account with this email already exists.';
        } else {
          _error = 'Signup failed. Please try again.';
        }
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient hero ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24, right: 24, bottom: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.medication_rounded, size: 42, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Create Account',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Start managing your medications',
                      style: TextStyle(fontSize: 16, color: Color(0xCCFFFFFF))),
                ],
              ),
            ),

            // ── Form ───────────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                        child: Text(_error!, style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 14)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildInput(_nameCtrl, 'Full Name', Icons.person_outline),
                    const SizedBox(height: 14),
                    _buildInput(_emailCtrl, 'Email', Icons.mail_outline, kb: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildInput(_passCtrl, 'Password', Icons.lock_outline, obscure: true),
                    const SizedBox(height: 20),
                    _GradientButton(label: 'Create Account', loading: _loading, onPressed: _handleSignup),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Already have an account? Log In',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 15)),
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

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? kb, bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: ctrl, keyboardType: kb, obscureText: obscure,
        textCapitalization: kb == null && !obscure ? TextCapitalization.words : TextCapitalization.none,
        style: const TextStyle(color: AppColors.text, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientH, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.gradientStart.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14), onTap: loading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}
