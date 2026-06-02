import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/reto_grupo_model.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/data/repositories/reto_grupo_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/grupo_repository.dart';
import 'package:uuid/uuid.dart';

class RetoGrupoController extends GetxController {
  final RetoGrupoRepository _retoGrupoRepo =
      RetoGrupoRepository(Supabase.instance.client);
  final GrupoRepository _grupoRepo =
      GrupoRepository(Supabase.instance.client);

  final retosAsignados = <RetoGrupoModel>[].obs;
  final gruposDisponibles = <GrupoModel>[].obs;
  final cargando = true.obs;
  final guardando = false.obs;
  final error = Rxn<String>();

  Future<void> cargarRetosPorGrupo(String grupoId) async {
    cargando.value = true;
    try {
      final data = await _retoGrupoRepo.obtenerRetosPorGrupo(grupoId);
      retosAsignados.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar retos: $e';
    } finally {
      cargando.value = false;
    }
  }

  Future<void> cargarGrupos(String maestroId) async {
    try {
      final data = await _grupoRepo.obtenerGruposPorMaestro(maestroId);
      gruposDisponibles.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar grupos: $e';
    }
  }

  Future<void> asignarReto({
    required String retoId,
    required String grupoId,
    String? nombreReto,
    int? puntajeMaximo,
    DateTime? fechaLimite,
  }) async {
    guardando.value = true;
    try {
      final nuevo = RetoGrupoModel(
        id: const Uuid().v4(),
        retoId: retoId,
        grupoId: grupoId,
        nombreReto: nombreReto,
        puntajeMaximo: puntajeMaximo,
        fechaLimite: fechaLimite,
      );
      await _retoGrupoRepo.asignarRetoAGrupo(nuevo);
      await cargarRetosPorGrupo(grupoId);
    } catch (e) {
      error.value = 'Error al asignar reto: $e';
    } finally {
      guardando.value = false;
    }
  }

  Future<void> desactivarReto(String id, String grupoId) async {
    await _retoGrupoRepo.desactivarRetoDeGrupo(id);
    await cargarRetosPorGrupo(grupoId);
  }
}
