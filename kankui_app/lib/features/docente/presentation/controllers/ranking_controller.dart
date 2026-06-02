import 'package:get/get.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:kankui_app/features/docente/domain/models/estudiantes_model.dart';
import 'package:kankui_app/shared/data/user_progress.dart';

class _NivelSabiduria {
  final int nivel;
  final String nombre;
  final int xpRequerido;

  const _NivelSabiduria({
    required this.nivel,
    required this.nombre,
    required this.xpRequerido,
  });
}

const List<_NivelSabiduria> _nivelesSabiduria = [
  _NivelSabiduria(nivel: 1, nombre: 'Semilla', xpRequerido: 0),
  _NivelSabiduria(nivel: 2, nombre: 'Brote', xpRequerido: 100),
  _NivelSabiduria(nivel: 3, nombre: 'Raíz', xpRequerido: 300),
  _NivelSabiduria(nivel: 4, nombre: 'Hoja', xpRequerido: 600),
  _NivelSabiduria(nivel: 5, nombre: 'Flor', xpRequerido: 1000),
  _NivelSabiduria(nivel: 6, nombre: 'Fruto', xpRequerido: 1500),
  _NivelSabiduria(nivel: 7, nombre: 'Árbol', xpRequerido: 2500),
  _NivelSabiduria(nivel: 8, nombre: 'Bosque', xpRequerido: 4000),
];

class RankingController extends GetxController {
  final EstudianteRepository _repo = Get.find();

  final loading = true.obs;
  final ranking = <EstudianteModel>[].obs;
  final errorMessage = Rxn<String>();

  late UserProgress userProgress;

  void initWith(UserProgress progress) {
    userProgress = progress;
    cargarRanking();
  }

  Future<void> cargarRanking() async {
    loading.value = true;
    errorMessage.value = null;

    try {
      final data = await _repo.obtenerRankingGlobal();
      ranking.assignAll(data);
    } catch (e) {
      errorMessage.value = 'Error al cargar el ranking: ${e.toString()}';
      ranking.clear();
    } finally {
      loading.value = false;
    }
  }

  String obtenerNivelPorXP(int xp) {
    for (int i = _nivelesSabiduria.length - 1; i >= 0; i--) {
      if (xp >= _nivelesSabiduria[i].xpRequerido) {
        return _nivelesSabiduria[i].nombre;
      }
    }
    return _nivelesSabiduria.first.nombre;
  }

  int obtenerNivelNumeroPorXP(int xp) {
    for (int i = _nivelesSabiduria.length - 1; i >= 0; i--) {
      if (xp >= _nivelesSabiduria[i].xpRequerido) {
        return _nivelesSabiduria[i].nivel;
      }
    }
    return 1;
  }

  int calcularXPParaSiguienteNivel(int xpActual) {
    final nivelActual = obtenerNivelNumeroPorXP(xpActual);
    final siguienteIndex = nivelActual;
    if (siguienteIndex >= _nivelesSabiduria.length) return 0;
    return _nivelesSabiduria[siguienteIndex].xpRequerido - xpActual;
  }

  double calcularProgresoNivel(int xpActual) {
    final nivelActual = obtenerNivelNumeroPorXP(xpActual);
    final xpBase = nivelActual > 1
        ? _nivelesSabiduria[nivelActual - 2].xpRequerido
        : 0;
    final xpTope = _nivelesSabiduria[nivelActual - 1].xpRequerido;
    if (xpTope <= xpBase) return 1.0;
    return ((xpActual - xpBase) / (xpTope - xpBase)).clamp(0.0, 1.0);
  }
}
