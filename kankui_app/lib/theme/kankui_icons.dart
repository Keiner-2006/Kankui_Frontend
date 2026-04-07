import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Iconos personalizados inspirados en tejidos de mochila Kankuama
/// Diseñados con trazos orgánicos que evocan los patrones ancestrales
class KankuiIcons {
  
  /// Icono de Mochila - Símbolo del conocimiento tejido
  static Widget mochila({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MochilaPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Sierra/Montaña - La Sierra Nevada
  static Widget sierra({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SierraPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Espiral - Ciclo de vida y conocimiento
  static Widget espiral({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EspiralPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Poporo - Sabiduría ancestral
  static Widget poporo({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PoporoPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Hoja - Naturaleza y medicina tradicional
  static Widget hoja({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HojaPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Ojo - El Ojo Ancestral (escáner)
  static Widget ojoAncestral({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _OjoAncestralPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Círculo de Sabiduría - Progresión
  static Widget circuloSabiduria({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CirculoSabiduriaIconPainter(color ?? AppColors.terracota),
    );
  }
  
  /// Icono de Tejido - Patrón de mochila
  static Widget tejido({double size = 24, Color? color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TejidoPainter(color ?? AppColors.terracota),
    );
  }
}

class _MochilaPainter extends CustomPainter {
  final Color color;
  _MochilaPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path();
    
    // Cuerpo de la mochila (forma orgánica)
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.4,
      size.width * 0.15, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.9,
      size.width * 0.5, size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.9,
      size.width * 0.85, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.4,
      size.width * 0.7, size.height * 0.2,
    );
    
    // Cierre superior con curva
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.1,
      size.width * 0.3, size.height * 0.2,
    );
    
    canvas.drawPath(path, paint);
    
    // Patrón de tejido interno (líneas diagonales)
    final patternPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    
    // Líneas de tejido
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.6),
      patternPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.6),
      patternPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.55),
      Offset(size.width * 0.65, size.height * 0.55),
      patternPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SierraPainter extends CustomPainter {
  final Color color;
  _SierraPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path();
    
    // Tres picos de montaña (Sierra Nevada)
    path.moveTo(size.width * 0.05, size.height * 0.85);
    path.lineTo(size.width * 0.25, size.height * 0.35);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.65, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width * 0.95, size.height * 0.85);
    
    canvas.drawPath(path, paint);
    
    // Sol/luna sobre la sierra
    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.2),
      size.width * 0.08,
      circlePaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EspiralPainter extends CustomPainter {
  final Color color;
  _EspiralPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final path = Path();
    
    // Espiral que representa el ciclo de conocimiento
    double radius = size.width * 0.08;
    double angle = 0;
    
    path.moveTo(center.dx + radius, center.dy);
    
    for (int i = 0; i < 720; i += 15) {
      angle = i * 3.14159 / 180;
      radius = size.width * 0.08 + (i / 720) * size.width * 0.32;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
  }
  
  double cos(double radians) => _cos(radians);
  double sin(double radians) => _sin(radians);
  
  double _cos(double x) {
    x = x % (2 * 3.14159);
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }
  
  double _sin(double x) {
    x = x % (2 * 3.14159);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PoporoPainter extends CustomPainter {
  final Color color;
  _PoporoPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path();
    
    // Forma del poporo (calabaza)
    path.moveTo(size.width * 0.5, size.height * 0.15);
    
    // Cuello
    path.quadraticBezierTo(
      size.width * 0.35, size.height * 0.2,
      size.width * 0.35, size.height * 0.3,
    );
    
    // Cuerpo izquierdo
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.5,
      size.width * 0.25, size.height * 0.8,
    );
    
    // Base
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.95,
      size.width * 0.75, size.height * 0.8,
    );
    
    // Cuerpo derecho
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.5,
      size.width * 0.65, size.height * 0.3,
    );
    
    // Cierre cuello
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.2,
      size.width * 0.5, size.height * 0.15,
    );
    
    canvas.drawPath(path, paint);
    
    // Palito del poporo
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.05),
      Offset(size.width * 0.5, size.height * 0.25),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HojaPainter extends CustomPainter {
  final Color color;
  _HojaPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final path = Path();
    
    // Forma de hoja de coca
    path.moveTo(size.width * 0.5, size.height * 0.9);
    
    // Lado izquierdo
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.6,
      size.width * 0.2, size.height * 0.3,
    );
    
    // Punta superior
    path.quadraticBezierTo(
      size.width * 0.35, size.height * 0.05,
      size.width * 0.5, size.height * 0.1,
    );
    
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.05,
      size.width * 0.8, size.height * 0.3,
    );
    
    // Lado derecho
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.6,
      size.width * 0.5, size.height * 0.9,
    );
    
    canvas.drawPath(path, paint);
    
    // Nervadura central
    final veinPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.85),
      veinPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OjoAncestralPainter extends CustomPainter {
  final Color color;
  _OjoAncestralPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Forma del ojo
    final path = Path();
    
    path.moveTo(size.width * 0.05, size.height * 0.5);
    
    // Párpado superior
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.1,
      size.width * 0.95, size.height * 0.5,
    );
    
    // Párpado inferior
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.9,
      size.width * 0.05, size.height * 0.5,
    );
    
    canvas.drawPath(path, paint);
    
    // Iris
    final irisPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.18,
      irisPaint,
    );
    
    // Pupila
    final pupilPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.08,
      pupilPaint,
    );
    
    // Rayos ancestrales
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;
    
    // Rayos superiores
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.15),
      Offset(size.width * 0.35, size.height * 0.05),
      rayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.12),
      Offset(size.width * 0.5, size.height * 0.0),
      rayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.15),
      Offset(size.width * 0.65, size.height * 0.05),
      rayPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CirculoSabiduriaIconPainter extends CustomPainter {
  final Color color;
  _CirculoSabiduriaIconPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width * 0.5, size.height * 0.5);
    
    // Círculo exterior
    canvas.drawCircle(center, size.width * 0.4, paint);
    
    // Círculo interior
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    
    canvas.drawCircle(center, size.width * 0.25, innerPaint);
    
    // Punto central (semilla)
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size.width * 0.08, centerPaint);
    
    // Cuatro puntos cardinales
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.width * 0.32),
      size.width * 0.04,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + size.width * 0.32),
      size.width * 0.04,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.32, center.dy),
      size.width * 0.04,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.32, center.dy),
      size.width * 0.04,
      dotPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TejidoPainter extends CustomPainter {
  final Color color;
  _TejidoPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;
    
    // Patrón de tejido diagonal
    // Líneas diagonales izquierda a derecha
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.6),
      paint,
    );
    
    // Líneas diagonales derecha a izquierda
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.6),
      paint2,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.1),
      Offset(size.width * 0.4, size.height * 0.4),
      paint2,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.8),
      paint2,
    );
    
    // Líneas horizontales de conexión
    final paint3 = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint3,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.7),
      paint3,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

