import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/reto_grupo_model.dart';
import 'dart:developer' as developer;

class RetoGrupoRepository {
  final SupabaseClient supabase;
  final String _tableName = 'reto_grupo';

  RetoGrupoRepository(this.supabase);

  Future<List<RetoGrupoModel>> obtenerRetosPorGrupo(String grupoId) async {
    try {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('grupo_id', grupoId)
          .eq('activo', true)
          .order('orden', ascending: true);

      return (response as List)
          .map((j) => RetoGrupoModel.fromJson(j))
          .toList();
    } catch (e) {
      developer.log('Error al obtener retos del grupo: $e',
          name: 'RetoGrupoRepository', error: e);
      return [];
    }
  }

  Future<List<RetoGrupoModel>> obtenerRetosPorMaestro(String maestroId) async {
    try {
      final response = await supabase.from(_tableName).select('''
          *,
          grupo:grupo_id (
            nombre,
            grado
          )
        ''').eq('grupo.maestro_id', maestroId).eq('activo', true);

      return (response as List)
          .map((j) => RetoGrupoModel.fromJson(j))
          .toList();
    } catch (e) {
      developer.log('Error al obtener retos del maestro: $e',
          name: 'RetoGrupoRepository', error: e);
      return [];
    }
  }

  Future<RetoGrupoModel?> asignarRetoAGrupo(RetoGrupoModel retoGrupo) async {
    try {
      final response = await supabase
          .from(_tableName)
          .insert(retoGrupo.toJson())
          .select()
          .single();

      return RetoGrupoModel.fromJson(response);
    } catch (e) {
      developer.log('Error al asignar reto a grupo: $e',
          name: 'RetoGrupoRepository', error: e);
      rethrow;
    }
  }

  Future<bool> desactivarRetoDeGrupo(String id) async {
    try {
      await supabase
          .from(_tableName)
          .update({'activo': false})
          .eq('id', id);
      return true;
    } catch (e) {
      developer.log('Error al desactivar reto de grupo: $e',
          name: 'RetoGrupoRepository', error: e);
      return false;
    }
  }
}
