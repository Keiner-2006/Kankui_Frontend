import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/auth/presentation/controllers/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  final VoidCallback? onFinish;

  const OnboardingScreen({super.key, this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: controller.goToPage,
        children: const [
          _OnboardingPage(
            title: 'Bienvenido a Kankui',
            description: 'Aprende vocabulario de forma divertida',
            icon: Icons.school,
          ),
          _OnboardingPage(
            title: 'Practica cada dia',
            description: 'Refuerza tu aprendizaje con recordatorios',
            icon: Icons.notifications_active,
          ),
          _OnboardingPage(
            title: 'Mide tu progreso',
            description: 'Observa como avanzas cada dia',
            icon: Icons.trending_up,
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: controller.currentPage.value == 2
              ? () {
                  controller.finishOnboarding();
                  onFinish?.call();
                }
              : controller.nextPage,
          child: Icon(
            controller.currentPage.value == 2
                ? Icons.check
                : Icons.arrow_forward,
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.green),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
