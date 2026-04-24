import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get_it/get_it.dart';
import '../repositories/categoria_repository.dart';
import '../models/categoria_model.dart';
import '../data/seed/vocablos_data.dart';
import '../services/service_locator.dart';

class RecursosQrScreen extends StatefulWidget {
  const RecursosQrScreen({super.key});

  @override
  State<RecursosQrScreen> createState() => _RecursosQrScreenState();
}

class _RecursosQrScreenState extends State<RecursosQrScreen> {
  final CategoriaRepository _categoriaRepo = GetIt.I<CategoriaRepository>();
  List<CategoriaModel> _categorias = [];
  bool _isLoading = true;
  CategoriaModel? _categoriaSeleccionada;
  List<Vocablo> _objetosDeCategoria = [];
  bool _isLoadingObjetos = false;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await _categoriaRepo.getCategorias();
      setState(() {
        _categorias = categorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarCategoria(CategoriaModel cat) async {
    setState(() {
      _categoriaSeleccionada = cat;
      _isLoadingObjetos = true;
    });

    try {
      final repo = locator<CategoriaRepository>();
      // Traemos las palabras EN VIVO desde Supabase usando el ID real de la categoría
      final objetos = await repo.getVocablosPorCategoria(cat.id);

      if (mounted) {
        setState(() {
          _objetosDeCategoria = objetos;
          _isLoadingObjetos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingObjetos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar las palabras de la base de datos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
            _categoriaSeleccionada == null
                ? 'Recursos Didácticos QR'
                : _categoriaSeleccionada!.nombre,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18)),
        backgroundColor: const Color(0xFF5C2E00),
        elevation: 0,
        leading: _categoriaSeleccionada != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => setState(() => _categoriaSeleccionada = null),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4730A)))
          : _categoriaSeleccionada == null
              ? _buildCategoriasGrid()
              : _buildObjetosGrid(),
    );
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
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                return _ItemCard(
                  title: cat.nombre,
                  subtitle: 'Ver objetos',
                  icon: Icons.folder_open_rounded,
                  onTap: () => _seleccionarCategoria(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjetosGrid() {
    if (_isLoadingObjetos) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4730A)),
      );
    }

    if (_objetosDeCategoria.isEmpty) {
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
                onPressed: () => _mostrarQrGeneral(context, _categoriaSeleccionada!),
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
              itemCount: _objetosDeCategoria.length,
              itemBuilder: (context, index) {
                final vocablo = _objetosDeCategoria[index];
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
              itemCount: _objetosDeCategoria.length,
              itemBuilder: (context, index) {
                final vocablo = _objetosDeCategoria[index];
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