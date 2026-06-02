import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/learning/domain/models/progresoreto_model.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/domain/models/reto_grupo_model.dart';
import 'package:kankui_app/features/docente/data/repositories/progreso_grupo_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/grupo_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/reto_grupo_repository.dart';

class ProgresoGrupoController extends GetxController {
  final ProgresoGrupoRepository _progresoRepo =
      ProgresoGrupoRepository(Supabase.instance.client);
  final GrupoRepository _grupoRepo =
      GrupoRepository(Supabase.instance.client);
  final RetoGrupoRepository _retoGrupoRepo =
      RetoGrupoRepository(Supabase.instance.client);

  final grupos = <GrupoModel>[].obs;
  final retosDelGrupo = <RetoGrupoModel>[].obs;
  final progresoPorReto = <String, List<ProgresoRetoModel>>{}.obs;
  final promedioGrupo = 0.0.obs;
  final cargando = true.obs;
  final error = Rxn<String>();
  final grupoSeleccionado = Rxn<GrupoModel>();

  Future<void> cargarGrupos(String maestroId) async {
    cargando.value = true;
    try {
      final data = await _grupoRepo.obtenerGruposPorMaestro(maestroId);
      grupos.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar grupos: $e';
    } finally {
      cargando.value = false;
    }
  }

  Future<void> seleccionarGrupo(GrupoModel grupo) async {
    grupoSeleccionado.value = grupo;
    await Future.wait([
      cargarRetosDelGrupo(grupo.id),
      cargarPromedio(grupo.id),
    ]);
    await cargarProgresoDelGrupo(grupo.id);
  }

  Future<void> cargarRetosDelGrupo(String grupoId) async {
    try {
      final data = await _retoGrupoRepo.obtenerRetosPorGrupo(grupoId);
      retosDelGrupo.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar retos: $e';
    }
  }

  Future<void> cargarProgresoDelGrupo(String grupoId) async {
    try {
      final data = await _progresoRepo.obtenerProgresoPorGrupo(grupoId);
      progresoPorReto.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar progreso: $e';
    }
  }

  Future<List<ProgresoRetoModel>> cargarProgresoDeReto(String retoId) async {
    return await _progresoRepo.obtenerProgresoPorReto(retoId);
  }

  Future<void> cargarPromedio(String grupoId) async {
    final promedio = await _progresoRepo.obtenerPromedioGrupo(grupoId);
    promedioGrupo.value = promedio;
  }

  int estudiantesCompletaron(String retoId) {
    final progresos = progresoPorReto[retoId] ?? [];
    return progresos.where((p) => p.completado).length;
  }

  int totalEstudiantesEnReto(String retoId) {
    return (progresoPorReto[retoId] ?? []).length;
  }
}
