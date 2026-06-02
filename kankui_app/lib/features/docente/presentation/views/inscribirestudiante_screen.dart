import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/features/auth/domain/models/usuario_model.dart';
import 'package:kankui_app/features/docente/domain/models/estudiantes_model.dart';
import 'package:kankui_app/shared/services/docenteservices.dart';

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

class InscribirEstudiantePage extends StatefulWidget {
  final void Function(NuevoEstudianteResult resultado)? onGuardar;
  final String? maestroId;

  const InscribirEstudiantePage({super.key, this.onGuardar, this.maestroId});

  @override
  State<InscribirEstudiantePage> createState() =>
      _InscribirEstudiantePageState();
}

class _InscribirEstudiantePageState extends State<InscribirEstudiantePage> {
  late final InscribirEstudianteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<InscribirEstudianteController>();

    ever(controller.pinGenerado, (pin) {
      if (pin != null && mounted) {
        final resultado = NuevoEstudianteResult(
          nombreCompleto: controller.nombreController.text.trim(),
          identificacion: controller.idController.text.trim(),
          grado: controller.gradoSeleccionado.value!,
          pin: pin,
        );
        widget.onGuardar?.call(resultado);
        _mostrarDialogoExito(resultado);
      }
    });

    ever(controller.errorMessage, (msg) {
      if (msg != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $msg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    controller.limpiar();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    await controller.guardar();
  }

  void _mostrarDialogoExito(NuevoEstudianteResult resultado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5D0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFFE8842A),
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Estudiante registrado!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                resultado.nombreCompleto,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCE8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8D48A),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'PIN del estudiante',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resultado.pin,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFCC8B2D),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C3D2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Listo',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: _AppColors.background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormField(
                      label: 'Nombre Completo',
                      child: _InputText(
                        controller: controller.nombreController,
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
                      label: 'Numero de Identificacion',
                      child: _InputText(
                        controller: controller.idController,
                        hint: '1234567890',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa el numero de identificacion';
                          }
                          if (v.trim().length < 6) {
                            return 'Minimo 6 digitos';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'Grado Escolar',
                      child: _GradoDropdown(
                        valor: controller.gradoSeleccionado.value,
                        onChanged: (v) => controller.gradoSeleccionado.value = v,
                        validator: (v) =>
                            v == null ? 'Selecciona un grado' : null,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _PinPreview(pin: controller.pinGenerado.value),
                    const SizedBox(height: 28),
                    _BotonGuardar(
                      cargando: controller.guardando.value,
                      onPressed: _guardar,
                    ),
                    const SizedBox(height: 20),
                    const _NotaInformativa(
                      texto:
                          'El PIN sera generado automaticamente al guardar. '
                          'Entregalo al estudiante para su primer acceso.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      initialValue: valor,
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
      items: gradosDisponibles.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
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
                const Text('PIN Generado Automaticamente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _AppColors.textSecondary)),
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
        child: cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar y Generar Codigo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
