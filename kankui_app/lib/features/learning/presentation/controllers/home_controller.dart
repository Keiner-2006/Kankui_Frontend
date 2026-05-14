import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/sesionmanager.dart';
import 'package:kankui_app/shared/data/user_progress.dart';
import 'package:kankui_app/features/auth/domain/models/usuario_model.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/shared/data/sync/sync_service.dart';

class HomeController extends GetxController {
  final SessionManager _session = Get.find();
  final CategoriaRepository _categoriaRepo = Get.find();

  final categorias = <CategoriaModel>[].obs;
  final loadingCategorias = true.obs;
  final currentNavIndex = 0.obs;
  final userProgress = Rxn<UserProgress>();

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
      final usuario = _session.usuario;
      if (usuario != null) {
        try {
          final supabase = Supabase.instance.client;
          final data = await supabase
              .from('estudiante')
              .select('*, usuario:usuario_id(*)')
              .eq('usuario_id', usuario.id)
              .maybeSingle()
              .timeout(const Duration(seconds: 5));

          if (data != null) {
            final usuarioData = data['usuario'] as Map<String, dynamic>;
            final mergedData = Map<String, dynamic>.from(usuarioData);
            mergedData['xp_total'] = data['xp_total'] ?? 0;
            mergedData['xp_hoy'] = data['xp_hoy'] ?? 0;
            mergedData['racha_dias'] = data['racha_dias'] ?? 0;
            mergedData['lecciones_completadas'] =
                data['lecciones_completadas_total'] ?? 0;
            mergedData['escaneos_exitosos'] = data['escaneos_exitosos'] ?? 0;
            mergedData['logros'] = data['logros'] ?? [];

            final usuarioActualizado = UsuarioModel.fromJson(mergedData);
            _session.loginEstudiante(usuarioActualizado);

            userProgress.value = UserProgress(
              xpTotal: usuarioActualizado.xpTotal,
              xpHoy: usuarioActualizado.xpHoy,
              rachaDias: usuarioActualizado.rachaDias,
              leccionesCompletadas: usuarioActualizado.leccionesCompletadas,
              escaneoExitosos: usuarioActualizado.escaneosExitosos,
              logrosDesbloqueados: usuarioActualizado.logros,
            );
          } else {
            userProgress.value = UserProgress(
              xpTotal: usuario.xpTotal,
              xpHoy: usuario.xpHoy,
              rachaDias: usuario.rachaDias,
              leccionesCompletadas: usuario.leccionesCompletadas,
              escaneoExitosos: usuario.escaneosExitosos,
              logrosDesbloqueados: usuario.logros,
            );
          }
        } catch (_) {
          userProgress.value = UserProgress(
            xpTotal: usuario.xpTotal,
            xpHoy: usuario.xpHoy,
            rachaDias: usuario.rachaDias,
            leccionesCompletadas: usuario.leccionesCompletadas,
            escaneoExitosos: usuario.escaneosExitosos,
            logrosDesbloqueados: usuario.logros,
          );
        }
      }

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
}
