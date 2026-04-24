import 'package:flutter/material.dart';
import 'package:kankui_app/theme/app_theme.dart';

/// Widget de opción de respuesta para el Quiz
/// Muestra una palabra kankuama como opción seleccionable
/// Soporta estados: normal, seleccionada, correcta, incorrecta, bloqueada
class OpcionRespuestaWidget extends StatelessWidget {
  final String opcion;
  final int index;
  final bool esSeleccionada;
  final bool esCorrecta;
  final bool esIncorrecta;
  final bool bloqueada;
  final VoidCallback? onTap;

  const OpcionRespuestaWidget({
    super.key,
    required this.opcion,
    required this.index,
    this.esSeleccionada = false,
    this.esCorrecta = false,
    this.esIncorrecta = false,
    this.bloqueada = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool esInteractiva = onTap != null && !bloqueada;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: esInteractiva ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: _obtenerColorFondo(),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _obtenerColorBorde(),
                width: 2,
              ),
              boxShadow: esSeleccionada && !bloqueada
                  ? [
                      BoxShadow(
                        color: AppColors.terracota.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Letra de la opción (A, B, C, D)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _obtenerColorIcono(),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D...
                      style: TextStyle(
                        color: _obtenerColorTextoIcono(),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Texto de la opción
                Expanded(
                  child: Text(
                    opcion,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: _obtenerPesoFuente(),
                      color: _obtenerColorTexto(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Icono de estado
                if (esCorrecta)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.verdeSelva,
                    size: 24,
                  )
                else if (esIncorrecta)
                  Icon(
                    Icons.cancel_rounded,
                    color: AppColors.terracota,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _obtenerColorFondo() {
    if (esCorrecta) {
      return AppColors.verdeSelva.withValues(alpha: 0.2);
    }
    if (esIncorrecta) {
      return AppColors.terracota.withValues(alpha: 0.1);
    }
    if (esSeleccionada) {
      return AppColors.terracota.withValues(alpha: 0.1);
    }
    return Colors.white;
  }

  Color _obtenerColorBorde() {
    if (esCorrecta) {
      return AppColors.verdeSelva;
    }
    if (esIncorrecta) {
      return AppColors.terracota.withValues(alpha: 0.5);
    }
    if (esSeleccionada) {
      return AppColors.terracota;
    }
    return AppColors.cremaOscuro;
  }

  Color _obtenerColorIcono() {
    if (esCorrecta) {
      return AppColors.verdeSelva.withValues(alpha: 0.2);
    }
    if (esIncorrecta && esSeleccionada) {
      return AppColors.terracota.withValues(alpha: 0.2);
    }
    if (esSeleccionada) {
      return AppColors.terracota.withValues(alpha: 0.2);
    }
    return AppColors.cremaOscuro;
  }

  Color _obtenerColorTextoIcono() {
    if (esCorrecta) {
      return AppColors.verdeSelva;
    }
    if (esIncorrecta && esSeleccionada) {
      return AppColors.terracota;
    }
    if (esSeleccionada) {
      return AppColors.terracota;
    }
    return AppColors.textoMedio;
  }

  Color _obtenerColorTexto() {
    if (esCorrecta) {
      return AppColors.verdeSelva;
    }
    if (esIncorrecta && esSeleccionada) {
      return AppColors.terracota;
    }
    if (esSeleccionada) {
      return AppColors.terracota;
    }
    return AppColors.textoOscuro;
  }

  FontWeight _obtenerPesoFuente() {
    if (esSeleccionada || esCorrecta) {
      return FontWeight.bold;
    }
    return FontWeight.w500;
  }
}
