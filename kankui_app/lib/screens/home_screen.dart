import 'package:flutter/material.dart';
import 'package:kankui_app/models/usuario_model.dart';
import 'package:kankui_app/services/sesionmanager.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../data/user_progress.dart';
import '../widgets/sierra_path.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/user_stats_card.dart';
import 'lessons_screen.dart';
import 'qr_scanner_screen.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/sync/sync_service.dart';
import '../models/categoria_model.dart';
import '../repositories/categoria_repository.dart';
import '../services/service_locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 final session = SessionManager();

UsuarioModel? get usuario => session.usuario;
UserProgress get userProgress => session.progreso;
  List<CategoriaModel> _categorias = [];
  bool _loadingCategorias = true;
  int _currentIndex = 0;

 
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Sincronizar aplicación (Versión Alejandro)
      final syncService = SyncService(Supabase.instance.client);
      await syncService.syncApp();

      // Cargar categorías (Versión Keiner)
      final repo = locator<CategoriaRepository>();
      final categorias = await repo.getCategorias();
     categorias.sort((a, b) => a.orden.compareTo(b.orden));
      if (mounted) {
        setState(() {
          _categorias = categorias;
          _loadingCategorias = false;
        });
      }
    } catch (e) {
      print('Error en fetchData: $e');
      if (mounted) {
        setState(() {
          _loadingCategorias = false;
        });
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingCategorias
          ? const Center(child: CircularProgressIndicator(color: AppColors.terracota))
          :IndexedStack(
  index: _currentIndex,
  children: [
    _HomeContent(
      userProgress: userProgress,
      categorias: _categorias,
    ),
    LessonsScreen(
      userProgress: userProgress,
      initialCategorias: _categorias,
    ),
    const QrScannerScreen(),
    RankingScreen(userProgress: userProgress),
    ProfileScreen(userProgress: userProgress),
  ],
),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final UserProgress userProgress;
  final List<CategoriaModel> categorias;

  const _HomeContent({
    required this.userProgress,
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header con saludo
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // Tarjeta de estadísticas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: UserStatsCard(userProgress: userProgress),
            ),
          ),

          // Título del camino
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  KankuiIcons.sierra(size: 28, color: AppColors.terracota),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'El Camino de la Sierra',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.textoOscuro,
                            ),
                      ),
                      Text(
                        'Tu viaje por el conocimiento Kankuamo',
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

          // Mapa/Camino de lecciones
          SliverToBoxAdapter(
            child: SierraPath(
              leccionesCompletadas: userProgress.leccionesCompletadas,
              categorias: categorias,
            ),
          ),

          // Sección: Palabra del día
          SliverToBoxAdapter(
            child: _buildPalabraDelDia(context),
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Eyuama',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.terracota,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.terracota.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Buenos días',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.terracota,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Bienvenido al camino del saber',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textoMedio,
                    ),
              ),
            ],
          ),
          // Avatar/Icono de perfil
          GestureDetector(
            onTap: () {
              // Navegar a perfil
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.terracota.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.terracota.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child:
                    KankuiIcons.mochila(size: 28, color: AppColors.terracota),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalabraDelDia(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.terracota,
            AppColors.terracotaLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracota.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: KankuiIcons.espiral(size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Palabra del día',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kunsamunu',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '/kun-sa-mu-nu/',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sierra Nevada - El corazón del mundo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionButton(
                context,
                icon: Icons.volume_up_rounded,
                label: 'Escuchar',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                icon: Icons.bookmark_outline_rounded,
                label: 'Guardar',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.terracota,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.terracota,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
