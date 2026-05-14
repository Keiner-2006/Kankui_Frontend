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
import 'package:kankui_app/features/quiz/domain/models/reto_model.dart';
import 'package:kankui_app/features/qr_scanner/presentation/views/scanner_screen.dart';
import 'package:kankui_app/features/docente/presentation/views/docente_screen.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/service_locator.dart';
import 'package:kankui_app/shared/data/sync/sync_service.dart';
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
        GetPage(name: '/quiz-question', page: () {
          final args = Get.arguments as Map<String, dynamic>;
          return QuizQuestionScreen(
            reto: args['reto'] as RetoQuizModel,
            categoriaNombre: args['categoriaNombre'] as String?,
          );
        }),
        GetPage(name: '/scanner', page: () => const ScannerScreen()),
        GetPage(name: '/docente', page: () => DocenteScreen(profesor: Get.arguments as Profesor)),
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

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToPage(int page) {
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _nextPage() {
    _goToPage(_currentPage + 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: const [
          _OnboardingPage(title: "Bienvenido a Kankui", description: "Aprende vocabulario de forma divertida", icon: Icons.school),
          _OnboardingPage(title: "Practica cada día", description: "Refuerza tu aprendizaje con recordatorios", icon: Icons.notifications_active),
          _OnboardingPage(title: "Mide tu progreso", description: "Observa cómo avanzas cada día", icon: Icons.trending_up),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _currentPage == 2
            ? () {
                if (widget.onFinish != null) widget.onFinish!();
              }
            : _nextPage,
        child: Icon(_currentPage == 2 ? Icons.check : Icons.arrow_forward),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title; final String description; final IconData icon;
  const _OnboardingPage({required this.title, required this.description, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40), width: double.infinity,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 100, color: Colors.green),
        const SizedBox(height: 30),
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Text(description, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
      ]),
    );
  }
}
