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
  Future<EstudianteModel?> guardarEstudiante(EstudianteModel estudiante) async {
    try {
      final List<dynamic> response = await supabase
          .from(_tableName)
          .insert(estudiante.toJson())
          .select()
          .timeout(const Duration(seconds: 10));

      if (response.isNotEmpty) {
        developer.log('Estudiante guardado exitosamente: ${estudiante.id}',
            name: 'EstudianteRepository');
        return EstudianteModel.fromJson(response.first);
      }
      return null;
    } catch (e) {
      developer.log('Error al guardar estudiante: $e',
          name: 'EstudianteRepository', error: e);
      rethrow; // Propaga el error para diagnóstico
    }
  }

  // ==========================================
  // READ (Uno)
  // Obtiene un estudiante según el ID de usuario de autenticación
  // ==========================================
  Future<EstudianteModel?> obtenerPerfilEstudiante(String usuarioId) async {
    try {
      final data = await supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (data != null) {
        return EstudianteModel.fromJson(data);
      }
      return null;
    } catch (e) {
      developer.log('Error al buscar perfil ($usuarioId): $e',
          name: 'EstudianteRepository', error: e);
      return null;
    }
  }

  // ==========================================
  // READ (Todos o Ranking)
  // Sirve para leaderboards o ver a todos los alumnos de un curso
  // ==========================================
  Future<List<EstudianteModel>> obtenerEstudiantesXCurso(String cursoId) async {
    try {
      // Ejemplo: Ordenados por XP Total (Mecánica de gamificación/Leaderboard)
      final List<dynamic> response = await supabase
          .from(_tableName)
          .select()
          .eq('curso', cursoId)
          .order('xp_total', ascending: false);

      return response.map((json) => EstudianteModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error al listar estudiantes: $e',
          name: 'EstudianteRepository', error: e);
      return [];
    }
  }

  // ==========================================
  // UPDATE (Parcial - Muy Útil para Acciones Específicas)
  // Revisa la base de datos para no enviar un objeto gigante si solo actualizas la racha
  // ==========================================
  Future<bool> actualizarGamificacion({
    required String usuarioId,
    required int xpSumar,
    bool incrementarRacha = false,
  }) async {
    try {
      // 1. Conseguimos el estado actual
      final modeloActual = await obtenerPerfilEstudiante(usuarioId);
      if (modeloActual == null) return false;

      // 2. Modificamos valores
      final mapToUpdate = {
        'xp_total': modeloActual.xpTotal + xpSumar,
        'xp_hoy': modeloActual.xpHoy + xpSumar,
        'ultima_actividad': DateTime.now().toIso8601String(),
      };

      if (incrementarRacha) {
        mapToUpdate['racha_dias'] = modeloActual.rachaDias + 1;
      }

      // 3. Enviamos actualización de columnas específicas
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
  // Elimina un estudiante de la tabla de estudiantes
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
