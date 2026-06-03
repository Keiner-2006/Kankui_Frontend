import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/presentation/controllers/grupo_controller.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/presentation/views/detalle_grupo_screen.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';

class GestionGruposScreen extends StatefulWidget {
  final String? maestroId;

  const GestionGruposScreen({super.key, this.maestroId});

  @override
  State<GestionGruposScreen> createState() => _GestionGruposScreenState();
}

class _GestionGruposScreenState extends State<GestionGruposScreen> {
  late final GrupoController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GrupoController>();
    if (widget.maestroId != null) {
      controller.cargarGrupos(widget.maestroId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grupos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.grupos.length} grupo${controller.grupos.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textoClaro,
                    ),
              ),
            ],
          ),
          FloatingActionButton.small(
            onPressed: () => _mostrarDialogoCrearGrupo(context),
            backgroundColor: AppColors.terracota,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.cargando.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.terracota),
      );
    }

    if (controller.error.value != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(controller.error.value!,
              style: const TextStyle(color: AppColors.textoClaro)),
        ),
      );
    }

    if (controller.grupos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined,
                size: 64, color: AppColors.textoClaro.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('No hay grupos creados',
                style: TextStyle(color: AppColors.textoClaro)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _mostrarDialogoCrearGrupo(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear primer grupo'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.cargarGrupos(widget.maestroId ?? ''),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: controller.grupos.length,
        itemBuilder: (context, index) {
          final grupo = controller.grupos[index];
          return _GrupoCard(
            grupo: grupo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleGrupoScreen(grupo: grupo),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoCrearGrupo(BuildContext context) {
    final nombreCtrl = TextEditingController();
    String? gradoSeleccionado;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Nuevo Grupo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del grupo',
                  hintText: 'Ej: Grado 6A',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gradoSeleccionado,
                onChanged: (v) => setDialogState(() => gradoSeleccionado = v),
                decoration: const InputDecoration(
                  labelText: 'Grado (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  'Sexto', 'Septimo', 'Octavo', 'Noveno', 'Décimo', 'Once',
                ]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isNotEmpty) {
                  controller.crearGrupo(
                    nombreCtrl.text.trim(),
                    gradoSeleccionado,
                    widget.maestroId ?? '',
                    null,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracota,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrupoCard extends StatelessWidget {
  final GrupoModel grupo;
  final VoidCallback onTap;

  const _GrupoCard({required this.grupo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.terracota.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.group_rounded,
                    color: AppColors.terracota, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grupo.nombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoOscuro,
                          ),
                    ),
                    if (grupo.grado != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        grupo.grado!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textoClaro,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.verdeSelva.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${grupo.cantidadEstudiantes}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.verdeSelva,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textoClaro),
            ],
          ),
        ),
      ),
    );
  }
}
