import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _sound = prefs.getBool('sound') ?? true;
      _vibration = prefs.getBool('vibration') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
                  const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SettingTile(title: 'Notifications', subtitle: 'Enable push notifications', value: _notifications, onChanged: (v) { setState(() => _notifications = v); _save('notifications', v); }),
                  _SettingTile(title: 'Sound', subtitle: 'Medication reminder sound', value: _sound, onChanged: (v) { setState(() => _sound = v); _save('sound', v); }),
                  _SettingTile(title: 'Vibration', subtitle: 'Vibrate on reminders', value: _vibration, onChanged: (v) { setState(() => _vibration = v); _save('vibration', v); }),
                  _SettingTile(title: 'Dark Mode', subtitle: 'Use dark theme', value: _darkMode, onChanged: (v) { setState(() => _darkMode = v); _save('darkMode', v); }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ])),
          Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}
