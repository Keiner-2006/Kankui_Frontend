import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/presentation/controllers/progreso_grupo_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';

class ProgresoGrupoScreen extends StatefulWidget {
  final GrupoModel grupo;

  const ProgresoGrupoScreen({super.key, required this.grupo});

  @override
  State<ProgresoGrupoScreen> createState() => _ProgresoGrupoScreenState();
}

class _ProgresoGrupoScreenState extends State<ProgresoGrupoScreen> {
  late final ProgresoGrupoController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProgresoGrupoController>();
    controller.seleccionarGrupo(widget.grupo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        title: Text('Progreso: ${widget.grupo.nombre}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.cargando.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.terracota),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.seleccionarGrupo(widget.grupo),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromedioCard(context),
                const SizedBox(height: 24),
                const Text('Retos Asignados',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoOscuro)),
                const SizedBox(height: 12),
                _buildRetosList(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPromedioCard(BuildContext context) {
    final promedio = controller.promedioGrupo.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.verdeSelva, AppColors.verdeMontana],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdeSelva.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Rendimiento General del Grupo',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Text(
            '${promedio.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: promedio / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Retos',
                '${controller.retosDelGrupo.length}',
                Icons.quiz_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildRetosList(BuildContext context) {
    if (controller.retosDelGrupo.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No hay retos asignados',
              style: TextStyle(color: AppColors.textoClaro)),
        ),
      );
    }

    return Column(
      children: controller.retosDelGrupo.map((reto) {
        final completados =
            controller.estudiantesCompletaron(reto.retoId);
        final total = controller.totalEstudiantesEnReto(reto.retoId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.terracota.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        color: AppColors.terracota, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reto.nombreReto ?? 'Reto',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoOscuro),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cremaOscuro,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${reto.puntajeMaximo ?? 100} pts',
                          style:
                              const TextStyle(color: AppColors.textoClaro),
                        ),
                        Text(
                          total > 0
                              ? '$completados/$total completaron'
                              : 'Sin progreso aun',
                          style: TextStyle(
                            color: completados > 0
                                ? AppColors.verdeSelva
                                : AppColors.textoClaro,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completados / total,
                        backgroundColor: AppColors.cremaOscuro,
                        color: AppColors.verdeSelva,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
