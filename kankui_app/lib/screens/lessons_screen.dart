import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../data/vocablos_data.dart';
import '../data/user_progress.dart';
import '../widgets/categoria_card.dart';
import '../models/categoria_model.dart';
import '../repositories/categoria_repository.dart';
import '../services/service_locator.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final UserProgress userProgress;
  final List<CategoriaModel>? initialCategorias;

  const LessonsScreen({
    super.key,
    required this.userProgress,
    this.initialCategorias,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<CategoriaModel> _categorias = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategorias != null) {
      _categorias = widget.initialCategorias!;
      _loading = false;
    } else {
      _fetchCategorias();
    }
  }

  Future<void> _fetchCategorias() async {
    final repo = locator<CategoriaRepository>();
    final categorias = await repo.getCategorias();
    
    if (mounted) {
      setState(() {
        _categorias = categorias;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KankuiIcons.mochila(size: 32, color: AppColors.terracota),
                      const SizedBox(width: 12),
                      Text(
                        'Kakatukwa-Lingo',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.terracota,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aprende la lengua de los ancestros',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textoMedio,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Progreso general
          SliverToBoxAdapter(
            child: _buildProgresoGeneral(context),
          ),

          // Título categorías
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Categorías de Aprendizaje',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textoOscuro,
                    ),
              ),
            ),
          ),

          // Lista de categorías (Cargando o Lista)
          if (_loading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.terracota),
                ),
              ),
            )
          else if (_categorias.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No hay categorías disponibles'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final categoria = _categorias[index];
                    // Nota: Todavía usamos VocablosData para los vocablos hasta que se cree PalabraRepository
                    final vocablosCategoria =
                        VocablosData.obtenerPorCategoria(categoria.id);
                    final progreso = _calcularProgresoCategoria(categoria.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CategoriaCard(
                        categoria: categoria,
                        cantidadVocablos: categoria.totalPalabras,
                        progreso: progreso,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonDetailScreen(
                                categoria: categoria,
                                vocablos: vocablosCategoria,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: _categorias.length,
                ),
              ),
            ),

          // Sección especial: Palabras en Recuperación
          SliverToBoxAdapter(
            child: _buildSeccionRecuperacion(context),
          ),

          // Espacio final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildProgresoGeneral(BuildContext context) {
    final totalVocablos = VocablosData.vocablos.length;
    final aprendidos = widget.userProgress.leccionesCompletadas * 3; // Simulación
    final porcentaje = (aprendidos / totalVocablos).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu Progreso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textoOscuro,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$aprendidos de $totalVocablos vocablos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoClaro,
                        ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.verdeSelva.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(porcentaje * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.verdeSelva,
                        fontWeight: FontWeight.bold,
                     ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso estilizada
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.cremaOscuro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: porcentaje,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.verdeSelva,
                          AppColors.verdeMontana,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Patrones de tejido en la barra
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomPaint(
                      painter: _TejidoBarraPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionRecuperacion(BuildContext context) {
    final palabrasRecuperacion = VocablosData.obtenerEnRecuperacion();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.doradoSol.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.doradoSol.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.doradoSol.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.doradoSol,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Palabras en Recuperación',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textoOscuro,
                          ),
                    ),
                    Text(
                      '${palabrasRecuperacion.length} palabras',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textoClaro,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Estas palabras están siendo recuperadas por el Cabildo y los Mayores. Tu aprendizaje ayuda a mantenerlas vivas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textoMedio,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: palabrasRecuperacion.take(5).map((vocablo) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.doradoSol.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  vocablo.palabra,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.terracota,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  double _calcularProgresoCategoria(String categoriaId) {
    // Simulación de progreso
    if (categoriaId.contains('saludos')) return 0.75;
    if (categoriaId.contains('familia')) return 0.6;
    if (categoriaId.contains('naturaleza')) return 0.4;
    if (categoriaId.contains('objetos')) return 0.25;
    if (categoriaId.contains('numeros')) return 0.5;
    return 0.1;
  }
}
class _TejidoBarraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Patrón diagonal sutil
    for (double i = -size.height; i < size.width + size.height; i += 8) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

