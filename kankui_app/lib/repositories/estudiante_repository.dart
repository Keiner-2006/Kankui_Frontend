import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estudiantes_model.dart';
import 'dart:developer' as developer;

class EstudianteRepository {
  final SupabaseClient supabase;
  final String _tableName = 'estudiante';

  EstudianteRepository(this.supabase);

  // ==========================================
  // CREATE / UPDATE (Upsert)
  // Guarda un nuevo estudiante y devuelve el registro guardado (incluye PIN de la BD)
  // ==========================================
  Future<Estudiante?> guardarEstudiante(Estudiante estudiante) async {
    try {
      final List<dynamic> response = await supabase
          .from(_tableName)
          .insert(estudiante.toJson())
          .select()
          .timeout(const Duration(seconds: 10));

      if (response.isNotEmpty) {
        developer.log('Estudiante guardado exitosamente: ${estudiante.id}',
            name: 'EstudianteRepository');
        return Estudiante.fromJson(response.first);
      }
      return null;
    } catch (e) {
      developer.log('Error al guardar estudiante: $e',
          name: 'EstudianteRepository', error: e);
      rethrow; // Propaga el error para diagnóstico
    }
  }


Future<List<Estudiante>> obtenerRankingGlobal() async {
  try {
    final response = await supabase
        .from(_tableName)
        .select('''
          id,
          usuario_id,
          xp_total,
          racha_dias,
          lecciones_completadas_total,
          escaneos_exitosos,
          logros_desbloqueados,
          usuario:usuario_id (
            nombre,
            apellido
          )
        ''')
        .order('xp_total', ascending: false);

    return (response as List)
        .map((json) => Estudiante.fromJson(json))
        .toList();
  } catch (e, stack) {
    developer.log('Error ranking global: $e',
        name: 'EstudianteRepository', error: e, stackTrace: stack);
    return [];
  }
}
  // ==========================================
  // READ (Uno)
  // Obtiene un estudiante según el ID de usuario de autenticación
  // ==========================================
  Future<Estudiante?> obtenerPerfilEstudiante(String usuarioId) async {
    try {
      final data = await supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (data != null) {
        return Estudiante.fromJson(data);
      }
      return null;
    } catch (e) {
      developer.log('Error al buscar perfil ($usuarioId): $e',
          name: 'EstudianteRepository', error: e);
      return null;
    }
  }

  Future<List<Estudiante>> obtenerTodos() async {
    try {
      final response = await supabase
          .from(_tableName)
          .select('''
            id,
            usuario_id,
            pin,
            curso,
            xp_total,
            usuario:usuario_id (
              nombre,
              apellido
            )
          ''');

      print('📦 RAW RESPONSE: $response');

      return response.map<Estudiante>((json) => Estudiante.fromJson(json)).toList();
    } catch (e, stack) {
      print('❌ ERROR EN REPO: $e');
      print(stack);
      return [];
    }
  }

  // ==========================================
  // READ (Todos o Ranking)
  // Sirve para leaderboards o ver a todos los alumnos de un curso
  // ==========================================
  Future<List<Estudiante>> obtenerEstudiantesXCurso(String cursoId) async {
    try {
      final List<dynamic> response = await supabase
          .from(_tableName)
          .select()
          .eq('curso', cursoId)
          .order('xp_total', ascending: false);

      return response.map((json) => Estudiante.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error al listar estudiantes: $e',
          name: 'EstudianteRepository', error: e);
      return [];
    }
  }

  // ==========================================
  // UPDATE (Parcial)
  // ==========================================
  Future<bool> actualizarGamificacion({
    required String usuarioId,
    required int xpSumar,
    bool incrementarRacha = false,
  }) async {
    try {
      final modeloActual = await obtenerPerfilEstudiante(usuarioId);
      if (modeloActual == null) return false;

      final mapToUpdate = {
        'xp_total': modeloActual.xpTotal + xpSumar,
        'xp_hoy': modeloActual.xpHoy + xpSumar,
        'ultima_actividad': DateTime.now().toIso8601String(),
      };

      if (incrementarRacha) {
        mapToUpdate['racha_dias'] = modeloActual.rachaDias + 1;
      }

      await supabase
          .from(_tableName)
          .update(mapToUpdate)
          .eq('usuario_id', usuarioId);

      developer.log('Progreso de gamificación registrado ($usuarioId)',
          name: 'EstudianteRepository');
      return true;
    } catch (e) {
      developer.log('Error al sumar progreso de estudiante: $e',
          name: 'EstudianteRepository', error: e);
      return false;
    }
  }

  // ==========================================
  // DELETE
  // ==========================================
  Future<bool> eliminarEstudiante(String idEstudiante) async {
    try {
      await supabase.from(_tableName).delete().eq('id', idEstudiante);

      developer.log('Estudiante eliminado correctamente',
          name: 'EstudianteRepository');
      return true;
    } catch (e) {
      developer.log('Error eliminando estudiante: $e',
          name: 'EstudianteRepository', error: e);
      return false;
    }
  }
}
