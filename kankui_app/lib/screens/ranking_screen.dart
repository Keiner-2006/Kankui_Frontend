import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../data/user_progress.dart';

class RankingScreen extends StatelessWidget {
  final UserProgress userProgress;

  const RankingScreen({super.key, required this.userProgress});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  KankuiIcons.circuloSabiduria(
                    size: 36,
                    color: AppColors.terracota,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Círculo de Sabiduría',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: AppColors.terracota,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'El camino hacia la sabiduría ancestral',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoClaro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tu nivel actual
          SliverToBoxAdapter(child: _buildNivelActual(context)),

          // Ranking local
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Ranking de la Comunidad',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textoOscuro,
                ),
              ),
            ),
          ),

          // Lista de ranking
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildRankingItem(context, index);
              }, childCount: _rankingData.length),
            ),
          ),

          // Tus logros
          SliverToBoxAdapter(child: _buildLogrosSection(context)),

          // Niveles de sabiduría
          SliverToBoxAdapter(child: _buildNivelesSection(context)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildNivelActual(BuildContext context) {
    final nivel = userProgress.nivelActual;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.verdeSelva, AppColors.verdeMontana],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.verdeSelva.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Círculo del nivel
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nv.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${nivel.nivel}',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nivel.nombre,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nivel.descripcion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barra de progreso
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${userProgress.xpTotal} XP',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    '${userProgress.xpParaSiguienteNivel} XP para siguiente nivel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: userProgress.progresoNivel,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Estadísticas rápidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.local_fire_department_rounded,
                value: '${userProgress.rachaDias}',
                label: 'Racha',
              ),
              _buildStatItem(
                context,
                icon: Icons.school_rounded,
                value: '${userProgress.leccionesCompletadas}',
                label: 'Lecciones',
              ),
              _buildStatItem(
                context,
                icon: Icons.remove_red_eye_rounded,
                value: '${userProgress.escaneoExitosos}',
                label: 'Escaneos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(BuildContext context, int index) {
    final item = _rankingData[index];
    final isCurrentUser = item['isCurrentUser'] as bool;
    final position = index + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.terracota.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrentUser
            ? Border.all(color: AppColors.terracota, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Posición
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getPositionColor(position),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: position <= 3
                  ? const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      '$position',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.cremaOscuro,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: KankuiIcons.mochila(
                size: 24,
                color: AppColors.terracota.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item['nombre'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textoOscuro,
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.terracota,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tú',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item['nivel'] as String,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textoClaro),
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['xp']} XP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.terracota,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    size: 14,
                    color: AppColors.doradoSol,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${item['racha']} días',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textoClaro,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return AppColors.doradoSol;
      case 2:
        return AppColors.textoClaro;
      case 3:
        return AppColors.terracota;
      default:
        return AppColors.textoMedio;
    }
  }

  Widget _buildLogrosSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tus Logros',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textoOscuro,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('Ver todos')),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLogroChip(
                context,
                'Primera Palabra',
                Icons.star_rounded,
                true,
              ),
              _buildLogroChip(
                context,
                'Racha 3 días',
                Icons.local_fire_department,
                true,
              ),
              _buildLogroChip(
                context,
                'Ojo Ancestral',
                Icons.visibility,
                false,
              ),
              _buildLogroChip(
                context,
                'Racha 7 días',
                Icons.local_fire_department,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogroChip(
    BuildContext context,
    String nombre,
    IconData icon,
    bool desbloqueado,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: desbloqueado
            ? AppColors.doradoSol.withValues(alpha: 0.15)
            : AppColors.cremaOscuro,
        borderRadius: BorderRadius.circular(16),
        border: desbloqueado
            ? Border.all(color: AppColors.doradoSol.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: desbloqueado ? AppColors.doradoSol : AppColors.textoClaro,
          ),
          const SizedBox(width: 6),
          Text(
            nombre,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: desbloqueado
                  ? AppColors.textoOscuro
                  : AppColors.textoClaro,
              fontWeight: desbloqueado ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNivelesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveles de Sabiduría',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.textoOscuro),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nivelesSabiduria.length,
              itemBuilder: (context, index) {
                final nivel = nivelesSabiduria[index];
                final alcanzado = userProgress.xpTotal >= nivel.xpRequerido;

                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: alcanzado
                              ? AppColors.verdeSelva.withValues(alpha: 0.15)
                              : AppColors.cremaOscuro,
                          border: Border.all(
                            color: alcanzado
                                ? AppColors.verdeSelva
                                : AppColors.textoClaro.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${nivel.nivel}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: alcanzado
                                      ? AppColors.verdeSelva
                                      : AppColors.textoClaro,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nivel.nombre,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: alcanzado
                              ? AppColors.textoOscuro
                              : AppColors.textoClaro,
                          fontWeight: alcanzado
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Datos simulados del ranking
final List<Map<String, dynamic>> _rankingData = [
  {
    'nombre': 'María Villazón',
    'nivel': 'Árbol',
    'xp': 3250,
    'racha': 15,
    'isCurrentUser': false,
  },
  {
    'nombre': 'Juan Torres',
    'nivel': 'Fruto',
    'xp': 2100,
    'racha': 8,
    'isCurrentUser': false,
  },
  {
    'nombre': 'Ana Maestre',
    'nivel': 'Flor',
    'xp': 1650,
    'racha': 12,
    'isCurrentUser': false,
  },
  {
    'nombre': 'Carlos Arias',
    'nivel': 'Hoja',
    'xp': 1200,
    'racha': 6,
    'isCurrentUser': false,
  },
  {
    'nombre': 'Tú',
    'nivel': 'Raíz',
    'xp': 450,
    'racha': 5,
    'isCurrentUser': true,
  },
  {
    'nombre': 'Laura Mejía',
    'nivel': 'Brote',
    'xp': 380,
    'racha': 3,
    'isCurrentUser': false,
  },
  {
    'nombre': 'Pedro Orozco',
    'nivel': 'Brote',
    'xp': 250,
    'racha': 2,
    'isCurrentUser': false,
  },
  {
    'nombre': 'Diana Rojas',
    'nivel': 'Semilla',
    'xp': 120,
    'racha': 1,
    'isCurrentUser': false,
  },
];
