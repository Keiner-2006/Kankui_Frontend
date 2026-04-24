import 'package:flutter/material.dart';

/// Widget de tarjeta KPI para mostrar métricas clave
/// Soporta iconos, valores grandes, etiquetas y tendencias
class KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color? color;
  final String? trend; // '+5%', '-2%', etc.
  final bool isPositive; // para color de tendencia
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? const Color(0xFFD4730A); // accent Kankui

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono con fondo circular
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: cardColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),

            // Valor principal
            Text(
              _formatNumber(value),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C1A0E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),

            // Etiqueta
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A6E5C),
                fontWeight: FontWeight.w500,
              ),
            ),

            // Tendencia (si existe)
            if (trend != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}
