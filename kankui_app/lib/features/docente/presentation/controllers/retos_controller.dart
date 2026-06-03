import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/reto_model.dart';
import 'package:kankui_app/features/docente/data/repositories/reto_repository.dart';
import 'package:uuid/uuid.dart';

class RetosController extends GetxController {
  final RetoRepository _repo = RetoRepository(Supabase.instance.client);

  final retos = <RetoModel>[].obs;
  final cargando = true.obs;
  final error = Rxn<String>();

  final gradosDisponibles = const [
    'Sexto', 'Septimo', 'Octavo', 'Noveno', 'Décimo', 'Once',
  ];

  @override
  void onInit() {
    super.onInit();
    cargarRetos();
  }

  Future<void> cargarRetos() async {
    cargando.value = true;
    try {
      final data = await _repo.obtenerTodos();
      retos.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar retos: $e';
    } finally {
      cargando.value = false;
    }
  }

  Future<void> crearReto({
    required String nombre,
    required String grado,
    int? puntajeMaximo,
    List<String>? preguntas,
  }) async {
    try {
      final nuevo = RetoModel(
        id: const Uuid().v4(),
        nombre: nombre,
        grado: grado,
        puntosMaximos: puntajeMaximo ?? 100,
        preguntas: preguntas,
      );
      await _repo.crear(nuevo);
      await cargarRetos();
    } catch (e) {
      error.value = 'Error al crear reto: $e';
    }
  }

  Future<void> eliminarReto(String id) async {
    try {
      await _repo.eliminar(id);
      await cargarRetos();
    } catch (e) {
      error.value = 'Error al eliminar reto: $e';
    }
  }
}
