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
  final gradoFiltro = Rxn<String>();

  final gradosDisponibles = const [
    'Sexto', 'Septimo', 'Octavo', 'Noveno', 'Décimo', 'Once',
  ];

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
      final rawData = await _repo.obtenerTodosRaw();
      final datos = rawData.map((row) {
        final usuario = row['usuario'] as Map<String, dynamic>?;

        return <String, dynamic>{
          'id': row['id'],
          'nombre': usuario?['nombre'] ?? 'Sin nombre',
          'apellido': usuario?['apellido'] ?? '',
          'pin': row['pin'] ?? '0000',
          'identificacion': usuario?['identificacion']?.toString() ?? '',
          'avatarUrl': null,
          'grado': row['curso']?.toString(),
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

  void cambiarGradoFiltro(String? grado) {
    gradoFiltro.value = grado;
    filter();
  }

  void filter() {
    final query = searchController.text.toLowerCase().trim();
    final grado = gradoFiltro.value;

    estudiantesFiltrados.assignAll(
      todosLosEstudiantes.where((e) {
        final nombre = (e['nombre'] ?? '').toString().toLowerCase();
        final apellido = (e['apellido'] ?? '').toString().toLowerCase();
        final id = (e['id'] ?? '').toString().toLowerCase();
        final identificacion =
            (e['identificacion'] ?? '').toString().toLowerCase();
        final nombreCompleto = '$nombre $apellido';

        final matchesSearch = nombreCompleto.contains(query) ||
            id.contains(query) ||
            identificacion.contains(query);

        final matchesGrado = grado == null || e['grado'] == grado;

        return matchesSearch && matchesGrado;
      }).toList(),
    );
  }

  void changeTab(int index) {
    currentTab.value = index;
  }
}
