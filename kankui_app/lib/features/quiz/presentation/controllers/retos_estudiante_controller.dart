import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/sesionmanager.dart';
import 'package:kankui_app/features/docente/domain/models/reto_model.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'dart:developer' as developer;

class RetoConEstado {
  final RetoModel reto;
  final bool completado;
  final int puntosObtenidos;

  RetoConEstado({
    required this.reto,
    this.completado = false,
    this.puntosObtenidos = 0,
  });
}

class RetosEstudianteController extends GetxController {
  final SessionManager _session = Get.find();
  final UserRepository _userRepo = Get.find();
  final SupabaseClient _supabase = Supabase.instance.client;

  final retos = <RetoConEstado>[].obs;
  final cargando = true.obs;
  final error = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    cargarRetos();
  }

  Future<void> cargarRetos() async {
    cargando.value = true;
    error.value = null;

    try {
      final usuario = _session.usuario;
      if (usuario == null) {
        error.value = 'Sesión no iniciada';
        return;
      }

      final estudiante = await _userRepo.getCurrentEstudiante();
      if (estudiante == null) {
        error.value = 'Estudiante no encontrado';
        return;
      }

      String? gradoEstudiante = estudiante.curso;

      if (gradoEstudiante == null || gradoEstudiante.isEmpty) {
        final supabaseEstudiante = await _supabase
            .from('estudiante')
            .select('curso')
            .eq('usuario_id', usuario.id)
            .maybeSingle();

        if (supabaseEstudiante != null) {
          gradoEstudiante = supabaseEstudiante['curso']?.toString();
        }
      }

      if (gradoEstudiante == null || gradoEstudiante.isEmpty) {
        developer.log('No se encontró curso/grado para el estudiante',
            name: 'RetosEstudiante');
        retos.value = [];
        cargando.value = false;
        return;
      }

      developer.log('Buscando retos para grado: $gradoEstudiante',
          name: 'RetosEstudiante');
      final response = await _supabase
          .from('reto')
          .select()
          .eq('grado', gradoEstudiante)
          .order('created_at', ascending: false);

      developer.log('Retos encontrados: ${(response as List).length}',
          name: 'RetosEstudiante');

      final retosDb =
          (response).map((j) => RetoModel.fromJson(j)).toList();

      final retosConEstado = <RetoConEstado>[];
      for (final reto in retosDb) {
        bool completado = false;
        int puntos = 0;

        try {
          final progreso = await _supabase
              .from('progreso_reto')
              .select('completado, puntos_obtenidos')
              .eq('reto_id', reto.id)
              .eq('usuario_id', usuario.id)
              .maybeSingle();

          if (progreso != null) {
            completado = progreso['completado'] == true;
            puntos = progreso['puntos_obtenidos'] ?? 0;
          }
        } catch (_) {}

        retosConEstado.add(RetoConEstado(
          reto: reto,
          completado: completado,
          puntosObtenidos: puntos,
        ));
      }

      retos.assignAll(retosConEstado);
    } catch (e) {
      developer.log('Error cargando retos: $e', name: 'RetosEstudiante');
      error.value = 'Error: $e';
    } finally {
      cargando.value = false;
    }
  }

  void responderReto(RetoConEstado retoConEstado) {
    Get.toNamed('/responder-reto', arguments: retoConEstado.reto)?.then((_) {
      cargarRetos();
    });
  }

  Future<void> enviarRespuesta(String retoId, String respuesta) async {
    final usuario = _session.usuario;
    if (usuario == null) return;

    await _supabase.from('progreso_reto').upsert({
      'usuario_id': usuario.id,
      'reto_id': retoId,
      'respuesta': respuesta,
      'completado': true,
      'fecha_completado': DateTime.now().toIso8601String(),
    }, onConflict: 'usuario_id,reto_id');
  }

  List<RetoConEstado> get retosPendientes =>
      retos.where((r) => !r.completado).toList();

  List<RetoConEstado> get retosCompletados =>
      retos.where((r) => r.completado).toList();
}
