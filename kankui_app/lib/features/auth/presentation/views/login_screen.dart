import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/auth/presentation/controllers/login_controller.dart';

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
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: LoginColors.brown, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: LoginColors.brownDark.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.shield_outlined, color: LoginColors.cream, size: 44),
              ),
              const SizedBox(height: 20),
              const Text('KANKUAMO', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: LoginColors.brownDark, letterSpacing: 4)),
              const SizedBox(height: 6),
              const Text('Portal Etnoeducativo', style: TextStyle(fontSize: 14, color: LoginColors.gold, letterSpacing: 1.5, fontStyle: FontStyle.italic)),
              const Spacer(flex: 2),
              _RoleCard(
                icon: Icons.person_outline_rounded, title: 'Soy Estudiante',
                subtitle: 'Semilla de Conocimiento',
                onTap: () => Get.to(() => const _StudentLoginForm()),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.person_pin_outlined, title: 'Soy Docente',
                subtitle: 'Bastón de Autoridad',
                onTap: () => Get.to(() => const _TeacherLoginForm()),
              ),
              const Spacer(flex: 3),
              const Text('I.E. Indígena Atánquez • Sierra Nevada', style: TextStyle(fontSize: 11, color: LoginColors.textMuted)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoginColors.white, borderRadius: BorderRadius.circular(16), elevation: 2,
      shadowColor: LoginColors.brownDark.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16), splashColor: LoginColors.cream,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: const BoxDecoration(color: LoginColors.cream, shape: BoxShape.circle),
                child: Icon(icon, color: LoginColors.brown, size: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: LoginColors.textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: LoginColors.textMuted)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: LoginColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentLoginForm extends StatefulWidget {
  const _StudentLoginForm();
  @override
  State<_StudentLoginForm> createState() => _StudentLoginFormState();
}

class _StudentLoginFormState extends State<_StudentLoginForm> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginController>();
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
              child: Align(alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(color: LoginColors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_left_rounded, color: LoginColors.textDark, size: 22)),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(width: 76, height: 76,
                      decoration: BoxDecoration(color: LoginColors.goldLight, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: LoginColors.gold.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                      child: const Icon(Icons.person_rounded, color: LoginColors.white, size: 40)),
                    const SizedBox(height: 18),
                    const Text('Entrada Estudiante', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: LoginColors.brown)),
                    const SizedBox(height: 6),
                    const Text('Ingresa con tus credenciales', style: TextStyle(fontSize: 13, color: LoginColors.textMuted)),
                    const SizedBox(height: 36),
                    _InputField(label: 'ID Estudiantil', hint: 'Ej: 1234567890', controller: controller.idController,
                      keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                    const SizedBox(height: 20),
                    _PinField(controller: controller.pinController),
                    const SizedBox(height: 36),
                    Obx(() => SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.handleStudentLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LoginColors.brownDark, foregroundColor: LoginColors.cream,
                          disabledBackgroundColor: LoginColors.brownDark.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4, shadowColor: LoginColors.brownDark.withValues(alpha: 0.4)),
                        child: controller.isLoading.value
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: LoginColors.cream, strokeWidth: 2.5))
                            : const Text('Entrar al Resguardo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    )),
                    const SizedBox(height: 20),
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('🌿', style: TextStyle(fontSize: 14)), SizedBox(width: 6),
                      Text('Pídele a tu profesor tu código secreto', style: TextStyle(fontSize: 12, color: LoginColors.textMuted, fontStyle: FontStyle.italic)),
                    ]),
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

class _TeacherLoginForm extends StatefulWidget {
  const _TeacherLoginForm();
  @override
  State<_TeacherLoginForm> createState() => _TeacherLoginFormState();
}

class _TeacherLoginFormState extends State<_TeacherLoginForm> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginController>();
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
              child: Align(alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(color: LoginColors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_left_rounded, color: LoginColors.textDark, size: 22)),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(width: 76, height: 76,
                      decoration: BoxDecoration(color: LoginColors.brown, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: LoginColors.brownDark.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                      child: const Icon(Icons.person_pin_rounded, color: LoginColors.cream, size: 40)),
                    const SizedBox(height: 18),
                    const Text('Portal Docente', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: LoginColors.brown)),
                    const SizedBox(height: 6),
                    const Text('Acceso al panel administrativo', style: TextStyle(fontSize: 13, color: LoginColors.textMuted)),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: LoginColors.white, borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: LoginColors.brownDark.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))]),
                      child: Column(
                        children: [
                          _InputField(label: 'Correo Institucional', hint: 'profesor@ieatanquez.edu.co', controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: const Icon(Icons.mail_outline_rounded, color: LoginColors.textMuted, size: 20)),
                          const SizedBox(height: 20),
                          Obx(() => _buildPasswordField()),
                          const SizedBox(height: 28),
                          Obx(() => SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.handleTeacherLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LoginColors.brownDark, foregroundColor: LoginColors.cream,
                                disabledBackgroundColor: LoginColors.brownDark.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 4, shadowColor: LoginColors.brownDark.withValues(alpha: 0.4)),
                              child: controller.isLoading.value
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: LoginColors.cream, strokeWidth: 2.5))
                                  : const Text('Acceder al Panel Administrativo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            ),
                          )),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _handleForgotPassword,
                            child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 13, color: LoginColors.brown, fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Acceso exclusivo para docentes autorizados', style: TextStyle(fontSize: 11, color: LoginColors.textMuted)),
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

  Widget _buildPasswordField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LoginColors.textDark)),
      const SizedBox(height: 8),
      TextField(
        controller: controller.passwordController,
        obscureText: controller.obscurePassword.value,
        style: const TextStyle(fontSize: 15, color: LoginColors.textDark),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(color: LoginColors.textMuted, fontSize: 18),
          filled: true, fillColor: LoginColors.cream,
          suffixIcon: GestureDetector(
            onTap: controller.togglePasswordVisibility,
            child: Obx(() => Icon(
              controller.obscurePassword.value ? Icons.lock_outline_rounded : Icons.lock_open_outlined,
              color: LoginColors.textMuted, size: 20,
            )),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.inputBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.inputBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.brown, width: 1.8)),
        ),
      ),
    ]);
  }

  void _handleForgotPassword() {
    Get.dialog(AlertDialog(
      backgroundColor: LoginColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Recuperar contraseña', style: TextStyle(color: LoginColors.brownDark, fontWeight: FontWeight.w700)),
      content: const Text('Contacta al administrador del sistema para restablecer tu contraseña institucional.', style: TextStyle(color: LoginColors.textMuted, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Entendido', style: TextStyle(color: LoginColors.brown, fontWeight: FontWeight.w700))),
      ],
    ));
  }
}

class _InputField extends StatelessWidget {
  final String label; final String hint; final TextEditingController controller;
  final TextInputType keyboardType; final List<TextInputFormatter> inputFormatters; final Widget? suffixIcon;
  const _InputField({required this.label, required this.hint, required this.controller, this.keyboardType = TextInputType.text, this.inputFormatters = const [], this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LoginColors.textDark)),
      const SizedBox(height: 8),
      TextField(
        controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 15, color: LoginColors.textDark),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: LoginColors.textMuted, fontSize: 14),
          filled: true, fillColor: LoginColors.cream, suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.inputBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.inputBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.brown, width: 1.8)),
        ),
      ),
    ]);
  }
}

class _PinField extends StatefulWidget {
  final TextEditingController controller;
  const _PinField({required this.controller});
  @override
  State<_PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<_PinField> {
  @override
  void initState() { super.initState(); widget.controller.addListener(() => setState(() {})); }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Código de Verificación (PIN)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LoginColors.textDark)),
      const SizedBox(height: 8),
      TextField(
        controller: widget.controller, keyboardType: TextInputType.text, maxLength: 8,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: LoginColors.textDark, letterSpacing: 2),
        decoration: InputDecoration(
          hintText: '1234AB', hintStyle: const TextStyle(color: LoginColors.textMuted, fontSize: 16, fontWeight: FontWeight.w500),
          counterText: '', prefixText: 'K-',
          prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: LoginColors.brown, letterSpacing: 1.5),
          filled: true, fillColor: LoginColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.inputBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.inputBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: LoginColors.brown, width: 1.8)),
        ),
      ),
    ]);
  }
}
