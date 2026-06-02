import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/docente/domain/models/estudiantes_model.dart';
import 'package:kankui_app/shared/services/docenteservices.dart';

class NuevoEstudianteResult {
  final String nombreCompleto;
  final String identificacion;
  final String grado;
  final String pin;

  const NuevoEstudianteResult({
    required this.nombreCompleto,
    required this.identificacion,
    required this.grado,
    required this.pin,
  });

  String get pinFormateado => 'K-$pin';
}

const List<String> gradosDisponibles = [
  'Preescolar', 'Primero', 'Segundo', 'Tercero', 'Cuarto', 'Quinto',
  'Sexto', 'Septimo', 'Octavo', 'Noveno', 'Decimo', 'Once',
];

class InscribirEstudianteController extends GetxController {
  final DocenteService _docenteService = Get.find();
  final SupabaseClient _supabase = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final idController = TextEditingController();
  final gradoSeleccionado = Rxn<String>();
  final pinGenerado = Rxn<String>();
  final guardando = false.obs;
  final errorMessage = Rxn<String>();

  List<String> get grados => gradosDisponibles;

  @override
  void onClose() {
    nombreController.dispose();
    idController.dispose();
    super.onClose();
  }

  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) return;

    guardando.value = true;
    errorMessage.value = null;

    try {
      final docente = _supabase.auth.currentUser;
      if (docente == null) {
        throw Exception('Usuario no autenticado');
      }

      final docStr = idController.text.trim();

      final soloNumeros = RegExp(r'^[0-9]+$');
      if (!soloNumeros.hasMatch(docStr)) {
        throw Exception('La cedula solo debe contener numeros');
      }
      if (docStr.length < 6) {
        throw Exception('Cedula demasiado corta (minimo 6 digitos)');
      }
      if (docStr.length > 11) {
        throw Exception('Cedula excedio su longitud maxima');
      }
      final docInt = int.tryParse(docStr);
      if (docInt == null) {
        throw Exception('La cedula no es valida');
      }
      if (docInt > 2147483647) {
        throw Exception('Cedula excedio su longitud');
      }

      final nombreCompleto = nombreController.text.trim();
      final partes = nombreCompleto.split(' ');
      final nombre = partes.take(2).join(' ');
      final apellido = partes.skip(2).join(' ');

      final usuarioEstudiante = await _supabase.from('usuario').insert({
        'id': const Uuid().v4(),
        'nombre': nombre.isNotEmpty ? nombre : nombreCompleto,
        'apellido': apellido.isNotEmpty ? apellido : null,
        'identificacion': docInt,
        'rol': 'estudiante',
      }).select().single();

      final usuarioEstudianteId = usuarioEstudiante['id'];

      final estudiante = Estudiante(
        id: const Uuid().v4(),
        usuarioId: usuarioEstudianteId,
        identificacion: docStr,
        curso: gradoSeleccionado.value,
        grupo: null,
        pin: '',
        ultimaActividad: DateTime.now(),
      );

      final estudianteCreado = await _docenteService.crearEstudianteConPinUnico(
        estudiante,
        docente.id,
        usuarioEstudianteId,
      );

      final pin = estudianteCreado.pin;
      if (pin == null || pin.isEmpty) {
        throw Exception('PIN generado invalido');
      }

      pinGenerado.value = pin;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      guardando.value = false;
    }
  }

  void limpiar() {
    nombreController.clear();
    idController.clear();
    gradoSeleccionado.value = null;
    pinGenerado.value = null;
    errorMessage.value = null;
  }
}
