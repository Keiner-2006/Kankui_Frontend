import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/services/sesionmanager.dart';
import 'package:kankui_app/features/auth/domain/models/usuario_model.dart';
import 'package:kankui_app/shared/services/auth_services.dart';
import 'package:kankui_app/shared/data/remote/supabase_service.dart';
import 'package:kankui_app/shared/data/local/user_repository.dart';
import 'package:kankui_app/shared/data/local/models_local.dart';
import 'package:kankui_app/shared/services/notificacion_service.dart';
import 'package:kankui_app/features/docente/presentation/views/docente_screen.dart';

class LoginController extends GetxController {
  final SessionManager _session = Get.find();
  final AuthService _authService = Get.find();
  final SupabaseService _supabaseService = Get.find();
  final UserRepository _userRepo = Get.find();

  final idController = TextEditingController();
  final pinController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final isStudent = true.obs;

  @override
  void onClose() {
    idController.dispose();
    pinController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> handleStudentLogin() async {
    final identificacion = idController.text.trim();
    final pin = pinController.text.trim();

    if (identificacion.isEmpty || pin.isEmpty) {
      Get.snackbar('Campos requeridos', 'Por favor completa todos los campos',
          backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final supabase = Supabase.instance.client;
      final usuario = await supabase
          .from('usuario')
          .select('*')
          .eq('identificacion', int.parse(identificacion))
          .eq('rol', 'estudiante')
          .maybeSingle();

      if (usuario == null) {
        throw Exception('No existe un estudiante con esa identificación');
      }

      final estudiante = await supabase
          .from('estudiante')
          .select('*, usuario:usuario_id(*)')
          .eq('usuario_id', usuario['id'])
          .eq('pin', pin)
          .maybeSingle();

      if (estudiante == null) {
        Get.snackbar('PIN incorrecto', 'Verifica tu código de verificación',
            backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
        return;
      }

      final mergedData = Map<String, dynamic>.from(usuario);
      mergedData['xp_total'] = estudiante['xp_total'] ?? 0;
      mergedData['xp_hoy'] = estudiante['xp_hoy'] ?? 0;
      mergedData['racha_dias'] = estudiante['racha_dias'] ?? 0;
      mergedData['lecciones_completadas'] =
          estudiante['lecciones_completadas'] ?? 0;
      mergedData['escaneos_exitosos'] = estudiante['escaneos_exitosos'] ?? 0;
      mergedData['logros'] = estudiante['logros'] ?? [];

      final usuarioModel = UsuarioModel.fromJson(mergedData);

      await _userRepo.saveCurrentUser(UsuarioLocal(
        id: usuarioModel.id,
        nombre: usuarioModel.nombre,
        identificacion: usuarioModel.identificacion.toString(),
        rol: usuarioModel.rol,
        fechaRegistro: usuarioModel.fechaRegistro.toIso8601String(),
        institucionId: usuarioModel.institucionId,
      ));

      await _userRepo.saveEstudiante(EstudianteLocal(
        id: estudiante['id'],
        usuarioId: usuarioModel.id,
        curso: estudiante['curso'],
        grupo: estudiante['grupo'],
        promedio: (estudiante['promedio'] ?? 0).toDouble(),
        pin: estudiante['pin'],
        maestroId: estudiante['maestro_id'],
        xpTotal: estudiante['xp_total'] ?? 0,
        xpHoy: estudiante['xp_hoy'] ?? 0,
        rachaDias: estudiante['racha_dias'] ?? 0,
        ultimaActividad: estudiante['ultima_actividad'],
        leccionesCompletadasTotal: estudiante['lecciones_completadas'] ?? 0,
        escaneosExitosos: estudiante['escaneos_exitosos'] ?? 0,
        leccionesDesbloqueadas:
            List<String>.from(estudiante['lecciones_desbloqueadas'] ?? ['leccion_1']),
        logrosDesbloqueados: List<String>.from(estudiante['logros'] ?? []),
      ));

      _session.loginEstudiante(usuarioModel);
      await NotificationService.showWelcome(usuarioModel.nombre);

      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleTeacherLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Campos requeridos', 'Por favor completa todos los campos',
          backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
      return;
    }

    if (!email.contains('@')) {
      Get.snackbar('Correo inválido', 'Ingresa un correo válido',
          backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final res = await _authService.login(email, password);
      final user = res.user;

      if (user == null) {
        throw Exception('Credenciales inválidas');
      }

      try {
        await _supabaseService.insertarUsuario({
          'id': user.id,
          'nombre': user.email?.split('@')[0] ?? 'Docente',
          'identificacion': 0,
          'rol': 'maestro',
          'fecha_registro': DateTime.now().toIso8601String(),
          'institucion_id': null,
        });
      } catch (_) {}

      await _supabaseService.insertarMaestro(userId: user.id);

      final profesorAutenticado = Profesor(
        nombre: 'Docente',
        apellido: '',
        correo: user.email ?? '',
        institucion: 'I.E. Indígena Atánquez',
      );

      Get.offAllNamed('/docente', arguments: profesorAutenticado);
    } on AuthException catch (e) {
      Get.snackbar('Error de autenticación', _traducirErrorAuth(e.message),
          backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error inesperado', e.toString(),
          backgroundColor: const Color(0xFF7B3A10), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  String _traducirErrorAuth(String mensaje) {
    if (mensaje.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    } else if (mensaje.contains('Email not confirmed')) {
      return 'Debes confirmar tu correo antes de ingresar';
    } else if (mensaje.contains('Too many requests')) {
      return 'Demasiados intentos. Espera unos minutos';
    }
    return 'Error de autenticación: $mensaje';
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }
}
