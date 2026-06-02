import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';

class DocenteController extends GetxController {
  final EstudianteRepository _repo =
      EstudianteRepository(Supabase.instance.client);

  final todosLosEstudiantes = <Map<String, dynamic>>[].obs;
  final estudiantesFiltrados = <Map<String, dynamic>>[].obs;
  final cargando = true.obs;
  final error = Rxn<String>();
  final currentTab = 0.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(filter);
    cargarEstudiantes();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> cargarEstudiantes() async {
    cargando.value = true;
    error.value = null;

    try {
      final data = await _repo.obtenerTodos();
      final datos = data.map((e) {
        return {
          'id': e.id,
          'nombre': e.nombre ?? 'Sin nombre',
          'apellido': e.apellido ?? '',
          'pin': e.pin ?? '0000',
          'identificacion': e.identificacion,
          'avatarUrl': null,
        };
      }).toList();

      todosLosEstudiantes.assignAll(datos);
      estudiantesFiltrados.assignAll(datos);
      filter();
    } catch (e) {
      error.value = 'Error cargando estudiantes: $e';
    } finally {
      cargando.value = false;
    }
  }

  void filter() {
    final query = searchController.text.toLowerCase().trim();
    estudiantesFiltrados.assignAll(
      todosLosEstudiantes.where((e) {
        final nombre = (e['nombre'] ?? '').toString().toLowerCase();
        final apellido = (e['apellido'] ?? '').toString().toLowerCase();
        final id = (e['id'] ?? '').toString().toLowerCase();
        final identificacion =
            (e['identificacion'] ?? '').toString().toLowerCase();
        final nombreCompleto = '$nombre $apellido';

        return nombreCompleto.contains(query) ||
            id.contains(query) ||
            identificacion.contains(query);
      }).toList(),
    );
  }

  void changeTab(int index) {
    currentTab.value = index;
  }
}