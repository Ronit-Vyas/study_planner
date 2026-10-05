import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'data/models/user_model.dart';
import 'providers/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'features/home/main_navigation_shell.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyPlannerApp());
}

/// Runs all async startup work and returns true when done.
Future<bool> _initApp() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await UserModel.initDatabase();
  await AuthService.init();
  await NotificationService.init();
  return true;
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Study Planner Pro',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: FutureBuilder<bool>(
              future: _initApp(),
              builder: (context, snapshot) {
                // ── Error state ──────────────────────────────────────────
                if (snapshot.hasError) {
                  return Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.redAccent, size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to start app',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // ── Loading / Splash ─────────────────────────────────────
                if (!snapshot.hasData) {
                  return const _SplashScreen();
                }

                // ── Ready: route based on auth state ─────────────────────
                if (AuthService.isLoggedIn) {
                  // Kick off data load after the widget tree is ready.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<AppProvider>().loadAll();
                  });
                  return const MainNavigationShell();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

/// Animated splash screen shown while the app initialises.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Study Planner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Setting up your workspace…',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
