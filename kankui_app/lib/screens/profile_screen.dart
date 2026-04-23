import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../data/user_progress.dart';

class ProfileScreen extends StatelessWidget {
  final UserProgress userProgress;

  const ProfileScreen({super.key, required this.userProgress});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header del perfil
          SliverToBoxAdapter(child: _buildHeader(context)),

          // Estadísticas detalladas
          SliverToBoxAdapter(child: _buildEstadisticas(context)),

          // Sección de configuración
          SliverToBoxAdapter(child: _buildConfiguracion(context)),

          // Sobre la app
          SliverToBoxAdapter(child: _buildSobreLaApp(context)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final nivel = userProgress.nivelActual;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar grande
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.terracota, AppColors.terracotaLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.terracota.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: KankuiIcons.mochila(size: 56, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.verdeSelva,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Text(
                    '${nivel.nivel}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nombre
          Text(
            'Aprendiz Kankuamo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textoOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Nivel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.verdeSelva.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                KankuiIcons.espiral(size: 16, color: AppColors.verdeSelva),
                const SizedBox(width: 8),
                Text(
                  'Nivel ${nivel.nivel} - ${nivel.nombre}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.verdeSelva,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Cita motivacional
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cremaOscuro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.terracota.withValues(alpha: 0.5),
                  size: 24,
                ),
                Text(
                  '"El conocimiento es como el agua de la Sierra, fluye de los Mayores hacia las nuevas generaciones."',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textoMedio,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '— Sabiduría Kankuama',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.terracota,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Camino',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textoOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.star_rounded,
                  value: '${userProgress.xpTotal}',
                  label: 'XP Total',
                  color: AppColors.doradoSol,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  value: '${userProgress.rachaDias}',
                  label: 'Días de racha',
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.school_rounded,
                  value: '${userProgress.leccionesCompletadas}',
                  label: 'Lecciones',
                  color: AppColors.verdeSelva,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.remove_red_eye_rounded,
                  value: '${userProgress.escaneoExitosos}',
                  label: 'Escaneos',
                  color: AppColors.azulCielo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.emoji_events_rounded,
                  value: '${userProgress.logrosDesbloqueados.length}',
                  label: 'Logros',
                  color: AppColors.terracota,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.translate_rounded,
                  value: '24',
                  label: 'Vocablos aprendidos',
                  color: AppColors.verdeMontana,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textoOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textoMedio),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguracion(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Configuración',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textoOscuro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildConfigItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Recordatorios',
            subtitle: 'Recibe notificaciones diarias',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: AppColors.terracota,
            ),
          ),
          _buildConfigItem(
            context,
            icon: Icons.volume_up_outlined,
            title: 'Sonidos',
            subtitle: 'Efectos de sonido en la app',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeThumbColor: AppColors.terracota,
            ),
          ),
          _buildConfigItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Modo nocturno',
            subtitle: 'Tema oscuro para la app',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeThumbColor: AppColors.terracota,
            ),
          ),
          _buildConfigItem(
            context,
            icon: Icons.download_outlined,
            title: 'Descargar contenido',
            subtitle: 'Para uso sin conexión',
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textoClaro,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildConfigItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cremaOscuro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.terracota, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textoOscuro,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textoClaro,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSobreLaApp(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.terracota.withValues(alpha: 0.1),
            AppColors.verdeSelva.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.terracota.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              KankuiIcons.sierra(size: 32, color: AppColors.terracota),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kankui App',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.terracota,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Versión 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textoClaro,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Una herramienta de resistencia cultural para la recuperación de la lengua Kankui del pueblo Kankuamo de la Sierra Nevada de Santa Marta.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textoMedio),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Texto largo aquí", // deja tu texto actual
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 8),
              Text("Otro"), // tu segundo widget
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
