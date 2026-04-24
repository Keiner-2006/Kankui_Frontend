import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../repositories/categoria_repository.dart';
import '../data/seed/vocablos_data.dart';
import '../services/service_locator.dart';
import '../models/categoria_model.dart';
import 'lesson_detail_screen.dart';
import 'kankuama_info_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController cameraController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        debugPrint('🔍 QR Detectado: $code');
        
        // 1. Vibración para confirmar detección
        await HapticFeedback.lightImpact();

        setState(() {
          _isProcessing = true;
        });

        // Pausar la cámara
        await cameraController.stop();

        // 2. Lógica de redirección según el contenido
        if (code.startsWith('KANKUI_LESSON:')) {
          final String categoriaId = code.split(':').last;
          await _navigateToLesson(categoriaId);
        } else {
          // Fallback a la pantalla de información general
          await _navigateToInfo(code);
        }

        // 3. Reactivar al volver
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          await cameraController.start();
        }
      }
    }
  }

  Future<void> _navigateToLesson(String categoriaId) async {
    try {
      // Mostrar un indicador de carga si es necesario
      final categoriaRepo = locator<CategoriaRepository>();
      final CategoriaModel? categoria = await categoriaRepo.getCategoriaById(categoriaId);

      if (categoria != null) {
        final vocablos = VocablosData.obtenerPorCategoria(categoriaId);
        
        if (!mounted) return;
        
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonDetailScreen(
              categoria: categoria,
              vocablos: vocablos,
            ),
          ),
        );
      } else {
        _showError('No se encontró la lección para: $categoriaId');
      }
    } catch (e) {
      _showError('Error al cargar la lección: $e');
    }
  }

  Future<void> _navigateToInfo(String code) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KankuamaInfoScreen(qrCodeId: code),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 250,
      height: 250,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Descubrir QR Kankuamo'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.white);
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
            scanWindow: scanWindow,
          ),
          // Diseño del marco para escanear
          CustomPaint(
            painter: _ScannerOverlayPainter(scanWindow: scanWindow),
            child: Container(),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: const Text(
                  'Centra el código QR en el cuadro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;

  _ScannerOverlayPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(scanWindow, const Radius.circular(16)));

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.orange[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Dibujar esquinas
    final double cornerLength = 30.0;

    // Top-Left
    canvas.drawLine(scanWindow.topLeft,
        scanWindow.topLeft + Offset(cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.topLeft,
        scanWindow.topLeft + Offset(0, cornerLength), borderPaint);

    // Top-Right
    canvas.drawLine(scanWindow.topRight,
        scanWindow.topRight + Offset(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.topRight,
        scanWindow.topRight + Offset(0, cornerLength), borderPaint);

    // Bottom-Left
    canvas.drawLine(scanWindow.bottomLeft,
        scanWindow.bottomLeft + Offset(cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.bottomLeft,
        scanWindow.bottomLeft + Offset(0, -cornerLength), borderPaint);

    // Bottom-Right
    canvas.drawLine(scanWindow.bottomRight,
        scanWindow.bottomRight + Offset(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.bottomRight,
        scanWindow.bottomRight + Offset(0, -cornerLength), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
