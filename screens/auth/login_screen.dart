import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email');
      return;
    }
    if (_passCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter your password');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      setState(() {
        final msg = e.toString();
        if (msg.contains('no_account')) {
          _error = 'No account found. Please sign up first.';
        } else if (msg.contains('wrong_password')) {
          _error = 'Incorrect password. Please try again.';
        } else {
          _error = 'Login failed. Please try again.';
        }
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient hero ──────────────────────────────────────────
            Container(
              height: screenH * 0.42,
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/53b00508-2e5d-4c9f-92f0-bf69115795f9.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.medication_rounded, size: 48, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Smart Medicine', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Text('Reminder', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
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
                    _Input(controller: _emailCtrl, hint: 'Email / Phone', icon: Icons.person_outline, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _Input(
                      controller: _passCtrl, hint: 'Password', icon: Icons.lock_outline,
                      obscureText: !_showPass,
                      suffix: IconButton(
                        icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary, size: 20),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _GradientButton(label: 'Log In', loading: _loading, onPressed: _handleLogin),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                      child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15)),
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

// ── Shared form widgets ────────────────────────────────────────────────────────

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _Input({
    required this.controller, required this.hint, required this.icon,
    this.keyboardType, this.obscureText = false, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller, keyboardType: keyboardType, obscureText: obscureText,
        style: const TextStyle(color: AppColors.text, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffix, border: InputBorder.none,
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
          borderRadius: BorderRadius.circular(14),
          onTap: loading ? null : onPressed,
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
