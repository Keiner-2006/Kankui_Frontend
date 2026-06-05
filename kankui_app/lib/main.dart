import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kankui_app/shared/services/notificacion_service.dart';
import 'package:kankui_app/features/auth/presentation/views/login_screen.dart';
import 'package:kankui_app/features/learning/presentation/views/home_screen.dart';
import 'package:kankui_app/features/learning/presentation/views/lessons_screen.dart';
import 'package:kankui_app/features/learning/presentation/views/lesson_detail_screen.dart';
import 'package:kankui_app/features/quiz/presentation/views/quiz_screen.dart';
import 'package:kankui_app/features/quiz/presentation/views/quiz_question_screen.dart';
import 'package:kankui_app/features/quiz/domain/models/reto_model.dart' as quiz;
import 'package:kankui_app/features/docente/domain/models/reto_model.dart';
import 'package:kankui_app/features/qr_scanner/presentation/views/scanner_screen.dart';
import 'package:kankui_app/features/docente/presentation/views/docente_screen.dart';
import 'package:kankui_app/features/quiz/presentation/views/responder_reto_screen.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/service_locator.dart';
import 'package:kankui_app/shared/data/sync/sync_service.dart';
import 'package:kankui_app/features/auth/presentation/views/onboarding_screen.dart';
import 'package:kankui_app/features/auth/presentation/views/download_progress_screen.dart';
import 'shared/ui/bindings/app_bindings.dart';
import 'shared/core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
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
    return GetMaterialApp(
      title: 'Kankui - Lengua Kankuamo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: AppBindings(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const Root()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/lessons', page: () => const LessonsScreen()),
        GetPage(name: '/lesson-detail', page: () => const LessonDetailScreen()),
        GetPage(name: '/quiz', page: () => const QuizScreen()),
        GetPage(name: '/quiz-question', page: () {
          final args = Get.arguments as Map<String, dynamic>;
          return QuizQuestionScreen(
            reto: args['reto'] as quiz.RetoQuizModel,
            categoriaNombre: args['categoriaNombre'] as String?,
          );
        }),
        GetPage(name: '/scanner', page: () => const ScannerScreen()),
        GetPage(name: '/docente', page: () => DocenteScreen(profesor: Get.arguments as Profesor)),
        GetPage(name: '/responder-reto', page: () {
          final reto = Get.arguments as RetoModel;
          return ResponderRetoScreen(reto: reto);
        }),
      ],
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
  bool _showDownload = false;
  bool _checkingPrefs = true;

  @override
  void initState() {
    super.initState();
    _checkMediaStatus();
  }

  Future<void> _checkMediaStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getBool('media_downloaded') ?? false;
    final skipped = prefs.getBool('media_skipped') ?? false;
    setState(() {
      _checkingPrefs = false;
      _showDownload = !downloaded && !skipped;
    });
  }

  void _finishOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  void _finishDownload() {
    setState(() {
      _showDownload = false;
    });
  }

  void _skipDownload() {
    setState(() {
      _showDownload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPrefs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(
        onFinish: _finishOnboarding,
      );
    }

    if (_showDownload) {
      return DownloadProgressScreen(
        onComplete: _finishDownload,
        onSkip: _skipDownload,
      );
    }

    return const LoginScreen();
  }
}