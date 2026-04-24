import 'package:flutter/material.dart';
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
import '../models/usuario_model.dart';
import '../repositories/categoria_repository.dart';
import '../services/service_locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionManager session = SessionManager();
  late UserProgress _userProgress;

  List<CategoriaModel> _categorias = [];
  bool _loadingCategorias = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _inicializarUserProgress();
    _fetchData();
  }

  void _inicializarUserProgress() {
    print('═══════════════════════════════════════════');
    print('📊 [XP DEBUG] Iniciando carga de progreso del usuario');

    final usuario = session.usuario;
    print('🔍 [XP DEBUG] Obteniendo usuario actual desde SessionManager');
    print('   ├─ Usuario: ${usuario != null ? usuario.nombre : 'N/A'}');

    if (usuario != null) {
      print('👤 [XP DEBUG] Usuario autenticado (ANTES de crear UserProgress):');
      print('   ├─ ID: ${usuario.id}');
      print('   ├─ Nombre: ${usuario.nombre}');
      print('   ├─ XP Total: ${usuario.xpTotal}');
      print('   ├─ XP Hoy: ${usuario.xpHoy}');
      print('   ├─ Racha días: ${usuario.rachaDias}');
      print('   ├─ Lecciones completadas: ${usuario.leccionesCompletadas}');
      print('   ├─ Escaneos exitosos: ${usuario.escaneosExitosos}');
      print('   └─ Logros: ${usuario.logros}');

      _userProgress = UserProgress(
        xpTotal: usuario.xpTotal ?? 0,
        xpHoy: usuario.xpHoy ?? 0,
        rachaDias: usuario.rachaDias ?? 0,
        leccionesCompletadas: usuario.leccionesCompletadas ?? 0,
        escaneoExitosos: usuario.escaneosExitosos ?? 0,
        logrosDesbloqueados: usuario.logros,
      );

      print('');
      print('✅ [XP DEBUG] UserProgress creado correctamente:');
      print('   ├─ XP Total: ${_userProgress.xpTotal}');
      print('   ├─ Racha: ${_userProgress.rachaDias} días');
      print('   ├─ Lecciones: ${_userProgress.leccionesCompletadas}');
      print('   └─ Escaneos: ${_userProgress.escaneoExitosos}');
    } else {
      print('⚠️ [XP DEBUG] No hay usuario autenticado');
      print('📦 [XP DEBUG] Usando valores por defecto (XP: 0)');

      _userProgress = const UserProgress(
        xpTotal: 0,
        xpHoy: 0,
        rachaDias: 0,
        leccionesCompletadas: 0,
        escaneoExitosos: 0,
        logrosDesbloqueados: [],
      );
    }

    print('═══════════════════════════════════════════');
  }

  Future<void> _fetchData() async {
    try {
      final usuario = session.usuario;

      if (usuario != null) {
        // 🔥 RECARGAR DATOS DEL USUARIO Y PROGRESO DESDE SUPABASE
        // El progreso está en la tabla 'estudiante', no en 'usuario'
        try {
          final supabase = Supabase.instance.client;

          // Consultar la tabla estudiante con join a usuario
          final data = await supabase
              .from('estudiante')
              .select('*, usuario:usuario_id(*)')
              .eq('usuario_id', usuario.id)
              .maybeSingle();

          if (data != null) {
            // EL progreso está en la tabla estudiante
            final usuarioData = data['usuario'] as Map<String, dynamic>;
            final mergedData = Map<String, dynamic>.from(usuarioData);

            // Agregar campos de progreso desde la tabla estudiante
            mergedData['xp_total'] = data['xp_total'] ?? 0;
            mergedData['xp_hoy'] = data['xp_hoy'] ?? 0;
            mergedData['racha_dias'] = data['racha_dias'] ?? 0;
            mergedData['lecciones_completadas'] =
                data['lecciones_completadas'] ?? 0;
            mergedData['escaneos_exitosos'] = data['escaneos_exitosos'] ?? 0;
            mergedData['logros'] = data['logros'] ?? [];

            final usuarioActualizado = UsuarioModel.fromJson(mergedData);
            session.loginEstudiante(usuarioActualizado);

            _userProgress = UserProgress(
              xpTotal: usuarioActualizado.xpTotal ?? 0,
              xpHoy: usuarioActualizado.xpHoy ?? 0,
              rachaDias: usuarioActualizado.rachaDias ?? 0,
              leccionesCompletadas:
                  usuarioActualizado.leccionesCompletadas ?? 0,
              escaneoExitosos: usuarioActualizado.escaneosExitosos ?? 0,
              logrosDesbloqueados: usuarioActualizado.logros,
            );

            print('✅ [HOME] Datos de usuario y progreso recargados');
            print('   ├─ XP Total: ${_userProgress.xpTotal}');
            print('   ├─ Racha: ${_userProgress.rachaDias}');
          } else {
            // Si no hay datos nuevos, usar los existentes del session
            _userProgress = UserProgress(
              xpTotal: usuario.xpTotal ?? 0,
              xpHoy: usuario.xpHoy ?? 0,
              rachaDias: usuario.rachaDias ?? 0,
              leccionesCompletadas: usuario.leccionesCompletadas ?? 0,
              escaneoExitosos: usuario.escaneosExitosos ?? 0,
              logrosDesbloqueados: usuario.logros,
            );
            print(
                '⚠️ [HOME] No se encontraron datos de estudiante, usando datos locales');
          }
        } catch (e) {
          print('⚠️ [HOME] Error recargando desde Supabase: $e');
          // En caso de error, usar datos existentes del session
          _userProgress = UserProgress(
            xpTotal: usuario.xpTotal ?? 0,
            xpHoy: usuario.xpHoy ?? 0,
            rachaDias: usuario.rachaDias ?? 0,
            leccionesCompletadas: usuario.leccionesCompletadas ?? 0,
            escaneoExitosos: usuario.escaneosExitosos ?? 0,
            logrosDesbloqueados: usuario.logros,
          );
        }
      }

      final syncService = SyncService(Supabase.instance.client);
      await syncService.syncApp();

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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.terracota))
          : IndexedStack(
              index: _currentIndex,
              children: [
                _HomeContent(
                    userProgress: _userProgress, categorias: _categorias),
                LessonsScreen(
                    userProgress: _userProgress,
                    initialCategorias: _categorias),
                const QrScannerScreen(),
                RankingScreen(userProgress: _userProgress),
                ProfileScreen(userProgress: _userProgress),
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

  String _obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    // Depuración de datos mostrados en UI
    print('═══════════════════════════════════════════');
    print('🎯 [XP DEBUG] Datos mostrados en HomeScreen:');
    print('   ├─ XP Total: ${userProgress.xpTotal}');
    print('   ├─ XP Hoy: ${userProgress.xpHoy}');
    print('   ├─ Racha: ${userProgress.rachaDias} días');
    print('   ├─ Lecciones completadas: ${userProgress.leccionesCompletadas}');
    print('   ├─ Escaneos exitosos: ${userProgress.escaneoExitosos}');
    print('   └─ Logros: ${userProgress.logrosDesbloqueados?.length ?? 0}');
    print('═══════════════════════════════════════════');

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
    final usuario = SessionManager().usuario;
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
                    usuario?.nombre ?? 'Viajero',
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
                      _obtenerSaludo(),
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
