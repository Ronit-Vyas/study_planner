import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the users database via UserModel
  await UserModel.initDatabase();

  // Restore existing user session if any
  await AuthService.init();

  // Initialize local notifications for reminders & alerts
  await NotificationService.init();

  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}