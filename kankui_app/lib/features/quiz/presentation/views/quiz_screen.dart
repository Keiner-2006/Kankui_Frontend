import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/features/quiz/presentation/controllers/quiz_controller.dart';

class QuizScreen extends GetView<QuizController> {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back()),
        title: Text('Reto Kankui',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.terracota, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildEncabezado(context),
          const SizedBox(height: 24),
          _buildTarjetaSeleccionQuiz(context),
        ]),
      ),
    );
  }

  Widget _buildEncabezado(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Elige tu desafío',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.textoOscuro, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(
          'Selecciona una categoría y pon a prueba tus conocimientos en kankuama.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.textoMedio)),
    ]);
  }

  Widget _buildTarjetaSeleccionQuiz(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.terracota.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Colors.white,
                AppColors.cremaOscuro.withValues(alpha: 0.3)
              ])),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.startQuiz(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(children: [
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.terracota.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.quiz_rounded,
                          color: AppColors.terracota, size: 40)),
                  const SizedBox(width: 20),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(controller.categoria?.nombre ?? 'Quiz General',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: AppColors.textoOscuro,
                                    fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            '${controller.cantidadPreguntas ?? 10} preguntas • General',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textoClaro)),
                      ])),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.terracota,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
