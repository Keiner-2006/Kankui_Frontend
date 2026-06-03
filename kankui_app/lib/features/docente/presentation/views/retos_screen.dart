import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/presentation/controllers/retos_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';

class RetosScreen extends StatefulWidget {
  const RetosScreen({super.key});

  @override
  State<RetosScreen> createState() => _RetosScreenState();
}

class _RetosScreenState extends State<RetosScreen> {
  late final RetosController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RetosController>();
  }

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
                const Icon(Icons.error_outline, size: 48, color: AppColors.textoClaro),
                const SizedBox(height: 16),
                Text(controller.error.value!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.cargarRetos,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final retos = controller.retos;
        if (retos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.quiz_outlined, size: 72, color: AppColors.textoClaro),
                SizedBox(height: 16),
                Text('No hay retos creados',
                    style: TextStyle(color: AppColors.textoClaro)),
                SizedBox(height: 8),
                Text('Toca + para crear tu primer reto',
                    style: TextStyle(color: AppColors.textoClaro, fontSize: 13)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.cargarRetos,
          color: AppColors.terracota,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: retos.length,
            itemBuilder: (context, index) {
              final reto = retos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.terracota.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        color: AppColors.terracota),
                  ),
                  title: Text(reto.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    reto.grado != null ? 'Grado: ${reto.grado}' : 'Sin grado',
                    style: const TextStyle(color: AppColors.textoClaro),
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Eliminar'),
                        onTap: () => controller.eliminarReto(reto.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCrear(context),
        backgroundColor: AppColors.terracota,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context) {
    final nombreCtrl = TextEditingController();
    String? gradoSeleccionado;
    final puntajeCtrl = TextEditingController(text: '100');
    final preguntasCtrl = <TextEditingController>[TextEditingController()];
    final preguntasKeys = <GlobalKey<FormFieldState>>[GlobalKey<FormFieldState>()];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Añadir Reto',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del reto',
                    hintText: 'Ej: Reto de vocabulario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: gradoSeleccionado,
                  onChanged: (v) =>
                      setDialogState(() => gradoSeleccionado = v),
                  decoration: const InputDecoration(
                    labelText: 'Grado escolar',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.gradosDisponibles
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: puntajeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Puntaje máximo',
                    hintText: '100',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Preguntas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          preguntasCtrl.add(TextEditingController());
                          preguntasKeys.add(GlobalKey<FormFieldState>());
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),
                ...List.generate(preguntasCtrl.length, (i) {
                  final ctrl = preguntasCtrl[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Pregunta ${i + 1}',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        if (preguntasCtrl.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () => setDialogState(() {
                              preguntasCtrl.removeAt(i);
                              preguntasKeys.removeAt(i);
                            }),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isNotEmpty &&
                    gradoSeleccionado != null) {
                  final preguntas = preguntasCtrl
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();
                  controller.crearReto(
                    nombre: nombreCtrl.text.trim(),
                    grado: gradoSeleccionado!,
                    puntajeMaximo: int.tryParse(puntajeCtrl.text),
                    preguntas: preguntas.isNotEmpty ? preguntas : null,
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
