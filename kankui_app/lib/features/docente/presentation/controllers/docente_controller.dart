import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:kankui_app/shared/services/docenteservices.dart';

class Profesor {
  final String nombre;
  final String apellido;
  final String correo;
  final String institucion;
  final String? avatarUrl;

  const Profesor({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.institucion,
    this.avatarUrl,
  });
}

class DocenteController extends GetxController {
  final EstudianteRepository _repo = EstudianteRepository(Supabase.instance.client);
  final DocenteService _docenteService = Get.find();

  final todosLosEstudiantes = <Map<String, dynamic>>[].obs;
  final estudiantesFiltrados = <Map<String, dynamic>>[].obs;
  final cargando = true.obs;
  final error = Rxn<String>();
  final currentTab = 0.obs;

  final searchController = TextEditingController();
  late Profesor profesor;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Profesor) {
      profesor = args;
    } else {
      profesor = const Profesor(
        nombre: 'Docente',
        apellido: '',
        correo: '',
        institucion: 'I.E. Indígena Atánquez',
      );
    }
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
      final datos = data.map((e) => e.toJson()).toList();
      todosLosEstudiantes.assignAll(datos);
      estudiantesFiltrados.assignAll(datos);
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
        final id = (e['id'] ?? '').toString().toLowerCase();
        return nombre.contains(query) || id.contains(query);
      }).toList(),
    );
  }

  void changeTab(int index) {
    currentTab.value = index;
  }
}
