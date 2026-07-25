import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import './core/medications_screen.dart';
import './health_tracking/tracker_entry_screen.dart';
import './health_tracking/appointments_screen.dart';
import './subscription_screen.dart';
import './health_tracking/diary_notes_screen.dart';
import './health_tracking/health_contacts_screen.dart';
import './medication_management/refills_screen.dart';
import './information/reports_screen.dart';
import './app_settings_screen.dart';
import './auth/signup_screen.dart';
import './information/reminders_troubleshooting_screen.dart';
import './information/help_center_screen.dart';
import './information/share_med_app_screen.dart';
import './auth/login_screen.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               child: Row(
                 children: [
                   GestureDetector(
                     onTap: () => Navigator.maybePop(context),
                     child: Container(
                       width: 32,
                       height: 32,
                       decoration: BoxDecoration(
                         color: AppColors.card,
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: AppColors.border),
                       ),
                       child: const Icon(Icons.chevron_left,
                           size: 18, color: AppColors.textSecondary),
                     ),
                   ),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('Manage',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ManageTile(
                    icon: Icons.card_membership_outlined,
                     title: 'Med_App Subscription',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.medication_rounded,
                    title: 'Medications',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MedicationsScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Health Trackers & Measurements',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrackerEntryScreen(
                              type: 'weight',
                              title: 'Health Trackers',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.calendar_month_rounded,
                    title: 'Appointments',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AppointmentsScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.description_outlined,
                    title: 'Diary Notes',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DiaryNotesScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.contacts_outlined,
                    title: 'Health Contacts',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HealthContactsScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.local_pharmacy_outlined,
                    title: 'Refills',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RefillsScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

             const SizedBox(height: 10),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               child: GestureDetector(
                 onTap: () {
                   if (context.mounted) {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (_) => const ReportsScreen()),
                     );
                   }
                 },
                 child: Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(14),
                   decoration: BoxDecoration(
                     color: AppColors.card,
                     borderRadius: BorderRadius.circular(14),
                     border: Border.all(color: AppColors.border, width: 1),
                   ),
                   child: Row(
                     children: [
                       Container(
                         width: 40,
                         height: 40,
                         decoration: BoxDecoration(
                           color: AppColors.secondary,
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: const Icon(Icons.assignment_outlined,
                             size: 20, color: AppColors.textSecondary),
                       ),
                       const SizedBox(width: 14),
                       const Expanded(
                         child: Text('Report',
                             style: TextStyle(
                                 fontSize: 15,
                                 fontWeight: FontWeight.w500,
                                 color: AppColors.text)),
                       ),
                       const Icon(Icons.chevron_right,
                           size: 18, color: AppColors.textSecondary),
                     ],
                   ),
                 ),
               ),
             ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Settings',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ManageTile(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AppSettingsScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.person_add_alt_1_outlined,
                    title: 'Create Account',
                    subtitle: 'Sign up to backup your data',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Reminders Troubleshooting',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RemindersTroubleshootingScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HelpCenterScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ManageTile(
                    icon: Icons.share_outlined,
                    title: 'Share Med_App',
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShareMedAppScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await auth.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout_outlined,
                                size: 20,
                                color: AppColors.destructive),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text('Logout',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.destructive)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _ManageTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
