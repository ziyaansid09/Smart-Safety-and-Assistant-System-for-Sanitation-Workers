import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/mode_select_screen.dart';
import 'screens/worker/worker_checkin_screen.dart';
import 'screens/worker/worker_home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/monitoring/monitoring_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait + landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Dark system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const SMCSafetyApp(),
    ),
  );
}

class SMCSafetyApp extends StatelessWidget {
  const SMCSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'SMC Smart Safety',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: provider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('mr'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppRouter(),
        );
      },
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        switch (provider.appMode) {
          case 'worker':
            return provider.isCheckedIn
                ? const WorkerHomeScreen()
                : const WorkerCheckInScreen();
          case 'admin':
            return const AdminDashboardScreen();
          case 'monitoring':
            return const MonitoringScreen();
          default:
            return const ModeSelectScreen();
        }
      },
    );
  }
}
