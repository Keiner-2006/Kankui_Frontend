import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kankui_app/services/notificacion_service.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/service_locator.dart';
import 'data/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jghnbyuanxxhtpllazmq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpnaG5ieXVhbnh4aHRwbGxhem1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU1MTc5MzUsImV4cCI6MjA5MTA5MzkzNX0.fboYT3pGgMKXDmaKNvfYr9FJ94cxnaoEiKRwz_h6cTY',
  );

  setupLocator();

  await NotificationService.init();
  await locator<SyncService>().syncApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KankuiApp());
}

class KankuiApp extends StatelessWidget {
  const KankuiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kankui - Lengua Kankuamo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool _showOnboarding = true;

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onFinish: _finishOnboarding,
      );
    }

    return const LoginScreen();
  }
}