import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                KankuiIcons.ojoAncestral(size: 36, color: AppColors.terracota),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ojo Ancestral',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.terracota,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Descubre el conocimiento en el mundo real',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textoClaro,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Área del escáner (simulada)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.textoOscuro.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  // Fondo con patrón
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: CustomPaint(painter: _ScannerBackgroundPainter()),
                    ),
                  ),

                  // Visor central
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.terracota.withValues(
                                  alpha: 0.6,
                                ),
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Anillos internos
                                Center(
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.terracota.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.terracota.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                // Icono central
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      KankuiIcons.ojoAncestral(
                                        size: 48,
                                        color: AppColors.terracota,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isScanning
                                            ? 'Buscando...'
                                            : 'Apunta a un objeto',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Esquinas decorativas
                  ..._buildCornerDecorations(),

                  // Instrucciones en la parte superior
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Enfoca una mochila, poporo o planta',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de escaneo y objetos recientes
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Botón principal de escaneo
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isScanning = !_isScanning;
                    });
                    // Simular escaneo
                    if (_isScanning) {
                      Future.delayed(const Duration(seconds: 2), () {
                        if (!mounted) return;
                        _showResultDialog(context);
                        setState(() {
                          _isScanning = false;
                        });
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isScanning
                            ? [AppColors.verdeSelva, AppColors.verdeMontana]
                            : [AppColors.terracota, AppColors.terracotaLight],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isScanning
                                      ? AppColors.verdeSelva
                                      : AppColors.terracota)
                                  .withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning
                              ? Icons.stop_rounded
                              : Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isScanning ? 'Escaneando...' : 'Iniciar Escaneo',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Objetos que puede reconocer
                _buildObjetosReconocibles(context),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Widget> _buildCornerDecorations() {
    return [
      // Esquina superior izquierda
      const Positioned(
        top: 60,
        left: 20,
        child: _CornerDecoration(isTop: true, isLeft: true),
      ),
      // Esquina superior derecha
      const Positioned(
        top: 60,
        right: 20,
        child: _CornerDecoration(isTop: true, isLeft: false),
      ),
      // Esquina inferior izquierda
      const Positioned(
        bottom: 20,
        left: 20,
        child: _CornerDecoration(isTop: false, isLeft: true),
      ),
      // Esquina inferior derecha
      const Positioned(
        bottom: 20,
        right: 20,
        child: _CornerDecoration(isTop: false, isLeft: false),
      ),
    ];
  }

  Widget _buildObjetosReconocibles(BuildContext context) {
    final objetos = [
      {'nombre': 'Mochila', 'icon': Icons.shopping_bag_outlined},
      {'nombre': 'Poporo', 'icon': Icons.egg_outlined},
      {'nombre': 'Planta', 'icon': Icons.local_florist_outlined},
      {'nombre': 'Tejido', 'icon': Icons.grid_4x4_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objetos reconocibles',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppColors.textoClaro),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: objetos.map((obj) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cremaOscuro,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    obj['icon'] as IconData,
                    color: AppColors.terracota,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  obj['nombre'] as String,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textoMedio),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showResultDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cremaOscuro,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verdeSelva.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.verdeSelva,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Objeto Reconocido!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.verdeSelva,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tutú - Mochila',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.terracota),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.crema,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Significado Cultural',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.terracota,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Símbolo del útero de la Madre Tierra. En su tejido se guarda el pensamiento. Cada patrón cuenta una historia ancestral.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textoMedio,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.doradoSol.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.doradoSol,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+25 XP',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.doradoSol,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerDecoration({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.terracota
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.terracota.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Patrón circular
    final center = Offset(size.width / 2, size.height / 2);
    for (double r = 50; r < size.width; r += 40) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
