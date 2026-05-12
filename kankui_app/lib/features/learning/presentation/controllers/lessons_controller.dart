import 'package:get/get.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/shared/data/user_progress.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'package:kankui_app/shared/data/local/progress_repository.dart';

class LessonsController extends GetxController {
  final CategoriaRepository _categoriaRepo = Get.find();
  final UserRepository _userRepo = Get.find();
  final ProgressRepository _progressRepo = Get.find();

  final categorias = <CategoriaModel>[].obs;
  final loading = true.obs;
  final userProgress = Rxn<UserProgress>();
  final progresoCategorias = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategorias();
  }

  Future<void> fetchCategorias() async {
    try {
      final data = await _categoriaRepo.getCategorias();
      categorias.assignAll(data);

      final estudiante = await _userRepo.getCurrentEstudiante();
      if (estudiante != null) {
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
        if (usuario != null) {
          final progresos = await _progressRepo.getProgresoCategoriasUsuario(usuario.id);
          for (var p in progresos) {
            if (p.totalLecciones > 0) {
              progresoCategorias[p.categoriaId] =
                  p.leccionesCompletadas / p.totalLecciones;
            }
          }
        }
      }
    } catch (_) {}

    loading.value = false;
  }

  double calcularProgresoCategoria(String categoriaId) {
    return progresoCategorias[categoriaId] ?? 0.0;
  }
}
