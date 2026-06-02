import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/sesionmanager.dart';
import 'package:kankui_app/shared/data/user_progress.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/shared/data/local/progress_repository.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'package:kankui_app/shared/data/sync/sync_service.dart';

class HomeController extends GetxController {
  final SessionManager _session = Get.find();
  final CategoriaRepository _categoriaRepo = Get.find();
  final ProgressRepository _progressRepo = Get.find();
  final UserRepository _userRepo = Get.find();

  final categorias = <CategoriaModel>[].obs;
  final loadingCategorias = true.obs;
  final currentNavIndex = 0.obs;
  final userProgress = Rxn<UserProgress>();
  final progresoCategorias = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserProgress();
    fetchData();
  }

  void _initializeUserProgress() {
    final usuario = _session.usuario;
    if (usuario != null) {
      userProgress.value = UserProgress(
        xpTotal: usuario.xpTotal,
        xpHoy: usuario.xpHoy,
        rachaDias: usuario.rachaDias,
        leccionesCompletadas: usuario.leccionesCompletadas,
        escaneoExitosos: usuario.escaneosExitosos,
        logrosDesbloqueados: usuario.logros,
      );
    } else {
      userProgress.value = const UserProgress();
    }
  }

  Future<void> fetchData() async {
    try {
      await _loadLocalUserProgress();

      try {
        final syncService = SyncService(Supabase.instance.client);
        await syncService.syncApp().timeout(const Duration(seconds: 6));
      } catch (_) {}

      final categorias = await _categoriaRepo.getCategorias();
      categorias.sort((a, b) => a.orden.compareTo(b.orden));
      this.categorias.assignAll(categorias);
    } catch (_) {
    } finally {
      loadingCategorias.value = false;
    }
  }

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
  }

  Future<void> refreshLocalProgress() => _loadLocalUserProgress();

  Future<void> refreshDashboard() async {
    await _loadLocalUserProgress();

    try {
      await SyncService(Supabase.instance.client)
          .syncProgressToSupabase()
          .timeout(const Duration(seconds: 6));
    } catch (_) {}

    await _loadLocalUserProgress();
  }

  Future<void> _loadLocalUserProgress() async {
    final estudiante = await _userRepo.getCurrentEstudiante();
    if (estudiante == null) return;

    userProgress.value = UserProgress(
      xpTotal: estudiante.xpTotal,
      xpHoy: estudiante.xpHoy,
      rachaDias: estudiante.rachaDias,
      leccionesCompletadas: estudiante.leccionesCompletadasTotal,
      escaneoExitosos: estudiante.escaneosExitosos,
      leccionesDesbloqueadas: estudiante.leccionesDesbloqueadas,
      logrosDesbloqueados: estudiante.logrosDesbloqueados,
      ultimaActividad: estudiante.ultimaActividad != null
          ? DateTime.tryParse(estudiante.ultimaActividad!)
          : null,
    );

    final usuario = await _userRepo.getCurrentUser();
    if (usuario == null) return;

    progresoCategorias.clear();
    final progresos =
        await _progressRepo.getProgresoCategoriasUsuario(usuario.id);
    for (var progreso in progresos) {
      if (progreso.totalLecciones > 0) {
        progresoCategorias[progreso.categoriaId] =
            progreso.leccionesCompletadas / progreso.totalLecciones;
      }
    }
  }
}
