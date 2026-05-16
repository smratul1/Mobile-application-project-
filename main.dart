import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/medications_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartMedicineApp());
}

class SmartMedicineApp extends StatelessWidget {
  const SmartMedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProxyProvider<AuthProvider, MedicationsProvider>(
          create: (_) => MedicationsProvider(),
          update: (_, auth, meds) =>
              (meds ?? MedicationsProvider())..updateUser(auth.currentUser?.email),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Medicine Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
