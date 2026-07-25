import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/medications_provider.dart';
import 'providers/trackers_provider.dart';
import 'providers/appointments_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase OK");
  } catch (e) {
    print("Firebase Init ERROR => $e");
  }

  try {
    await NotificationService().init();
    print("NotificationService OK");
  } catch (e) {
    print("NotificationService ERROR => $e");
  }

  runApp(const SmartMedicineApp());
}

class SmartMedicineApp extends StatelessWidget {
  const SmartMedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..init(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MedicationsProvider>(
          create: (_) => MedicationsProvider(),
          update: (_, auth, meds) =>
              (meds ?? MedicationsProvider())
                ..updateUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TrackersProvider>(
          create: (_) => TrackersProvider(),
          update: (_, auth, trackers) =>
              (trackers ?? TrackersProvider())
                ..updateUser(auth.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppointmentsProvider>(
          create: (_) => AppointmentsProvider(),
          update: (_, auth, appointments) =>
              (appointments ?? AppointmentsProvider())
                ..updateUser(auth.uid),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Medicine Reminder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(),
      ),
        home: const SplashScreen(),
      ),
    );
  }
}
