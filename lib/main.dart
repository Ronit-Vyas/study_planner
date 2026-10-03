import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'providers/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'features/home/main_navigation_shell.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await UserModel.initDatabase();
  await AuthService.init();
  await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..loadAll(),
      child: const StudyPlannerApp(),
    ),
  );
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
<<<<<<< HEAD
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Study Planner',
    theme: AppTheme.darkTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: ThemeMode.dark,
    home: AuthService.isLoggedIn ? const AppShell() : const LoginScreen(),
  );
=======
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Study Planner Pro',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AuthService.isLoggedIn
              ? const MainNavigationShell()
              : const LoginScreen(),
        );
      },
    );
  }
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
}
