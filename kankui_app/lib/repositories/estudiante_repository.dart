import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estudiantes_model.dart';
import 'dart:developer' as developer;

class EstudianteRepository {
  final SupabaseClient supabase;
  final String _tableName = 'estudiante';

  EstudianteRepository(this.supabase);

  // ==========================================
  // CREATE / UPDATE (Upsert)
  // Guarda un nuevo estudiante o sobreescribe uno existente si los IDs coinciden
  // ==========================================
  Future<bool> guardarEstudiante(Estudiante estudiante) async {
    try {
      await supabase.from(_tableName).upsert(estudiante.toJson());
      developer.log('Estudiante guardado exitosamente: ${estudiante.id}',
          name: 'EstudianteRepository');
      return true;
    } catch (e) {
      developer.log('Error al guardar estudiante: $e',
          name: 'EstudianteRepository', error: e);
      return false;
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
          usuario:usuario_id (
            nombre,
            Apellido
          )
        ''');

    print('📦 RAW RESPONSE: $response');

    return response.map<Estudiante>((json) {
      final usuario = json['usuario'];

      print('👀 JSON individual: $json');

      return Estudiante(
        id: json['id'],
        nombre: usuario != null ? usuario['nombre'] ?? 'Sin nombre' : 'Sin nombre',
        apellido: usuario != null ? usuario['Apellido'] ?? '' : '',
        pin: json['pin'] ?? '0000',
      );
    }).toList();

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
      // Ejemplo: Ordenados por XP Total (Mecánica de gamificación/Leaderboard)
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
