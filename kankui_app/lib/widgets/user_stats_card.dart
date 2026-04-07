import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/user_progress.dart';

/// Tarjeta de estadísticas del usuario mostrada en el home
class UserStatsCard extends StatelessWidget {
  final UserProgress userProgress;

  const UserStatsCard({
    super.key,
    required this.userProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracota.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila de estadísticas principales
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.error,
                  value: '${userProgress.rachaDias}',
                  label: 'Racha',
                  sublabel: 'días',
                ),
              ),
              _buildDivider(),
              Expanded(
                child: _StatItem(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.doradoSol,
                  value: '${userProgress.xpHoy}',
                  label: 'XP Hoy',
                  sublabel: '+',
                ),
              ),
              _buildDivider(),
              Expanded(
                child: _StatItem(
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppColors.terracota,
                  value: '${userProgress.logrosDesbloqueados.length}',
                  label: 'Logros',
                  sublabel: '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de nivel
          _buildLevelProgress(context),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.cremaOscuro,
    );
  }

  Widget _buildLevelProgress(BuildContext context) {
    final nivel = userProgress.nivelActual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.verdeSelva,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${nivel.nivel}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nivel.nombre,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textoOscuro,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '${userProgress.xpTotal} XP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textoClaro,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${userProgress.xpParaSiguienteNivel} XP más',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.verdeSelva,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.cremaOscuro,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: userProgress.progresoNivel,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.verdeSelva,
                        AppColors.verdeMontana,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String sublabel;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (sublabel == '+')
              Text(
                '+',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.verdeSelva,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textoOscuro,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (sublabel.isNotEmpty && sublabel != '+')
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 2),
                child: Text(
                  sublabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textoClaro,
                      ),
                ),
              ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textoClaro,
              ),
        ),
      ],
    );
  }
}
