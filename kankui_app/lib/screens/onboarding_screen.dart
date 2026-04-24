import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  void nextPage() {
    if (currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() {
    // 🔥 SOLO NOTIFICA AL ROOT, NO NAVEGA
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => currentPage = index);
        },
        children: const [
          OnboardingPage(
            title: "Bienvenido a Kankui",
            description: "Aprende vocabulario de forma divertida",
            icon: Icons.school,
          ),
          OnboardingPage(
            title: "Practica cada día",
            description: "Refuerza tu aprendizaje con recordatorios",
            icon: Icons.notifications_active,
          ),
          OnboardingPage(
            title: "Mide tu progreso",
            description: "Observa cómo avanzas cada día",
            icon: Icons.trending_up,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: nextPage,
        child: Icon(
          currentPage == 2 ? Icons.check : Icons.arrow_forward,
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPage({
    super.key,
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
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
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