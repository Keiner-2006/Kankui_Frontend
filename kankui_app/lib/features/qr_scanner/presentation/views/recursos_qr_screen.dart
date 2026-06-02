import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/recursos_qr_controller.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';

class RecursosQrScreen extends StatefulWidget {
  const RecursosQrScreen({super.key});

  @override
  State<RecursosQrScreen> createState() => _RecursosQrScreenState();
}

class _RecursosQrScreenState extends State<RecursosQrScreen> {
  late final RecursosQrController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RecursosQrController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
            controller.categoriaSeleccionada.value == null
                ? 'Recursos Didácticos QR'
                : controller.categoriaSeleccionada.value!.nombre,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18)),
        backgroundColor: const Color(0xFF5C2E00),
        elevation: 0,
        leading: controller.categoriaSeleccionada.value != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => controller.limpiarSeleccion(),
              )
            : null,
      ),
      body: controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4730A)))
          : controller.categoriaSeleccionada.value == null
              ? _buildCategoriasGrid()
              : _buildObjetosGrid(),
    ));
  }

  Widget _buildCategoriasGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Selecciona una categoría para ver sus objetos culturales:',
              style: TextStyle(
                  color: Color(0xFF8A6E5C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: controller.categorias.length,
              itemBuilder: (context, index) {
                final cat = controller.categorias[index];
                return _ItemCard(
                  title: cat.nombre,
                  subtitle: 'Ver objetos',
                  icon: Icons.folder_open_rounded,
                  onTap: () => controller.seleccionarCategoria(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjetosGrid() {
    if (controller.isLoadingObjetos.value) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4730A)),
      );
    }

    if (controller.objetosDeCategoria.isEmpty) {
      return const Center(child: Text('No hay palabras registradas en esta categoría'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Objetos Individuales',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              TextButton.icon(
                onPressed: () => _mostrarTodosLosQr(context),
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: const Text('Generar todos', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD4730A),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _mostrarQrGeneral(context, controller.categoriaSeleccionada.value!),
                icon: const Icon(Icons.qr_code_rounded, size: 18),
                label: const Text('QR Lección Completa', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8A6E5C),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: controller.objetosDeCategoria.length,
              itemBuilder: (context, index) {
                final vocablo = controller.objetosDeCategoria[index];
                return _ItemCard(
                  title: vocablo.palabra,
                  subtitle: vocablo.significado,
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => _mostrarQrIndividual(context, vocablo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarTodosLosQr(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          appBar: AppBar(
            title: const Text('Hoja de Recursos QR', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF5C2E00),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () { /* TODO: Implementar compartir PDF/Imagen */ },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: controller.objetosDeCategoria.length,
              itemBuilder: (context, index) {
                final vocablo = controller.objetosDeCategoria[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: QrImageView(
                          data: 'KANKUI_ITEM:${vocablo.id}',
                          version: QrVersions.auto,
                          size: 150.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vocablo.palabra,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        vocablo.significado,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarQrGeneral(BuildContext context, CategoriaModel cat) {
    _showQrDialog(context, 'KANKUI_LESSON:${cat.id}', 'Lección: ${cat.nombre}',
        'Escanea para abrir la lección completa.');
  }

  void _mostrarQrIndividual(BuildContext context, Vocablo vocablo) {
    _showQrDialog(context, 'KANKUI_ITEM:${vocablo.id}', vocablo.palabra,
        'Escanea este código colocado junto al objeto real: "${vocablo.significado}".');
  }

  void _showQrDialog(
      BuildContext context, String data, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square, color: Color(0xFF5C2E00)),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF5C2E00)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {/* TODO: Implementar impresión/compartir */},
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Compartir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5C2E00),
                      side: const BorderSide(color: Color(0xFF5C2E00)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ItemCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C2E00).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4730A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: const Color(0xFFD4730A)),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8A6E5C))),
          ],
        ),
      ),
    );
  }
}
