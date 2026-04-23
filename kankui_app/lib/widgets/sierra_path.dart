import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../models/categoria_model.dart';

/// Widget que muestra el camino de la Sierra Nevada
/// Representación visual del progreso del usuario a través de las lecciones
class SierraPath extends StatelessWidget {
  final List<String> leccionesDesbloqueadas;
  final int leccionesCompletadas;
  final List<CategoriaModel> categorias;

  const SierraPath({
    super.key,
    required this.leccionesDesbloqueadas,
    required this.leccionesCompletadas,
    this.categorias = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomPaint(
        painter: _SierraPathPainter(),
        child: Stack(
          children: [
            // Nodos de las lecciones
            ..._buildLessonNodes(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLessonNodes(BuildContext context) {
    final nodes = <Widget>[];
    
    // Si no hay categorías de la DB, usar las hardcoded por defecto para no romper el UI
    final List<Map<String, dynamic>> lecciones = categorias.isEmpty 
      ? _leccionesData 
      : categorias.asMap().entries.map((entry) {
          int index = entry.key;
          CategoriaModel cat = entry.value;
          // Reutilizar coordenadas del camino predefinido si es posible
          final defaultData = index < _leccionesData.length ? _leccionesData[index] : _leccionesData.last;
          return {
            'id': cat.id,
            'nombre': cat.nombre,
            'icono': cat.icono ?? 'espiral',
            'x': defaultData['x'],
            'y': defaultData['y'],
          };
        }).toList();

    for (int i = 0; i < lecciones.length; i++) {
      final leccion = lecciones[i];
      final isDesbloqueada = leccionesDesbloqueadas.contains(leccion['id'].toString());
      final isCompletada = i < leccionesCompletadas;
      final isCurrent =
          isDesbloqueada && !isCompletada && i == leccionesCompletadas;

      nodes.add(
        Positioned(
          left: leccion['x'] as double,
          top: leccion['y'] as double,
          child: _LessonNode(
            nombre: leccion['nombre'] as String,
            icono: leccion['icono'] as String,
            isDesbloqueada: isDesbloqueada,
            isCompletada: isCompletada,
            isCurrent: isCurrent,
            onTap: isDesbloqueada ? () {} : null,
          ),
        ),
      );
    }

    return nodes;
  }
}

class _LessonNode extends StatelessWidget {
  final String nombre;
  final String icono;
  final bool isDesbloqueada;
  final bool isCompletada;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LessonNode({
    required this.nombre,
    required this.icono,
    required this.isDesbloqueada,
    required this.isCompletada,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;

    if (isCompletada) {
      backgroundColor = AppColors.verdeSelva;
      borderColor = AppColors.verdeMontana;
      iconColor = Colors.white;
    } else if (isCurrent) {
      backgroundColor = AppColors.terracota;
      borderColor = AppColors.terracotaLight;
      iconColor = Colors.white;
    } else if (isDesbloqueada) {
      backgroundColor = Colors.white;
      borderColor = AppColors.terracota;
      iconColor = AppColors.terracota;
    } else {
      backgroundColor = AppColors.cremaOscuro;
      borderColor = AppColors.textoClaro.withValues(alpha: 0.3);
      iconColor = AppColors.textoClaro;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nodo circular
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 70 : 60,
            height: isCurrent ? 70 : 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.terracota.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : isCompletada
                      ? [
                          BoxShadow(
                            color: AppColors.verdeSelva.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
            ),
            child: Center(
              child: _buildIcon(iconColor),
            ),
          ),
          const SizedBox(height: 6),
          // Nombre de la lección
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.terracota : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              nombre,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCurrent ? Colors.white : AppColors.textoMedio,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 10,
                  ),
            ),
          ),
          // Indicador de completado
          if (isCompletada) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.verdeSelva,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(Color color) {
    switch (icono) {
      case 'espiral':
        return KankuiIcons.espiral(size: 28, color: color);
      case 'mochila':
        return KankuiIcons.mochila(size: 28, color: color);
      case 'sierra':
        return KankuiIcons.sierra(size: 28, color: color);
      case 'poporo':
        return KankuiIcons.poporo(size: 28, color: color);
      case 'hoja':
        return KankuiIcons.hoja(size: 28, color: color);
      case 'tejido':
        return KankuiIcons.tejido(size: 28, color: color);
      default:
        return Icon(
          Icons.circle,
          size: 24,
          color: color,
        );
    }
  }
}

class _SierraPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.terracota.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Dibujar el camino que conecta las lecciones
    final path = Path();

    // Camino serpenteante que sube la sierra
    path.moveTo(size.width * 0.15 + 30, 50);
    path.quadraticBezierTo(
      size.width * 0.3,
      80,
      size.width * 0.55 + 30,
      90,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      100,
      size.width * 0.25 + 30,
      160,
    );
    path.quadraticBezierTo(
      size.width * 0.1,
      180,
      size.width * 0.6 + 30,
      230,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      250,
      size.width * 0.35 + 30,
      310,
    );

    canvas.drawPath(path, paint);

    // Dibujar montañas de fondo
    _drawMountains(canvas, size);
  }

  void _drawMountains(Canvas canvas, Size size) {
    final mountainPaint = Paint()
      ..color = AppColors.terracota.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Montaña de fondo
    final mountainPath = Path();
    mountainPath.moveTo(0, size.height);
    mountainPath.lineTo(size.width * 0.3, size.height * 0.4);
    mountainPath.lineTo(size.width * 0.5, size.height * 0.6);
    mountainPath.lineTo(size.width * 0.7, size.height * 0.2);
    mountainPath.lineTo(size.width, size.height * 0.5);
    mountainPath.lineTo(size.width, size.height);
    mountainPath.close();

    canvas.drawPath(mountainPath, mountainPaint);

    // Segunda montaña
    final mountain2Paint = Paint()
      ..color = AppColors.verdeSelva.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final mountain2Path = Path();
    mountain2Path.moveTo(0, size.height);
    mountain2Path.lineTo(size.width * 0.2, size.height * 0.5);
    mountain2Path.lineTo(size.width * 0.4, size.height * 0.7);
    mountain2Path.lineTo(size.width * 0.6, size.height * 0.3);
    mountain2Path.lineTo(size.width * 0.8, size.height * 0.6);
    mountain2Path.lineTo(size.width, size.height * 0.4);
    mountain2Path.lineTo(size.width, size.height);
    mountain2Path.close();

    canvas.drawPath(mountain2Path, mountain2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Datos de las lecciones para el mapa (Coordenadas predefinidas)
final List<Map<String, dynamic>> _leccionesData = [
  {
    'id': 'leccion_1',
    'nombre': 'Saludos',
    'icono': 'espiral',
    'x': 20.0,
    'y': 20.0
  },
  {
    'id': 'leccion_2',
    'nombre': 'Familia',
    'icono': 'mochila',
    'x': 180.0,
    'y': 60.0
  },
  {
    'id': 'leccion_3',
    'nombre': 'Naturaleza',
    'icono': 'sierra',
    'x': 50.0,
    'y': 130.0
  },
  {
    'id': 'leccion_4',
    'nombre': 'Sagrado',
    'icono': 'poporo',
    'x': 200.0,
    'y': 200.0
  },
  {
    'id': 'leccion_5',
    'nombre': 'Números',
    'icono': 'tejido',
    'x': 80.0,
    'y': 280.0
  },
  {
    'id': 'leccion_6',
    'nombre': 'Colores',
    'icono': 'hoja',
    'x': 220.0,
    'y': 330.0
  },
];
