import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'dart:developer' as developer;

class GrupoRepository {
  final SupabaseClient supabase;
  final String _tableName = 'grupo';

  GrupoRepository(this.supabase);

  Future<List<GrupoModel>> obtenerGruposPorMaestro(String maestroId) async {
    try {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('maestro_id', maestroId)
          .eq('activo', true)
          .order('nombre', ascending: true);

      return (response as List).map((j) => GrupoModel.fromJson(j)).toList();
    } catch (e) {
      developer.log('Error al obtener grupos: $e',
          name: 'GrupoRepository', error: e);
      return [];
    }
  }

  Future<GrupoModel?> crearGrupo(GrupoModel grupo) async {
    try {
      final response = await supabase
          .from(_tableName)
          .insert(grupo.toJson())
          .select()
          .single();

      return GrupoModel.fromJson(response);
    } catch (e) {
      developer.log('Error al crear grupo: $e',
          name: 'GrupoRepository', error: e);
      rethrow;
    }
  }

  Future<bool> actualizarGrupo(GrupoModel grupo) async {
    try {
      await supabase
          .from(_tableName)
          .update(grupo.toJson())
          .eq('id', grupo.id);
      return true;
    } catch (e) {
      developer.log('Error al actualizar grupo: $e',
          name: 'GrupoRepository', error: e);
      return false;
    }
  }

  Future<bool> eliminarGrupo(String id) async {
    try {
      await supabase.from(_tableName).delete().eq('id', id);
      return true;
    } catch (e) {
      developer.log('Error al eliminar grupo: $e',
          name: 'GrupoRepository', error: e);
      return false;
    }
  }

  Future<bool> asignarEstudianteAGrupo(
      String estudianteId, String grupoId) async {
    try {
      await supabase
          .from('estudiante')
          .update({'grupo_id': grupoId})
          .eq('id', estudianteId);
      return true;
    } catch (e) {
      developer.log('Error al asignar estudiante a grupo: $e',
          name: 'GrupoRepository', error: e);
      return false;
    }
  }

  Future<List<GrupoModel>> obtenerTodos() async {
    try {
      final response =
          await supabase.from(_tableName).select().eq('activo', true);

      return (response as List).map((j) => GrupoModel.fromJson(j)).toList();
    } catch (e) {
      developer.log('Error al obtener todos los grupos: $e',
          name: 'GrupoRepository', error: e);
      return [];
    }
  }
}
