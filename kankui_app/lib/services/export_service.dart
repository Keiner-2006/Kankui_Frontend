import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:kankui_app/models/dashboard_data.dart';

/// Servicio para exportar el dashboard como PDF o imagen
class ExportService {
  
  /// Exporta un widget como imagen PNG (screenshot)
  Future<Uint8List?> exportAsImage(GlobalKey globalKey) async {
    try {
      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) return null;

      final image = await boundary.toImage(
        pixelRatio: 3.0, // alta calidad
      );
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error exportando imagen: $e');
      return null;
    }
  }

  /// Guarda una imagen en el almacenamiento local
  Future<String?> saveImageToStorage(Uint8List imageBytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/dashboard_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      return filePath;
    } catch (e) {
      debugPrint('Error guardando imagen: $e');
      return null;
    }
  }

  /// Genera un PDF con los datos del dashboard
  Future<Uint8List> generateDashboardPdf({
    required String userName,
    required String institution,
    required DateTime date,
    required int totalXp,
    required int racha,
    required int lecciones,
    required int escaneos,
    required List<Map<String, dynamic>> chartData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Dashboard de Progreso',
                  style:pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

               // Info del usuario y fecha
               pw.Row(
                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                 children: [
                   pw.Column(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                       pw.Text('Responsable: $userName',
                           style: const pw.TextStyle(fontSize: 14)),
                       pw.Text('Institución: $institution',
                           style: const pw.TextStyle(fontSize: 12)),
                     ],
                   ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text('Generado por Kankui App',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
              pw.Divider(height: 30),

              // KPIs principales
              pw.Text(
                'Métricas Clave',
                style:  pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Table.fromTextArray(
  headers: ['Métrica', 'Valor'],
  data: [
    ['XP Total', totalXp.toString()],
    ['Racha Actual', '$racha días'],
    ['Lecciones Completadas', lecciones.toString()],
    ['Escaneos Exitosos', escaneos.toString()],
  ],
  headerStyle: pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
  ),
  cellAlignment: pw.Alignment.centerLeft,
  cellStyle: pw.TextStyle(
    fontSize: 10,
  ),
),

              pw.SizedBox(height: 24),

              // Gráficos de datos
              pw.Text(
                'Resumen Gráfico',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              ...chartData.map((chart) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        chart['title'] ?? 'Gráfico',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      // Mostrar tabla de datos del gráfico
                      pw.Table.fromTextArray(
                        headers: [chart['labelKey'] ?? 'Categoría', chart['valueKey'] ?? 'Valor'],
                        data: (chart['data'] as List<Map<String, dynamic>>)
                            .map((item) => [
                                  item['label']?.toString() ?? '',
                                  (item['value']?.toStringAsFixed(0) ?? '0'),
                                ])
                            .toList(),
                        headerStyle: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                                              cellAlignment: pw.Alignment.centerLeft,
                        cellStyle: pw.TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 30),

              // Footer
              pw.Center(
                child: pw.Text(
                  '© 2026 Kankui - Lengua Kankuamo',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Comparte/exporta el PDF (abre diálogo de compartir/guardar)
  Future<void> sharePdf(BuildContext context, Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      debugPrint('Error compartiendo PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar PDF: $e')),
        );
      }
    }
  }

  /// Exporta y muestra diálogo de éxito
  Future<void> exportDashboardAsPdf({
    required BuildContext context,
    required String userName,
    required String institution,
    required DashboardData data,
  }) async {
    try {
      final pdfBytes = await generateDashboardPdf(
        userName: userName,
        institution: institution,
        date: DateTime.now(),
        totalXp: data.totalXp,
        racha: data.racha,
        lecciones: data.lecciones,
        escaneos: data.escaneos,
        chartData: [
          {
            'title': 'XP por Día',
            'labelKey': 'Fecha',
            'valueKey': 'XP',
            'data': data.xpPorDia
                .map((e) => {'label': e.label, 'value': e.valor})
                .toList(),
          },
          {
            'title': 'Actividad por Categoría',
            'labelKey': 'Categoría',
            'valueKey': 'Actividades',
            'data': data.actividadPorCategoria
                .map((e) => {'label': e.label, 'value': e.valor})
                .toList(),
          },
          {
            'title': 'Progreso Semanal',
            'labelKey': 'Semana',
            'valueKey': 'Lecciones',
            'data': data.progresoSemanal
                .map((e) => {'label': e.label, 'value': e.valor})
                .toList(),
          },
        ],
      );

      await sharePdf(context, pdfBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard exportado como PDF'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error exportando PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Exporta como imagen
  Future<void> exportDashboardAsImage({
    required BuildContext context,
    required GlobalKey key,
    required String fileName,
  }) async {
    try {
      final imageBytes = await exportAsImage(key);
      if (imageBytes == null) {
        throw Exception('No se pudo generar la imagen');
      }

      final filePath = await saveImageToStorage(imageBytes);
      if (filePath != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen guardada: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error exportando imagen: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
