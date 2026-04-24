import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/categoria_model.dart';

class CategoriaRepository {
  final SupabaseClient _client;

  CategoriaRepository(this._client);

  /// Obtiene todas las categorías ordenadas por el campo 'orden'
  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await _client
          .from('categoria')
          .select()
          .order('orden', ascending: true);
      
      return (response as List)
          .map((json) => CategoriaModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  /// Obtiene una categoría por su ID
  Future<CategoriaModel?> getCategoriaById(String id) async {
    try {
      final response = await _client
          .from('categoria')
          .select()
          .eq('id', id)
          .single();
      
      return CategoriaModel.fromJson(response);
    } catch (e) {
      print('Error al obtener categoría $id: $e');
      return null;
    }
  }
}
