import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/medications_provider.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _sounds = true;
  bool _vibration = true;
  bool _doseFreq = true;
  bool _syncHealth = false;

  Future<void> _showAddReminderDialog(
      BuildContext context, MedicationsProvider meds) async {
    final nameCtrl = TextEditingController();
    String selectedTime = '09:00';
    String? error;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add custom reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dose name',
                    hintText: 'e.g. Missed morning pill',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text('Time: $selectedTime',
                          style: const TextStyle(fontSize: 15)),
                    ),
                    TextButton(
                      onPressed: () async {
                        final parts = selectedTime.split(':');
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.parse(parts[0]),
                            minute: int.parse(parts[1]),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    setState(() => error = 'Please enter a reminder name.');
                    return;
                  }
                  meds.addCustomReminder(CustomReminder(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    time: selectedTime,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text('Reminders & Settings',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  // User card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        const BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Row(children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(auth.currentUser?.name ?? 'User',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text)),
                            Text(auth.currentUser?.email ?? '',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                          ])),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: AppColors.destructive, size: 20),
                        onPressed: () async {
                          await auth.logout();
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ]),
                  ),

                  // Notifications section
                  _Section(title: 'NOTIFICATIONS', children: [
                    _Row(
                        label: 'Notification Sounds',
                        value: _sounds,
                        onChanged: (v) => setState(() => _sounds = v)),
                    const _Divider(),
                    _Row(
                        label: 'Vibration',
                        value: _vibration,
                        onChanged: (v) => setState(() => _vibration = v)),
                    const _Divider(),
                    _Row(
                        label: 'Dose Frequency',
                        value: _doseFreq,
                        onChanged: (v) => setState(() => _doseFreq = v)),
                  ]),

                  _Section(title: 'CUSTOM REMINDERS', children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                                'Add a reminder for a missed dose so you can be reminded again.',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5)),
                            const SizedBox(height: 10),
                            const Text(
                                'Each reminder includes a dose name and time, and can be deleted later.',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5)),
                            const SizedBox(height: 16),
                            Builder(builder: (context) {
                              final meds = context.watch<MedicationsProvider>();
                              final reminders = meds.customReminders;
                              return Column(
                                children: [
                                  if (reminders.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Text(
                                        'No custom reminders yet. Create one to remind yourself of missed doses.',
                                        style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 14,
                                            height: 1.4),
                                      ),
                                    )
                                  else
                                    Column(
                                      children: reminders.map((reminder) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: AppColors.card,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: AppColors.border,
                                                width: 1.5),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(reminder.name,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .text)),
                                                    const SizedBox(height: 4),
                                                    Text(reminder.time,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: AppColors
                                                                .textSecondary)),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline,
                                                    color:
                                                        AppColors.destructive),
                                                onPressed: () {
                                                  meds.removeCustomReminder(
                                                      reminder.id);
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add reminder'),
                                          onPressed: () =>
                                              _showAddReminderDialog(
                                                  context,
                                                  context.read<
                                                      MedicationsProvider>()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ]),
                    ),
                  ]),

                  // Integrations section
                  _Section(title: 'INTEGRATIONS', children: [
                    _Row(
                        label: 'Sync with Health App',
                        value: _syncHealth,
                        onChanged: (v) => setState(() => _syncHealth = v)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 6,
              offset: Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary)),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Row(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text)),
          Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.border);
}
