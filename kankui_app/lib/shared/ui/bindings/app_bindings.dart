import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/sesionmanager.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/features/auth/data/repositories/usuario_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:kankui_app/features/quiz/data/repositories/quiz_repository.dart';
import 'package:kankui_app/features/qr_scanner/data/repositories/kankuama_info_repository.dart';
import 'package:kankui_app/shared/data/remote/supabase_service.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'package:kankui_app/shared/data/local/progress_repository.dart';
import 'package:kankui_app/shared/services/auth_services.dart';
import 'package:kankui_app/shared/services/docenteservices.dart';
import 'package:kankui_app/shared/services/audio_service.dart';
import 'package:kankui_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:kankui_app/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:kankui_app/features/learning/presentation/controllers/home_controller.dart';
import 'package:kankui_app/features/learning/presentation/controllers/lessons_controller.dart';
import 'package:kankui_app/features/learning/presentation/controllers/lesson_detail_controller.dart';
import 'package:kankui_app/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:kankui_app/features/quiz/presentation/controllers/quiz_question_controller.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/scanner_controller.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/recursos_qr_controller.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/kankuama_info_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/docente_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/ranking_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/inscribir_estudiante_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/grupo_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/reto_grupo_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/progreso_grupo_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    final supabase = Supabase.instance.client;

    Get.put(SessionManager(), permanent: true);
    Get.put(SupabaseService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(DocenteService(), permanent: true);
    Get.put(AudioService(), permanent: true);
    Get.put(UserRepository(), permanent: true);
    Get.put(ProgressRepository(), permanent: true);

    Get.lazyPut(() => CategoriaRepository(supabase));
    Get.lazyPut(() => UsuarioRepository(supabase));
    Get.lazyPut(() => EstudianteRepository(supabase));
    Get.lazyPut(() => QuizRepository());
    Get.lazyPut(() => KankuamaInfoRepository());

    Get.put(LoginController(), permanent: true);
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => LessonsController());
    Get.put(LessonDetailController(), permanent: true);
    Get.lazyPut(() => QuizController());
    Get.lazyPut(() => QuizQuestionController());
    Get.lazyPut(() => ScannerController());
    Get.lazyPut(() => DocenteController());
    Get.lazyPut(() => RecursosQrController());
    Get.lazyPut(() => KankuamaInfoController());
    Get.lazyPut(() => RankingController());
    Get.lazyPut(() => InscribirEstudianteController());
    Get.lazyPut(() => GrupoController());
    Get.lazyPut(() => RetoGrupoController());
    Get.lazyPut(() => ProgresoGrupoController());
  }
}
