import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:kankui_app/features/docente/domain/models/estudiantes_model.dart';
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

  final todosLosEstudiantes = <EstudianteModel>[].obs;
  final estudiantesFiltrados = <EstudianteModel>[].obs;
  final cargando = true.obs;
  final error = Rxn<String>();
  final currentTab = 0.obs;
  final maestroId = Rxn<String>();

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
    _cargarMaestroId();
  }

  Future<void> _cargarMaestroId() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('maestro')
          .select('id')
          .eq('usuario_id', user.id)
          .maybeSingle();
      if (data != null) {
        maestroId.value = data['id'];
      }
    } catch (_) {}
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
      todosLosEstudiantes.assignAll(data);
      estudiantesFiltrados.assignAll(data);
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
        final nombre = '${e.nombre ?? ''} ${e.apellido ?? ''}'.toLowerCase();
        final id = e.id.toLowerCase();
        return nombre.contains(query) || id.contains(query);
      }).toList(),
    );
  }

  void changeTab(int index) {
    currentTab.value = index;
  }

  String nombreCompleto(EstudianteModel e) =>
      '${e.nombre ?? ''} ${e.apellido ?? ''}'.trim();

  String pinFormateado(EstudianteModel e) => 'K-${e.pin ?? ''}';
}
