import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // CRUD para Palabras
  Future<void> insertarPalabra(Map<String, dynamic> palabra) async {
    await supabase.from('palabra').insert({
      'id': palabra['id'],
      'termino': palabra['termino'],
      'traduccion': palabra['traduccion'],
      'audio_url': palabra['audio_url'],
      'categoria_id': palabra['categoria_id'],
    });
  }

  Future<List<Map<String, dynamic>>> obtenerPalabras() async {
    final response = await supabase.from('palabra').select();
    return response;
  }

  Future<Map<String, dynamic>?> obtenerPalabraPorId(String id) async {
    final response =
        await supabase.from('palabra').select().eq('id', id).single();
    return response;
  }

  Future<void> actualizarPalabra(
      String id, Map<String, dynamic> updates) async {
    await supabase.from('palabra').update(updates).eq('id', id);
  }

  Future<void> eliminarPalabra(String id) async {
    await supabase.from('palabra').delete().eq('id', id);
  }

  // Consulta con filtros (ejemplo: por categoría)
  Future<List<Map<String, dynamic>>> obtenerPalabrasPorCategoria(
      int categoriaId) async {
    final response =
        await supabase.from('palabra').select().eq('categoria_id', categoriaId);
    return response;
  }

  // Consulta con búsqueda (ejemplo: por término)
  Future<List<Map<String, dynamic>>> buscarPalabras(String termino) async {
    final response =
        await supabase.from('palabra').select().ilike('termino', '%$termino%');
    return response;
  }

  // CRUD para Usuarios
  Future<void> insertarUsuario(Map<String, dynamic> usuario) async {
    await supabase.from('usuarios').insert({
      'id': usuario['id'],
      'nombre': usuario['nombre'],
      'identificacion': usuario['identificacion'],
      'rol': usuario['rol'],
      'fecha_registro': usuario['fecha_registro'],
      'institucion_id': usuario['institucion_id'],
    });
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final response = await supabase.from('usuarios').select();
    return response;
  }

  Future<Map<String, dynamic>?> obtenerUsuarioPorId(String id) async {
    final response =
        await supabase.from('usuarios').select().eq('id', id).single();
    return response;
  }

  Future<void> actualizarUsuario(
      String id, Map<String, dynamic> updates) async {
    await supabase.from('usuarios').update(updates).eq('id', id);
  }

  Future<void> eliminarUsuario(String id) async {
    await supabase.from('usuarios').delete().eq('id', id);
  }

  // Consulta estudiantes por institución
  Future<List<Map<String, dynamic>>> obtenerEstudiantesPorInstitucion(
      String institucionId) async {
    final response = await supabase
        .from('usuarios')
        .select()
        .eq('institucion_id', institucionId)
        .eq('rol', 'estudiante');
    return response;
  }
}
