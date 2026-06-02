import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/kankuama_info_controller.dart';

class KankuamaInfoScreen extends StatefulWidget {
  const KankuamaInfoScreen({super.key});

  @override
  State<KankuamaInfoScreen> createState() => _KankuamaInfoScreenState();
}

class _KankuamaInfoScreenState extends State<KankuamaInfoScreen> {
  late final KankuamaInfoController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<KankuamaInfoController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Colors.brown),
                SizedBox(height: 20),
                Text('Descifrando el conocimiento...', style: TextStyle(color: Colors.brown)),
              ],
            ),
          ),
        );
      }

      final info = controller.info.value;

      if (info == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('QR Desconocido'),
            backgroundColor: Colors.brown[800],
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'El código escaneado no contiene información Kankuama conocida.\n\nCódigo: ${controller.qrCodeId}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[800],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver a intentar'),
                  )
                ],
              ),
            ),
          ),
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.brown[800],
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
                title: Text(
                  info.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                ),
                background: info.imageUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            info.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(color: Colors.brown[400]),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      if (info.type != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            info.type!.toUpperCase(),
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        info.description,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            'Entendido',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
