import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/shared/ui/theme/kankui_icons.dart';
import 'package:kankui_app/features/quiz/presentation/controllers/retos_estudiante_controller.dart';

class RetosEstudianteScreen extends GetView<RetosEstudianteController> {
  const RetosEstudianteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Obx(() {
      if (controller.cargando.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.terracota),
        );
      }

      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.textoClaro),
              const SizedBox(height: 16),
              Text(controller.error.value!,
                  style: const TextStyle(color: AppColors.textoClaro)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.cargarRetos,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracota,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.retos.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KankuiIcons.sierra(
                  size: 64, color: AppColors.textoClaro.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text('No hay retos asignados',
                  style: TextStyle(
                      color: AppColors.textoClaro,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Cuando tu profesor asigne un reto,\naparecerá aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textoClaro)),
            ],
          ),
        );
      }

      return SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.cargarRetos,
          color: AppColors.terracota,
          child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (controller.retosPendientes.isNotEmpty)
              SliverToBoxAdapter(child: _buildSectionTitle('Pendientes')),
            if (controller.retosPendientes.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RetoCard(
                    reto: controller.retosPendientes[index],
                    onResponder: controller.responderReto,
                  ),
                  childCount: controller.retosPendientes.length,
                ),
              ),
            if (controller.retosCompletados.isNotEmpty)
              SliverToBoxAdapter(
                  child: _buildSectionTitle('Completados',
                      count: controller.retosCompletados.length)),
            if (controller.retosCompletados.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _RetoCard(
                    reto: controller.retosCompletados[index],
                    onResponder: controller.responderReto,
                  ),
                  childCount: controller.retosCompletados.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final pendientes = controller.retosPendientes.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mis Retos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textoOscuro,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 4),
                Text(
                  pendientes > 0
                      ? '$pendientes reto${pendientes == 1 ? '' : 's'} pendiente${pendientes == 1 ? '' : 's'}'
                      : 'Todos tus retos están completados',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textoClaro),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.terracota.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: KankuiIcons.mochila(
                size: 28, color: AppColors.terracota),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textoOscuro,
              )),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.verdeSelva.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verdeSelva,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

class _RetoCard extends StatelessWidget {
  final RetoConEstado reto;
  final void Function(RetoConEstado) onResponder;

  const _RetoCard({required this.reto, required this.onResponder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      shadowColor: AppColors.terracota.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: reto.completado ? null : () => onResponder(reto),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: reto.completado
                      ? AppColors.verdeSelva.withValues(alpha: 0.15)
                      : AppColors.terracota.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  reto.completado
                      ? Icons.check_circle_rounded
                      : Icons.quiz_rounded,
                  color: reto.completado
                      ? AppColors.verdeSelva
                      : AppColors.terracota,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reto.reto.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoOscuro,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reto.reto.grado ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textoClaro,
                      ),
                    ),
                    if (reto.completado)
                      Text(
                        '${reto.puntosObtenidos} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.verdeSelva,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (!reto.completado)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.terracota.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Responder',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.terracota,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
