import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';
import '../models/estudiantes_model.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/estudiante_repository.dart';
import 'package:kankui_app/services/docenteservices.dart';

// ============================================================
// PALETA DE COLORES (misma que AdminPanelPage)
// ============================================================

class _AppColors {
  static const headerBrown    = Color(0xFF5C2E00);
  static const headerSubtitle = Color(0xFFD4956A);
  static const accent         = Color(0xFFD4730A);
  static const accentLight    = Color(0xFFF4A535);
  static const background     = Color(0xFFFFF8F0);
  static const cardBackground = Color(0xFFFFFFFF);
  static const textPrimary    = Color(0xFF2C1A0E);
  static const textSecondary  = Color(0xFF8A6E5C);
  static const pinBorder      = Color(0xFFD4730A);
  static const pinBackground  = Color(0xFFFFF3E0);
  static const pinText        = Color(0xFFD4730A);
  static const inputBorder    = Color(0xFFE0D5CB);
  static const inputFill      = Color(0xFFFFFFFF);
  static const hintColor      = Color(0xFFBCAFA6);
  static const infoColor      = Color(0xFF8A6E5C);
}

// ============================================================
// MODELOS
// ============================================================

const List<String> _gradosDisponibles = [
  'Preescolar',
  'Primero',
  'Segundo',
  'Tercero',
  'Cuarto',
  'Quinto',
  'Sexto',
  'Séptimo',
  'Octavo',
  'Noveno',
  'Décimo',
  'Once',
];

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

// ============================================================
// PANTALLA: Inscribir Estudiante
// ============================================================

class InscribirEstudiantePage extends StatefulWidget {
  final void Function(NuevoEstudianteResult resultado)? onGuardar;
  final String? maestroId;

  const InscribirEstudiantePage({super.key, this.onGuardar, this.maestroId});

  @override
  State<InscribirEstudiantePage> createState() =>
      _InscribirEstudiantePageState();
}

class _InscribirEstudiantePageState extends State<InscribirEstudiantePage> {
  final _formKey = GlobalKey<FormState>();
  final docenteservice = DocenteService();

  final _nombreController = TextEditingController();
  final _idController     = TextEditingController();
  String? _gradoSeleccionado;

  String? _pinGenerado;
  UsuarioModel? _usuarioGuardado;
  EstudianteModel? _estudianteGuardado;

  bool _guardando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _guardarYGenerar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      // Lógica combinada (Preferida de Alejandro para integrar con Supabase)
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      
      // Intentamos usar el modelo que Alejandro espera (esto podría causar errores si Estudiante != EstudianteModel)
      // Para propósitos de depuración, usaremos la estructura de Alejandro
      final estudiante = Estudiante(
        id: const Uuid().v4(),
        curso: _gradoSeleccionado,
        grupo: null,
        pin: '', 
        ultimaActividad: DateTime.now(),
      );
      
      final estudianteCreado = await docenteservice.crearEstudianteConPinUnico(
        estudiante,
        user.id,
      );
      
      final pinGenerado = estudianteCreado.pin;
      if (pinGenerado == null || pinGenerado.isEmpty) {
        throw Exception('PIN generado inválido');
      }
      
      if (!mounted) return;
      
      setState(() {
        _pinGenerado = pinGenerado;
        _guardando = false;
      });
      
      final resultado = NuevoEstudianteResult(
        nombreCompleto: _nombreController.text.trim(),
        identificacion: _idController.text.trim(),
        grado: _gradoSeleccionado!,
        pin: pinGenerado,
      );
      
      widget.onGuardar?.call(resultado);
      _mostrarDialogoExito(resultado);
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      print ('Error al guardar estudiante: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoExito(NuevoEstudianteResult r) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoExito(
        resultado: r,
        onAceptar: () {
          Navigator.of(context).pop(); 
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormField(
                      label: 'Nombre Completo',
                      child: _InputText(
                        controller: _nombreController,
                        hint: 'Ej: Juan Carlos Kakuamo Torres',
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa el nombre completo';
                          }
                          if (v.trim().split(' ').length < 2) {
                            return 'Ingresa nombre y apellido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'Número de Identificación',
                      child: _InputText(
                        controller: _idController,
                        hint: '1234567890',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa el número de identificación';
                          }
                          if (v.trim().length < 6) {
                            return 'Mínimo 6 dígitos';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'Grado Escolar',
                      child: _GradoDropdown(
                        valor: _gradoSeleccionado,
                        onChanged: (v) =>
                            setState(() => _gradoSeleccionado = v),
                        validator: (v) =>
                            v == null ? 'Selecciona un grado' : null,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _PinPreview(pin: _pinGenerado),
                    const SizedBox(height: 28),
                    _BotonGuardar(
                      cargando: _guardando,
                      onPressed: _guardarYGenerar,
                    ),
                    const SizedBox(height: 20),
                    const _NotaInformativa(
                      texto:
                          'El PIN será generado automáticamente al guardar. '
                          'Entrégalo al estudiante para su primer acceso.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onBack;
  const _Header({this.onBack});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _AppColors.headerBrown,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 24,
        bottom: 28,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Inscribir Estudiante',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Registra un nuevo alumno al sistema',
                style: TextStyle(
                  color: _AppColors.headerSubtitle,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InputText extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  const _InputText({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _AppColors.hintColor, fontSize: 14),
        filled: true,
        fillColor: _AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _GradoDropdown extends StatelessWidget {
  final String? valor;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  const _GradoDropdown({required this.valor, required this.onChanged, this.validator});
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valor,
      onChanged: onChanged,
      validator: validator,
      hint: const Text('Seleccionar grado...', style: TextStyle(color: _AppColors.hintColor, fontSize: 14)),
      style: const TextStyle(fontSize: 14, color: _AppColors.textPrimary),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _AppColors.textSecondary),
      decoration: InputDecoration(
        filled: true,
        fillColor: _AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AppColors.inputBorder),
        ),
      ),
      items: _gradosDisponibles.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
    );
  }
}

class _PinPreview extends StatelessWidget {
  final String? pin;
  const _PinPreview({this.pin});
  @override
  Widget build(BuildContext context) {
    final generado = pin != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _AppColors.pinBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.pinBorder.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PIN Generado Automáticamente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(generado ? 'K-$pin' : 'K-????', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: generado ? _AppColors.pinText : _AppColors.pinText.withOpacity(0.45), letterSpacing: 1.5)),
              ],
            ),
          ),
          if (generado)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: 'K-$pin'));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN copiado')));
              },
              child: const Icon(Icons.copy_rounded, color: _AppColors.accent, size: 24),
            ),
        ],
      ),
    );
  }
}

class _BotonGuardar extends StatelessWidget {
  final bool cargando;
  final VoidCallback? onPressed;
  const _BotonGuardar({required this.cargando, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.headerBrown,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar y Generar Código', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _NotaInformativa extends StatelessWidget {
  final String texto;
  const _NotaInformativa({required this.texto});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, color: _AppColors.infoColor, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 12, color: _AppColors.infoColor))),
      ],
    );
  }
}

// Faltan componentes como _DialogoExito, se asume que están definidos abajo o en otro archivo
// Para que compile si faltan, podrías necesitar definirlos o importarlos.
class _DialogoExito extends StatelessWidget {
  final NuevoEstudianteResult resultado;
  final VoidCallback onAceptar;
  const _DialogoExito({required this.resultado, required this.onAceptar});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¡Éxito!'),
      content: Text('Estudiante registrado. PIN: ${resultado.pinFormateado}'),
      actions: [TextButton(onPressed: onAceptar, child: const Text('Aceptar'))],
    );
  }
}
