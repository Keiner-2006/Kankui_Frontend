import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../models/categoria_model.dart';
import '../data/seed/vocablos_data.dart';

/// Tarjeta de categoría de vocablos
class CategoriaCard extends StatelessWidget {
  final CategoriaModel categoria;
  final int cantidadVocablos;
  final double progreso;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.cantidadVocablos,
    required this.progreso,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono de la categoría
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: _buildIcon(),
              ),
            ),
            const SizedBox(width: 16),
            // Información de la categoría
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.nombre,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textoOscuro,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoria.descripcion ?? 'Explora el vocabulario de ${categoria.nombre}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textoClaro,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Barra de progreso
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.cremaOscuro,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progreso,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _getGradientColors(),
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progreso * 100).toInt()}%',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: _getGradientColors()[0],
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Cantidad de vocablos y flecha
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.cremaOscuro,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$cantidadVocablos',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textoMedio,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textoClaro,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (categoria.id) {
      case 'saludos':
        return [AppColors.terracota, AppColors.terracotaLight];
      case 'familia':
        return [AppColors.verdeSelva, AppColors.verdeMontana];
      case 'naturaleza':
        return [AppColors.azulCielo, const Color(0xFF7BA8C4)];
      case 'objetos_sagrados':
        return [AppColors.doradoSol, const Color(0xFFE8C878)];
      case 'numeros':
        return [const Color(0xFF8B5A6B), const Color(0xFFA67485)];
      case 'colores':
        return [const Color(0xFF6B8D5A), const Color(0xFF8BA87A)];
      case 'animales':
        return [AppColors.terracotaDark, AppColors.terracota];
      case 'plantas':
        return [AppColors.verdeMontana, const Color(0xFF6B9D7A)];
      default:
        return [AppColors.terracota, AppColors.terracotaLight];
    }
  }

  Widget _buildIcon() {
    const color = Colors.white;
    const size = 28.0;

    switch (categoria.icono) {
      case 'espiral':
        return KankuiIcons.espiral(size: size, color: color);
      case 'circulo':
        return KankuiIcons.circuloSabiduria(size: size, color: color);
      case 'sierra':
        return KankuiIcons.sierra(size: size, color: color);
      case 'poporo':
        return KankuiIcons.poporo(size: size, color: color);
      case 'tejido':
        return KankuiIcons.tejido(size: size, color: color);
      case 'mochila':
        return KankuiIcons.mochila(size: size, color: color);
      case 'hoja':
        return KankuiIcons.hoja(size: size, color: color);
      default:
        return KankuiIcons.espiral(size: size, color: color);
    }
  }
}
