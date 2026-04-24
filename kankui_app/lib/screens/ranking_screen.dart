import 'package:flutter/material.dart';
import 'package:kankui_app/repositories/estudiante_repository.dart';
import 'package:kankui_app/screens/docente_screen.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../data/user_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/models/estudiantes_model.dart';
class RankingScreen extends StatefulWidget {
  final UserProgress userProgress;

  const RankingScreen({super.key, required this.userProgress});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  bool _loading = true;
  late final EstudianteRepository _repo;
  List<EstudianteModel> _ranking = [];
  String? _errorMessage;

  // Niveles de sabiduría definidos localmente
  final List<_NivelSabiduria> _nivelesSabiduria = [
    _NivelSabiduria(nivel: 1, nombre: 'Semilla',  xpRequerido: 0),
    _NivelSabiduria(nivel: 2, nombre: 'Brote',    xpRequerido: 100),
    _NivelSabiduria(nivel: 3, nombre: 'Raíz',     xpRequerido: 300),
    _NivelSabiduria(nivel: 4, nombre: 'Hoja',     xpRequerido: 600),
    _NivelSabiduria(nivel: 5, nombre: 'Flor',     xpRequerido: 1000),
    _NivelSabiduria(nivel: 6, nombre: 'Fruto',    xpRequerido: 1500),
    _NivelSabiduria(nivel: 7, nombre: 'Árbol',    xpRequerido: 2500),
    _NivelSabiduria(nivel: 8, nombre: 'Bosque',   xpRequerido: 4000),
  ];

  @override
  void initState() {
    super.initState();
    _repo = EstudianteRepository(Supabase.instance.client);
    _cargarRanking();
  }

  Future<void> _cargarRanking() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repo.obtenerRankingGlobal();
      setState(() {
        _ranking = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar el ranking: ${e.toString()}';
        _loading = false;
        _ranking = [];
      });
    }
  }

  // ─── Helpers de nivel ───────────────────────────────────────────────────────

  String _obtenerNivelPorXP(int xp) {
    for (int i = _nivelesSabiduria.length - 1; i >= 0; i--) {
      if (xp >= _nivelesSabiduria[i].xpRequerido) {
        return _nivelesSabiduria[i].nombre;
      }
    }
    return _nivelesSabiduria.first.nombre;
  }

  int _obtenerNivelNumeroPorXP(int xp) {
    for (int i = _nivelesSabiduria.length - 1; i >= 0; i--) {
      if (xp >= _nivelesSabiduria[i].xpRequerido) {
        return _nivelesSabiduria[i].nivel;
      }
    }
    return 1;
  }

  int _calcularXPParaSiguienteNivel(int xpActual) {
    final nivelActual = _obtenerNivelNumeroPorXP(xpActual);
    final siguienteIndex = nivelActual; // 0-based → nivel 1 = índice 0
    if (siguienteIndex >= _nivelesSabiduria.length) return 0;
    return _nivelesSabiduria[siguienteIndex].xpRequerido - xpActual;
  }

  double _calcularProgresoNivel(int xpActual) {
    final nivelActual = _obtenerNivelNumeroPorXP(xpActual);
    final xpBase = nivelActual > 1
        ? _nivelesSabiduria[nivelActual - 2].xpRequerido
        : 0;
    final xpTope = _nivelesSabiduria[nivelActual - 1].xpRequerido;
    if (xpTope <= xpBase) return 1.0;
    return ((xpActual - xpBase) / (xpTope - xpBase)).clamp(0.0, 1.0);
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.terracota),
            )
          : RefreshIndicator(
              onRefresh: _cargarRanking,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Círculo de Sabiduría',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: AppColors.terracota,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'El camino hacia la sabiduría ancestral',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.textoClaro),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tu nivel actual
                  SliverToBoxAdapter(child: _buildNivelActual(context)),

                  // Banner de error (si existe)
                  if (_errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: _cargarRanking,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Título ranking + contador
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ranking de la Comunidad',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.textoOscuro),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.terracota.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_ranking.length} participantes',
                              style: TextStyle(
                                color: AppColors.terracota,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista vacía o lista de ranking
                  if (_ranking.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 64, color: AppColors.textoClaro),
                              SizedBox(height: 16),
                              Text(
                                'No hay estudiantes registrados',
                                style: TextStyle(color: AppColors.textoClaro),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildRankingItem(context, index),
                          childCount: _ranking.length,
                        ),
                      ),
                    ),

                  // Logros
                  SliverToBoxAdapter(child: _buildLogrosSection(context)),

                  // Niveles de sabiduría
                  SliverToBoxAdapter(child: _buildNivelesSection(context)),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  // ─── Nivel actual del usuario ────────────────────────────────────────────────

  Widget _buildNivelActual(BuildContext context) {
    final xpActual    = widget.userProgress.xpTotal;
    final nivelNumero = _obtenerNivelNumeroPorXP(xpActual);
    final nivelNombre = _obtenerNivelPorXP(xpActual);
    final progreso    = _calcularProgresoNivel(xpActual);
    final xpSiguiente = _calcularXPParaSiguienteNivel(xpActual);

    const descripciones = {
      'Semilla': 'Comienzas tu viaje en el conocimiento ancestral',
      'Brote':   'Empiezas a crecer en sabiduría',
      'Raíz':    'Te conectas con la tierra y la tradición',
      'Hoja':    'Absorbes el conocimiento como la luz del sol',
      'Flor':    'Compartes tu sabiduría con la comunidad',
      'Fruto':   'Cosechas los frutos de tu aprendizaje',
      'Árbol':   'Eres pilar de sabiduría para tu comunidad',
      'Bosque':  'Has alcanzado la más alta sabiduría ancestral',
    };
    final descripcionNivel =
        descripciones[nivelNombre] ?? 'Continúa tu camino de aprendizaje';

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
                        '$nivelNumero',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
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
                      nivelNombre,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcionNivel,
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
          // Barra de XP
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$xpActual XP',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  if (xpSiguiente > 0)
                    Text(
                      '$xpSiguiente XP para siguiente nivel',
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
                      widthFactor: progreso,
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
                value: '${widget.userProgress.rachaDias}',
                label: 'Racha',
              ),
              _buildStatItem(
                context,
                icon: Icons.school_rounded,
                value: '${widget.userProgress.leccionesCompletadas}',
                label: 'Lecciones',
              ),
              _buildStatItem(
                context,
                icon: Icons.remove_red_eye_rounded,
                value: '${widget.userProgress.escaneoExitosos}',
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

  // ─── Ítem del ranking ────────────────────────────────────────────────────────
  // Usa los campos reales del modelo Estudiante que vienen de Supabase

  Widget _buildRankingItem(BuildContext context, int index) {
    final EstudianteModel item = _ranking[index];
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    final isCurrentUser = item.usuarioId == currentUserId;
    final position      = index + 1;

    // Nombre completo desde la relación usuario
  final nombreFinal =
    '${item.nombre ?? ''} ${item.apellido ?? ''}'
        .trim()
        .ifEmpty('Sin nombre');
    final xp    = item.xpTotal;
    final racha = item.rachaDias;
    final nivel = _obtenerNivelPorXP(xp);

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
                  ? const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 20)
                  : Text(
                      '$position',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.white),
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
          // Nombre y nivel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nombreFinal,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: AppColors.textoOscuro,
                              fontWeight: isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.terracota,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tú',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
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
                  nivel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textoClaro),
                ),
              ],
            ),
          ),
          // XP y racha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp XP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.terracota,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 14, color: AppColors.doradoSol),
                  const SizedBox(width: 2),
                  Text(
                    '$racha días',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textoClaro),
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
        return const Color(0xFFC0C0C0); // Plata
      case 3:
        return const Color(0xFFCD7F32); // Bronce
      default:
        return AppColors.textoMedio;
    }
  }

  // ─── Logros ──────────────────────────────────────────────────────────────────
  // Los logros vienen de widget.userProgress.logrosDesbloqueados (List<String>?)
  // que debe estar mapeado desde la columna logros_desbloqueados del schema.

  Widget _buildLogrosSection(BuildContext context) {
    final logrosObtenidos =
        widget.userProgress.logrosDesbloqueados ?? <String>[];

    const todosLogros = [
      {'nombre': 'Primera Palabra',    'key': 'primera_palabra',   'icono': Icons.star_rounded},
      {'nombre': 'Racha 3 días',       'key': 'racha_3',           'icono': Icons.local_fire_department},
      {'nombre': 'Ojo Ancestral',      'key': 'ojo_ancestral',     'icono': Icons.visibility},
      {'nombre': 'Racha 7 días',       'key': 'racha_7',           'icono': Icons.local_fire_department},
      {'nombre': 'Sabio Principiante', 'key': 'sabio_principiante','icono': Icons.school},
      {'nombre': 'Explorador',         'key': 'explorador',        'icono': Icons.explore},
    ];

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
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.textoOscuro),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: todosLogros.take(4).map((logro) {
              final desbloqueado =
                  logrosObtenidos.contains(logro['key'] as String);
              return _buildLogroChip(
                context,
                logro['nombre'] as String,
                logro['icono'] as IconData,
                desbloqueado,
              );
            }).toList(),
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
            color:
                desbloqueado ? AppColors.doradoSol : AppColors.textoClaro,
          ),
          const SizedBox(width: 6),
          Text(
            nombre,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: desbloqueado
                      ? AppColors.textoOscuro
                      : AppColors.textoClaro,
                  fontWeight:
                      desbloqueado ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  // ─── Niveles de sabiduría ────────────────────────────────────────────────────

  Widget _buildNivelesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveles de Sabiduría',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.textoOscuro),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _nivelesSabiduria.length,
              itemBuilder: (context, index) {
                final nivel    = _nivelesSabiduria[index];
                final alcanzado =
                    widget.userProgress.xpTotal >= nivel.xpRequerido;

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
                                : AppColors.textoClaro
                                    .withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${nivel.nivel}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
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
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
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

// ─── Modelo local ────────────────────────────────────────────────────────────

class _NivelSabiduria {
  final int nivel;
  final String nombre;
  final int xpRequerido;

  const _NivelSabiduria({
    required this.nivel,
    required this.nombre,
    required this.xpRequerido,
  });
}

// ─── Extensión helper ────────────────────────────────────────────────────────

extension _StringIfEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}