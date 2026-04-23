import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estudiantes_model.dart';

class DocenteService {
  final supabase = Supabase.instance.client;

  // 🔍 OBTENER ESTUDIANTES DEL DOCENTE
  Future<List<Estudiante>> obtenerEstudiantes(String docenteId) async {
    final response = await supabase
        .from('estudiante')
        .select()
        .eq('maestro_id', docenteId);

    return (response as List)
        .map((e) => Estudiante.fromJson(e))
        .toList();
  }

  // ➕ CREAR ESTUDIANTE
   Future<Estudiante> crearEstudianteConPinUnico(
    Estudiante e, String docenteId
  ) async {
    // Llamar a la función RPC para generar PIN único
    final pinGenerado = await supabase.rpc(
      'generar_pin_unico',
      // Si necesitas parámetros, van aquí
      // params: {}
    );
    
    // Insertar estudiante con el PIN generado
    final response = await supabase.from('estudiante').insert({
      ...e.toJson(),
      'maestro_id': docenteId,
      'pin': pinGenerado, // Usar PIN generado por la BD
    }).select().single();
    
    return Estudiante.fromJson(response);
  }

  // ✏️ ACTUALIZAR ESTUDIANTE
  Future<void> actualizarEstudiante(Estudiante e) async {
    await supabase
        .from('estudiante')
        .update(e.toJson())
        .eq('id', e.id);
  }

  // ❌ ELIMINAR ESTUDIANTE
  Future<void> eliminarEstudiante(String id) async {
    await supabase.from('estudiante').delete().eq('id', id);
  }
}