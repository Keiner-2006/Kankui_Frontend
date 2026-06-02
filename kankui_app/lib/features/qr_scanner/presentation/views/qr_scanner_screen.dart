import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/scanner_controller.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final ScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ScannerController>();
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
              valueListenable: controller.cameraController,
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
            onPressed: () => controller.cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => controller.cameraController.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.cameraController,
            onDetect: controller.onDetect,
            scanWindow: scanWindow,
          ),
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
                  color: Colors.black.withValues(alpha: 0.6),
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
      ..color = Colors.black.withValues(alpha: 0.6)
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

    final double cornerLength = 30.0;

    canvas.drawLine(scanWindow.topLeft,
        scanWindow.topLeft + Offset(cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.topLeft,
        scanWindow.topLeft + Offset(0, cornerLength), borderPaint);

    canvas.drawLine(scanWindow.topRight,
        scanWindow.topRight + Offset(-cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.topRight,
        scanWindow.topRight + Offset(0, cornerLength), borderPaint);

    canvas.drawLine(scanWindow.bottomLeft,
        scanWindow.bottomLeft + Offset(cornerLength, 0), borderPaint);
    canvas.drawLine(scanWindow.bottomLeft,
        scanWindow.bottomLeft + Offset(0, -cornerLength), borderPaint);

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
