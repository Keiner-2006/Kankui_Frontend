import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/learning/domain/models/progresoreto_model.dart';
import 'dart:developer' as developer;

class ProgresoGrupoRepository {
  final SupabaseClient supabase;

  ProgresoGrupoRepository(this.supabase);

  Future<List<ProgresoRetoModel>> obtenerProgresoPorReto(String retoId) async {
    try {
      final response = await supabase
          .from('progreso_reto')
          .select()
          .eq('reto_id', retoId);

      return (response as List)
          .map((j) => ProgresoRetoModel.fromJson(j))
          .toList();
    } catch (e) {
      developer.log('Error al obtener progreso del reto: $e',
          name: 'ProgresoGrupoRepository', error: e);
      return [];
    }
  }

  Future<Map<String, List<ProgresoRetoModel>>>
      obtenerProgresoPorGrupo(String grupoId) async {
    try {
      final retosAsignados = await supabase
          .from('reto_grupo')
          .select('reto_id')
          .eq('grupo_id', grupoId)
          .eq('activo', true);

      final retoIds = (retosAsignados as List)
          .map((r) => r['reto_id'] as String)
          .toList();

      if (retoIds.isEmpty) return {};

      final Map<String, List<ProgresoRetoModel>> agrupado = {};
      for (final retoId in retoIds) {
        final response = await supabase
            .from('progreso_reto')
            .select()
            .eq('reto_id', retoId);

        final progresos = (response as List)
            .map((j) => ProgresoRetoModel.fromJson(j))
            .toList();
        if (progresos.isNotEmpty) {
          agrupado[retoId] = progresos;
        }
      }
      return agrupado;
    } catch (e) {
      developer.log('Error al obtener progreso del grupo: $e',
          name: 'ProgresoGrupoRepository', error: e);
      return {};
    }
  }

  Future<double> obtenerPromedioGrupo(String grupoId) async {
    try {
      final agrupado = await obtenerProgresoPorGrupo(grupoId);
      if (agrupado.isEmpty) return 0;

      int sumaPuntos = 0;
      int totalRetos = 0;

      for (final entry in agrupado.entries) {
        for (final p in entry.value) {
          if (p.completado) {
            sumaPuntos += p.puntosObtenidos;
            totalRetos++;
          }
        }
      }

      if (totalRetos == 0) return 0;
      return (sumaPuntos / (totalRetos * 10)) * 100;
    } catch (e) {
      developer.log('Error al calcular promedio: $e',
          name: 'ProgresoGrupoRepository', error: e);
      return 0;
    }
  }

  Future<int> contarEstudiantesCompletaron(
      String grupoId, String retoId) async {
    try {
      final response = await supabase
          .from('progreso_reto')
          .select('id')
          .eq('reto_id', retoId)
          .eq('completado', true);

      return (response as List).length;
    } catch (e) {
      developer.log('Error al contar completados: $e',
          name: 'ProgresoGrupoRepository', error: e);
      return 0;
    }
  }
}
