import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/qr_scanner/presentation/controllers/scanner_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:kankui_app/shared/ui/theme/kankui_icons.dart';

class ScannerScreen extends GetView<ScannerController> {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              KankuiIcons.ojoAncestral(size: 36, color: AppColors.terracota),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ojo Ancestral', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.terracota, fontWeight: FontWeight.bold)),
                Text('Descubre el conocimiento en el mundo real', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textoClaro)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
