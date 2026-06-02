import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/data/repositories/grupo_repository.dart';
import 'package:kankui_app/features/docente/domain/models/estudiantes_model.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:uuid/uuid.dart';

class GrupoController extends GetxController {
  final GrupoRepository _grupoRepo =
      GrupoRepository(Supabase.instance.client);
  final EstudianteRepository _estudianteRepo =
      EstudianteRepository(Supabase.instance.client);

  final grupos = <GrupoModel>[].obs;
  final estudiantesPorGrupo = <String, List<EstudianteModel>>{}.obs;
  final cargando = true.obs;
  final error = Rxn<String>();
  final grupoSeleccionado = Rxn<GrupoModel>();

  final nombreController = Rx<TextEditingController>(TextEditingController());
  final gradoController = Rx<String?>(null);
  final guardando = false.obs;

  @override
  void onClose() {
    nombreController.value.dispose();
    super.onClose();
  }

  Future<void> cargarGrupos(String maestroId) async {
    cargando.value = true;
    error.value = null;

    try {
      final data = await _grupoRepo.obtenerGruposPorMaestro(maestroId);
      grupos.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar grupos: $e';
    } finally {
      cargando.value = false;
    }
  }

  Future<void> crearGrupo(String nombre, String? grado, String maestroId,
      String? institucionId) async {
    guardando.value = true;
    try {
      final nuevo = GrupoModel(
        id: const Uuid().v4(),
        nombre: nombre,
        grado: grado,
        maestroId: maestroId,
        institucionId: institucionId,
      );
      await _grupoRepo.crearGrupo(nuevo);
      await cargarGrupos(maestroId);
    } catch (e) {
      error.value = 'Error al crear grupo: $e';
    } finally {
      guardando.value = false;
    }
  }

  void seleccionarGrupo(GrupoModel grupo) {
    grupoSeleccionado.value = grupo;
  }

  Future<void> cargarEstudiantesDeGrupo(String grupoId) async {
    try {
      final todos = await _estudianteRepo.obtenerTodos();
      final filtrados =
          todos.where((e) => e.grupo?.toString() == grupoId).toList();
      estudiantesPorGrupo[grupoId] = filtrados;
    } catch (e) {
      developer.log('Error al cargar estudiantes del grupo: $e',
          name: 'GrupoController', error: e);
    }
  }
}
