import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/presentation/controllers/grupo_controller.dart';
import 'package:kankui_app/features/docente/presentation/controllers/reto_grupo_controller.dart';
import 'package:kankui_app/features/docente/presentation/views/asignar_reto_screen.dart';
import 'package:kankui_app/features/docente/presentation/views/progreso_grupo_screen.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';

class DetalleGrupoScreen extends StatefulWidget {
  final GrupoModel grupo;

  const DetalleGrupoScreen({super.key, required this.grupo});

  @override
  State<DetalleGrupoScreen> createState() => _DetalleGrupoScreenState();
}

class _DetalleGrupoScreenState extends State<DetalleGrupoScreen> {
  late final GrupoController _grupoController;
  late final RetoGrupoController _retoController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _grupoController = Get.find<GrupoController>();
    _retoController = Get.find<RetoGrupoController>();
    _grupoController.cargarEstudiantesDeGrupo(widget.grupo.id);
    _retoController.cargarRetosPorGrupo(widget.grupo.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        title: Text(
          widget.grupo.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProgresoGrupoScreen(grupo: widget.grupo),
                ),
              );
            },
            tooltip: 'Ver progreso',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoHeader(context),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: _currentTab == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AsignarRetoScreen(
                      grupo: widget.grupo,
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.terracota,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.terracota.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.group_rounded,
                color: AppColors.terracota, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.grupo.nombre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                if (widget.grupo.grado != null)
                  Text('Grado: ${widget.grupo.grado}',
                      style: const TextStyle(color: AppColors.textoClaro)),
              ],
            ),
          ),
          Obx(() {
            final count = _grupoController
                    .estudiantesPorGrupo[widget.grupo.id]
                    ?.length ??
                0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.verdeSelva.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$count estudiantes',
                  style: const TextStyle(
                      color: AppColors.verdeSelva,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cremaOscuro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Estudiantes',
            icon: Icons.people_rounded,
            selected: _currentTab == 0,
            onTap: () => setState(() => _currentTab = 0),
          ),
          _TabItem(
            label: 'Retos',
            icon: Icons.quiz_rounded,
            selected: _currentTab == 1,
            onTap: () => setState(() => _currentTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildEstudiantesTab();
      case 1:
        return _buildRetosTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildEstudiantesTab() {
    return Obx(() {
      final estudiantes =
          _grupoController.estudiantesPorGrupo[widget.grupo.id] ?? [];
      if (estudiantes.isEmpty) {
        return const Center(
          child: Text('No hay estudiantes en este grupo',
              style: TextStyle(color: AppColors.textoClaro)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: estudiantes.length,
        itemBuilder: (context, index) {
          final e = estudiantes[index];
          final nombre =
              '${e.nombre ?? ''} ${e.apellido ?? ''}'.trim();
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.terracota.withValues(alpha: 0.1),
                child: Text(
                  (e.nombre ?? '?')[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.terracota,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('XP: ${e.xpTotal}',
                  style: const TextStyle(color: AppColors.textoClaro)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.verdeSelva.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Activo',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.verdeSelva,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildRetosTab() {
    return Obx(() {
      if (_retoController.cargando.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.terracota),
        );
      }

      final retos = _retoController.retosAsignados;
      if (retos.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz_outlined,
                  size: 64,
                  color: AppColors.textoClaro.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text('No hay retos asignados a este grupo',
                  style: TextStyle(color: AppColors.textoClaro)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AsignarRetoScreen(
                        grupo: widget.grupo,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Asignar reto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracota,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: retos.length,
        itemBuilder: (context, index) {
          final reto = retos[index];
          final vencido = reto.fechaLimite != null &&
              reto.fechaLimite!.isBefore(DateTime.now());
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: vencido
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppColors.verdeSelva.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  color: vencido ? Colors.red : AppColors.verdeSelva,
                ),
              ),
              title: Text(reto.nombreReto ?? 'Reto',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                reto.fechaLimite != null
                    ? 'Vence: ${reto.fechaLimite!.day}/${reto.fechaLimite!.month}/${reto.fechaLimite!.year}'
                    : 'Sin fecha limite',
                style: TextStyle(
                  color: vencido ? Colors.red : AppColors.textoClaro,
                ),
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Desactivar'),
                    onTap: () => _retoController
                        .desactivarReto(reto.id, widget.grupo.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? AppColors.terracota
                      : AppColors.textoClaro),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? AppColors.terracota
                      : AppColors.textoClaro,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
