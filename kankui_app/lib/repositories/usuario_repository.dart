import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import 'dart:developer' as developer;

class UsuarioRepository {
  final SupabaseClient supabase;
  final String _tableName = 'usuario';

  UsuarioRepository(this.supabase);

  Future<UsuarioModel?> guardarUsuario(UsuarioModel usuario) async {
    try {
      final List<dynamic> response = await supabase
          .from(_tableName)
          .insert(usuario.toJson())
          .select()
          .timeout(const Duration(seconds: 10));

      if (response.isNotEmpty) {
        developer.log('Usuario guardado: ${usuario.id}',
            name: 'UsuarioRepository');
        return UsuarioModel.fromJson(response.first);
      }
      return null;
    } catch (e) {
      developer.log('Error guardando usuario: $e',
          name: 'UsuarioRepository', error: e);
      rethrow; // Propaga el error para ver el mensaje exacto
    }
  }

  Future<UsuarioModel?> obtenerUsuarioPorId(String id) async {
    try {
      final data = await supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data != null) {
        return UsuarioModel.fromJson(data);
      }
      return null;
    } catch (e) {
      developer.log('Error buscando usuario ($id): $e',
          name: 'UsuarioRepository', error: e);
      return null;
    }
  }
}
