import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kankui_app/services/notificacion_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/screens/docente_screen.dart';
import 'home_screen.dart';
import '../services/sesionmanager.dart';
import '../models/usuario_model.dart';

import '../services/auth_services.dart';
import '../data/remote/supabase_service.dart';
import '../data/local/user_repository.dart';
import '../data/local/models_local.dart';

// ─────────────────────────────────────────────
// COLORES
// ─────────────────────────────────────────────
class LoginColors {
  static const cream = Color(0xFFF5F0DC);
  static const brown = Color(0xFF7B3A10);
  static const brownDark = Color(0xFF5C2A08);
  static const gold = Color(0xFFB8860B);
  static const goldLight = Color(0xFFD4A017);
  static const white = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF3A1A00);
  static const textMuted = Color(0xFF8A6A50);
  static const inputBorder = Color(0xFFD4B896);
}

// ─────────────────────────────────────────────
// PANTALLA DE LOGIN PRINCIPAL (Selector de Rol)
// ─────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  final VoidCallback? onFinish;

  const LoginScreen({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo escudo
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: LoginColors.brown,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: LoginColors.brownDark.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: LoginColors.cream,
                  size: 44,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'KANKUAMO',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: LoginColors.brownDark,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Portal Etnoeducativo',
                style: TextStyle(
                  fontSize: 14,
                  color: LoginColors.gold,
                  letterSpacing: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(flex: 2),

              // Tarjeta Estudiante
              _RoleCard(
                icon: Icons.person_outline_rounded,
                title: 'Soy Estudiante',
                subtitle: 'Semilla de Conocimiento',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, animation, __) =>
                          const _StudentLoginForm(),
                      transitionsBuilder: (_, animation, __, child) =>
                          SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Tarjeta Docente
              _RoleCard(
                icon: Icons.person_pin_outlined,
                title: 'Soy Docente',
                subtitle: 'Bastón de Autoridad',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, animation, __) =>
                          const _TeacherLoginForm(),
                      transitionsBuilder: (_, animation, __, child) =>
                          SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 3),

              const Text(
                'I.E. Indígena Atánquez • Sierra Nevada',
                style: TextStyle(
                  fontSize: 11,
                  color: LoginColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Tarjeta de rol
// ─────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoginColors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: LoginColors.brownDark.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: LoginColors.cream,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LoginColors.cream,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: LoginColors.brown, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: LoginColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: LoginColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FORMULARIO DE LOGIN ESTUDIANTE
// ─────────────────────────────────────────────
class _StudentLoginForm extends StatefulWidget {
  const _StudentLoginForm();

  @override
  State<_StudentLoginForm> createState() => __StudentLoginFormState();
}

class __StudentLoginFormState extends State<_StudentLoginForm> {
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identificacion = _idController.text.trim();
    final pin = _pinController.text.trim();

    if (identificacion.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: LoginColors.brown,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Buscar usuario por identificacion (traer todos los campos incluyendo progreso)
      final usuario = await supabase
          .from('usuario')
          .select('*')
          .eq('identificacion', int.parse(identificacion))
          .eq('rol', 'estudiante')
          .maybeSingle();

      if (usuario == null) {
        throw Exception('No existe un estudiante con esa identificacion');
      }

      // 2. Buscar estudiante con ese usuario_id y verificar PIN
      final estudiante = await supabase
          .from('estudiante')
          .select('*, usuario:usuario_id(*)')
          .eq('usuario_id', usuario['id'])
          .eq('pin', pin)
          .maybeSingle();

      if (!mounted) return;

      if (estudiante == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN incorrecto'),
            backgroundColor: LoginColors.brown,
          ),
        );
        return;
      }

      // 🔥 OBTENER DATOS DE PROGRESO DE LA TABLA ESTUDIANTE
      // Los campos de progreso están en la tabla estudiante, no en usuario
      final mergedData = Map<String, dynamic>.from(usuario);

      // Extraer progreso de la tabla estudiante
      mergedData['xp_total'] = estudiante['xp_total'] ?? 0;
      mergedData['xp_hoy'] = estudiante['xp_hoy'] ?? 0;
      mergedData['racha_dias'] = estudiante['racha_dias'] ?? 0;
      mergedData['lecciones_completadas'] =
          estudiante['lecciones_completadas'] ?? 0;
      mergedData['escaneos_exitosos'] = estudiante['escaneos_exitosos'] ?? 0;
      mergedData['logros'] = estudiante['logros'] ?? [];

      // Crear modelo de usuario con todos los datos (incluyendo progreso)
      final usuarioModel = UsuarioModel.fromJson(mergedData);

      // 🔥 GUARDAR EN BASE LOCAL (SQLite)
      final userRepo = UserRepository();

      // Guardar usuario
      await userRepo.saveCurrentUser(UsuarioLocal(
        id: usuarioModel.id,
        nombre: usuarioModel.nombre,
        identificacion: usuarioModel.identificacion.toString(),
        rol: usuarioModel.rol,
        fechaRegistro: usuarioModel.fechaRegistro.toIso8601String(),
        institucionId: usuarioModel.institucionId,
      ));

      // Guardar estudiante (con progreso)
      await userRepo.saveEstudiante(EstudianteLocal(
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
        leccionesDesbloqueadas: List<String>.from(
            estudiante['lecciones_desbloqueadas'] ?? ['leccion_1']),
        logrosDesbloqueados: List<String>.from(estudiante['logros'] ?? []),
      ));

      // 🔥 GUARDAR SESIÓN GLOBAL
      print(
          'Usuario autenticado: ${usuarioModel.nombre}, ID: ${usuarioModel.id}');
      print(
          'Progreso: XP Total=${usuarioModel.xpTotal}, Racha=${usuarioModel.rachaDias}');
      SessionManager().loginEstudiante(usuarioModel);

      await NotificationService.showWelcome(
  usuarioModel.nombre,
);

      // 3. Login exitoso - navegar al HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: LoginColors.brown,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: LoginColors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: LoginColors.textDark,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: LoginColors.goldLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: LoginColors.gold.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: LoginColors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Entrada Estudiante',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.brown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ingresa con tus credenciales',
                      style: TextStyle(
                        fontSize: 13,
                        color: LoginColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _InputField(
                      label: 'ID Estudiantil',
                      hint: 'Ej: 1234567890',
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 20),
                    _PinField(controller: _pinController),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LoginColors.brownDark,
                          foregroundColor: LoginColors.cream,
                          disabledBackgroundColor:
                              LoginColors.brownDark.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor:
                              LoginColors.brownDark.withValues(alpha: 0.4),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: LoginColors.cream,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Entrar al Resguardo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'Pídele a tu profesor tu código secreto',
                          style: TextStyle(
                            fontSize: 12,
                            color: LoginColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FORMULARIO DE LOGIN DOCENTE
// ─────────────────────────────────────────────
class _TeacherLoginForm extends StatefulWidget {
  const _TeacherLoginForm();

  @override
  State<_TeacherLoginForm> createState() => __TeacherLoginFormState();
}

class __TeacherLoginFormState extends State<_TeacherLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── LOGIN DOCENTE CON SUPABASE ───────────────
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validaciones básicas
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: LoginColors.brown,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un correo válido'),
          backgroundColor: LoginColors.brown,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔐 SOLO LOGIN CON SUPABASE AUTH
      final res = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      final user = res.user;

      if (user == null) {
        throw Exception('Credenciales inválidas');
      }

      // Crear usuario en tabla usuarios
      try {
        await SupabaseService().insertarUsuario({
          'id': user.id,
          'nombre': user.email?.split('@')[0] ?? 'Docente',
          'identificacion': 0,
          'rol': 'maestro',
          'fecha_registro': DateTime.now().toIso8601String(),
          'institucion_id': null,
        });
      } catch (e) {}

      // Crear registro de maestro si no existe
      await SupabaseService().insertarMaestro(userId: user.id);

      // �👇 CREAMOS UN PROFESOR BÁSICO (SIN BD)
      final profesorAutenticado = Profesor(
        nombre: 'Docente',
        apellido: '',
        correo: user.email ?? '',
        institucion: 'I.E. Indígena Atánquez',
      );

    // 🚀 ENTRAR DIRECTO
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DocenteScreen(profesor: profesorAutenticado),
      ),
    );
    } on AuthException catch (e) {
      // Error específico de Supabase Auth (credenciales inválidas, etc.)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_traducirErrorAuth(e.message)),
          backgroundColor: LoginColors.brown,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${e.toString()}'),
          backgroundColor: LoginColors.brown,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Traduce los mensajes de error de Supabase al español
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

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: LoginColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Recuperar contraseña',
          style: TextStyle(
            color: LoginColors.brownDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Contacta al administrador del sistema para restablecer tu contraseña institucional.',
          style: TextStyle(color: LoginColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                  color: LoginColors.brown, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Botón volver
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: LoginColors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: LoginColors.textDark,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Avatar docente
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: LoginColors.brown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: LoginColors.brownDark.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_pin_rounded,
                        color: LoginColors.cream,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Portal Docente',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.brown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Acceso al panel administrativo',
                      style: TextStyle(
                        fontSize: 13,
                        color: LoginColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Card contenedor del formulario
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: LoginColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                LoginColors.brownDark.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Campo correo
                          _InputField(
                            label: 'Correo Institucional',
                            hint: 'profesor@ieatanquez.edu.co',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: LoginColors.textMuted,
                              size: 20,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Campo contraseña
                          _PasswordField(
                            controller: _passwordController,
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),

                          const SizedBox(height: 28),

                          // Botón acceder
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LoginColors.brownDark,
                                foregroundColor: LoginColors.cream,
                                disabledBackgroundColor: LoginColors.brownDark
                                    .withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                                shadowColor: LoginColors.brownDark
                                    .withValues(alpha: 0.4),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: LoginColors.cream,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Acceder al Panel Administrativo',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Olvidaste contraseña
                          GestureDetector(
                            onTap: _handleForgotPassword,
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                fontSize: 13,
                                color: LoginColors.brown,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: LoginColors.brown,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    const Text(
                      'Acceso exclusivo para docentes autorizados',
                      style: TextStyle(
                        fontSize: 11,
                        color: LoginColors.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Campo de texto genérico
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final Widget? suffixIcon;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: LoginColors.textDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 15, color: LoginColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: LoginColors.textMuted, fontSize: 14),
            filled: true,
            fillColor: LoginColors.cream,
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: LoginColors.brown, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Campo Contraseña con toggle
// ─────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contraseña',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: LoginColors.textDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 15, color: LoginColors.textDark),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle:
                const TextStyle(color: LoginColors.textMuted, fontSize: 18),
            filled: true,
            fillColor: LoginColors.cream,
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure ? Icons.lock_outline_rounded : Icons.lock_open_outlined,
                color: LoginColors.textMuted,
                size: 20,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: LoginColors.brown, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Campo PIN con formato K-XXXXXX (alfanumérico)
// ─────────────────────────────────────────────
class _PinField extends StatefulWidget {
  final TextEditingController controller;

  const _PinField({required this.controller});

  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Código de Verificación (PIN)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: LoginColors.textDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.text,
          maxLength: 8,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: LoginColors.textDark,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: '1234AB',
            hintStyle: const TextStyle(
              color: LoginColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            counterText: '',
            prefixText: 'K-',
            prefixStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LoginColors.brown,
              letterSpacing: 1.5,
            ),
            filled: true,
            fillColor: LoginColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LoginColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: LoginColors.brown,
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
