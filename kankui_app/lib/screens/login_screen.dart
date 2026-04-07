import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

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
  const LoginScreen({super.key});

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
                      color: LoginColors.brownDark.withOpacity(0.35),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Módulo docente próximamente'),
                      backgroundColor: LoginColors.brown,
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
      shadowColor: LoginColors.brownDark.withOpacity(0.15),
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
    if (_idController.text.isEmpty || _pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: LoginColors.brown,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simular proceso de login
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    // ✅ LOGIN EXITOSO - Navegar al HomeScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
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
                      color: LoginColors.white.withOpacity(0.8),
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

                    // Avatar dorado
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: LoginColors.goldLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: LoginColors.gold.withOpacity(0.3),
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

                    // Campo ID
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

                    // Campo PIN
                    _PinField(controller: _pinController),

                    const SizedBox(height: 36),

                    // Botón entrar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LoginColors.brownDark,
                          foregroundColor: LoginColors.cream,
                          disabledBackgroundColor:
                              LoginColors.brownDark.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: LoginColors.brownDark.withOpacity(0.4),
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

                    // Hint
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
// WIDGET: Campo de texto genérico
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
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
            hintStyle: const TextStyle(color: LoginColors.textMuted, fontSize: 15),
            filled: true,
            fillColor: LoginColors.white,
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
              borderSide: const BorderSide(color: LoginColors.brown, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Campo PIN con 4 puntos visuales
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
    final pinLength = widget.controller.text.length.clamp(0, 4);

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
        Stack(
          children: [
            // Visual: 4 puntos
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: LoginColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LoginColors.inputBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < pinLength;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? LoginColors.brown : LoginColors.inputBorder,
                    ),
                  );
                }),
              ),
            ),
            // Input invisible encima
            Positioned.fill(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.transparent),
                cursorColor: Colors.transparent,
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: LoginColors.brown, width: 1.8),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}