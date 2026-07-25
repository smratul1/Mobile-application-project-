import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'profile/add_dependent_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/invite_medfriend_screen.dart';
import 'auth/login_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final width = MediaQuery.of(context).size.width * 0.72;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.card,
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.card,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.person,
                            size: 28, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.currentUser?.name ?? 'Ratul',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                );
                              },
                              child: const Text('Edit Profile',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('Profiles',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  _DrawerTile(
                    icon: Icons.add,
                    iconColor: AppColors.success,
                    title: 'Add Dependent',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddDependentScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text('Medfriends',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  _DrawerTile(
                    icon: Icons.add,
                    iconColor: AppColors.success,
                    title: 'Invite Medfriend',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InviteMedfriendScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  _DrawerTile(
                    icon: Icons.grid_view_rounded,
                    iconColor: AppColors.textSecondary,
                    title: 'Verification Code',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _DrawerTile(
                    icon: Icons.login_rounded,
                    iconColor: AppColors.textSecondary,
                    title: 'Login',
                    onTap: () async {
                      await auth.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  const _DrawerTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
