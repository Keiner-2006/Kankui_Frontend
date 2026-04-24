import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/categoria_model.dart';
import '../data/seed/vocablos_data.dart';

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

  /// Obtiene las palabras reales desde Supabase y las formatea para la UI
  Future<List<Vocablo>> getVocablosPorCategoria(String categoriaId) async {
    try {
      final response = await _client
          .from('palabra')
          .select()
          .eq('categoria_id', categoriaId);
      
      return (response as List).map((json) {
        return Vocablo(
          id: json['id'].toString(),
          palabra: json['termino'] ?? 'Sin término',
          fonetica: json['pronunciacion'] ?? '',
          significado: json['traduccion'] ?? 'Sin traducción',
          categoria: categoriaId,
          descripcionCultural: 'Conocimiento extraído de la base de datos Kankuama.',
          nivelDificultad: 1,
        );
      }).toList();
    } catch (e) {
      print('Error al obtener palabras de la BD: $e');
      return [];
    }
  }
}
