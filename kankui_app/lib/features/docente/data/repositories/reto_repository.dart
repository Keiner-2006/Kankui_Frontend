import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/reto_model.dart';

class RetoRepository {
  final SupabaseClient supabase;
  final String _tableName = 'reto';

  RetoRepository(this.supabase);

  Future<List<RetoModel>> obtenerTodos() async {
    final response = await supabase
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((j) => RetoModel.fromJson(j)).toList();
  }

  Future<List<RetoModel>> obtenerPorGrado(String grado) async {
    final response = await supabase
        .from(_tableName)
        .select()
        .eq('grado', grado)
        .order('created_at', ascending: false);
    return (response as List).map((j) => RetoModel.fromJson(j)).toList();
  }

  Future<RetoModel> crear(RetoModel reto) async {
    final response =
        await supabase.from(_tableName).insert(reto.toJson()).select().single();
    return RetoModel.fromJson(response);
  }

  Future<void> eliminar(String id) async {
    await supabase.from(_tableName).delete().eq('id', id);
  }
}
