import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/estudiantes_model.dart';

class DocenteService {
  final supabase = Supabase.instance.client;

  // ==========================================
  // 🔍 OBTENER ESTUDIANTES DEL DOCENTE
  // ==========================================
  Future<Estudiante> crearEstudianteConPinUnico(
  Estudiante e,
  String docenteId,
  String usuarioEstudianteId, // 🔥 NUEVO
) async {

  print('🔍 Buscando maestro para docente: $docenteId');

  // 🔍 Obtener maestro_id
  var maestro = await supabase
      .from('maestro')
      .select('id')
      .eq('usuario_id', docenteId)
      .maybeSingle();

  if (maestro == null) {
    final nuevoMaestroId = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.from('maestro').insert({
      'id': nuevoMaestroId,
      'usuario_id': docenteId,
    });

    maestro = {'id': nuevoMaestroId};
  }

  final maestroId = maestro['id'];

  // 🔍 VALIDAR SI YA EXISTE ESTE ESTUDIANTE
  final existente = await supabase
      .from('estudiante')
      .select()
      .eq('usuario_id', usuarioEstudianteId)
      .maybeSingle();

  if (existente != null) {
    print('⚠️ Este usuario ya es estudiante');
    return Estudiante.fromJson(existente);
  }

  // 🔐 Generar PIN
  final pin = await supabase.rpc('generar_pin_unico');

  print('📝 Creando estudiante con usuario_id: $usuarioEstudianteId');

  final response = await supabase.from('estudiante').insert({
    ...e.toJson(),
    'usuario_id': usuarioEstudianteId, // 🔥 CLAVE
    'maestro_id': maestroId,
    'pin': pin,
  }).select().single();

  print('✅ Estudiante creado correctamente');

  return Estudiante.fromJson(response);
}




  // ==========================================
  // ✏️ ACTUALIZAR ESTUDIANTE
  // ==========================================
  Future<void> actualizarEstudiante(Estudiante e) async {
    await supabase
        .from('estudiante')
        .update(e.toJson())
        .eq('id', e.id);
  }

  // ==========================================
  // ❌ ELIMINAR ESTUDIANTE
  // ==========================================
  Future<void> eliminarEstudiante(String id) async {
    await supabase.from('estudiante').delete().eq('id', id);
  }
}