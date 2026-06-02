import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kankui_app/shared/services/notificacion_service.dart';
import 'package:kankui_app/features/auth/presentation/views/login_screen.dart';
import 'package:kankui_app/features/learning/presentation/views/home_screen.dart';
import 'package:kankui_app/features/learning/presentation/views/lessons_screen.dart';
import 'package:kankui_app/features/learning/presentation/views/lesson_detail_screen.dart';
import 'package:kankui_app/features/quiz/presentation/views/quiz_screen.dart';
import 'package:kankui_app/features/quiz/presentation/views/quiz_question_screen.dart';
import 'package:kankui_app/features/quiz/presentation/views/quiz_resumen_screen.dart';
import 'package:kankui_app/features/qr_scanner/presentation/views/scanner_screen.dart';
import 'package:kankui_app/features/qr_scanner/presentation/views/kankuama_info_screen.dart';
import 'package:kankui_app/features/docente/presentation/views/docente_screen.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/service_locator.dart';
import 'package:kankui_app/shared/data/sync/sync_service.dart';
import 'package:kankui_app/features/auth/presentation/views/onboarding_screen.dart';
import 'shared/ui/bindings/app_bindings.dart';
import 'shared/core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
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
        GetPage(name: '/quiz-question', page: () => const QuizQuestionScreen()),
        GetPage(name: '/quiz-resumen', page: () => const QuizResumenScreen()),
        GetPage(name: '/scanner', page: () => const ScannerScreen()),
        GetPage(name: '/kankuama-info', page: () => const KankuamaInfoScreen()),
        GetPage(name: '/docente', page: () => const DocenteScreen()),
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
