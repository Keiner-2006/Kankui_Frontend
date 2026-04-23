import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maestro_model.dart';
import 'dart:developer' as developer;

class MaestroRepository {
  final SupabaseClient supabase;
  final String _tableName = 'maestro';

  MaestroRepository(this.supabase);

  Future<MaestroModel?> obtenerMaestroPorEmail(String email) async {
    try {
      final data = await supabase
          .from(_tableName)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (data != null) {
        return MaestroModel.fromJson(data);
      }
      return null;
    } catch (e) {
      developer.log('Error buscando maestro por email ($email): $e',
          name: 'MaestroRepository', error: e);
      return null;
    }
  }

  Future<MaestroModel?> obtenerMaestroPorUsuarioId(String usuarioId) async {
    try {
      final data = await supabase
          .from(_tableName)
          .select()
          .eq('usuario_id', usuarioId)
          .maybeSingle();

      if (data != null) {
        return MaestroModel.fromJson(data);
      }
      return null;
    } catch (e) {
      developer.log('Error buscando maestro por usuario_id ($usuarioId): $e',
          name: 'MaestroRepository', error: e);
      return null;
    }
  }
}
