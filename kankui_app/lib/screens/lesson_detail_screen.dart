import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/kankui_icons.dart';
import '../models/categoria_model.dart';
import '../data/seed/vocablos_data.dart';
import '../screens/quiz_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final CategoriaModel categoria;
  final List<Vocablo> vocablos;

  const LessonDetailScreen({
    super.key,
    required this.categoria,
    required this.vocablos,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _currentIndex = 0;
  bool _showSignificado = false;

  @override
  Widget build(BuildContext context) {
    if (widget.vocablos.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.crema,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.categoria.nombre),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 64,
                  color: AppColors.textoClaro,
                ),
                const SizedBox(height: 24),
                Text(
                  'No hay vocablos disponibles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textoOscuro,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pronto se añadirán nuevas palabras a esta categoría.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textoClaro,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vocablo = widget.vocablos[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.categoria.nombre),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.terracota.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentIndex + 1}/${widget.vocablos.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.terracota),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.cremaOscuro,
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: constraints.maxWidth * ((_currentIndex + 1) / widget.vocablos.length),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.terracota, AppColors.terracotaLight],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSignificado = !_showSignificado;
                        });
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _showSignificado
                            ? _buildSignificadoCard(context, vocablo)
                            : _buildPalabraCard(context, vocablo),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Toca la tarjeta para ver ${_showSignificado ? 'la palabra' : 'el significado'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoClaro,
                        ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.terracota,
                          ),
                          iconSize: 28,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('🔊 ${vocablo.fonetica}'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.terracota,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            if (_currentIndex > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _goToPrevious,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Anterior'),
                                ),
                              ),
                            if (_currentIndex > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _goToNext,
                                icon: Icon(
                                  _currentIndex < widget.vocablos.length - 1
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_rounded,
                                ),
                                label: Text(
                                  _currentIndex < widget.vocablos.length - 1
                                      ? 'Siguiente'
                                      : 'Completar',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalabraCard(BuildContext context, Vocablo vocablo) {
    return Container(
      key: const ValueKey('palabra'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.terracota, AppColors.terracotaLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracota.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: KankuiIcons.tejido(size: 40, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            vocablo.palabra,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  letterSpacing: 2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '/${vocablo.fonetica}/',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          const Spacer(),
          if (vocablo.enRecuperacion) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.doradoSol.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Palabra en recuperación',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignificadoCard(BuildContext context, Vocablo vocablo) {
    return Container(
      key: const ValueKey('significado'),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.verdeSelva.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: KankuiIcons.hoja(size: 40, color: AppColors.verdeSelva),
          ),
          const SizedBox(height: 32),
          Text(
            vocablo.significado,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.textoOscuro,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (vocablo.descripcionCultural != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.crema,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.terracota, size: 20),
                      const SizedBox(width: 8),
                      Text('Conocimiento de los Mayores', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.terracota)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vocablo.descripcionCultural!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textoMedio, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Text(vocablo.palabra, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.terracota, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showSignificado = false;
      });
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.vocablos.length - 1) {
      setState(() {
        _currentIndex++;
        _showSignificado = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.verdeSelva.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.celebration_rounded, color: AppColors.verdeSelva, size: 56),
              ),
              const SizedBox(height: 24),
              Text('¡Sewá!', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.verdeSelva, fontWeight: FontWeight.bold)),
              Text('(¡Gracias!)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textoClaro, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              Text('Has completado la lección de ${widget.categoria.nombre}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textoMedio), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(color: AppColors.doradoSol.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded, color: AppColors.doradoSol, size: 28),
                  const SizedBox(width: 8),
                  Text('+${widget.vocablos.length * 10} XP', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.doradoSol, fontWeight: FontWeight.bold)),
                ]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _mostrarOpcionesPostLeccion();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarOpcionesPostLeccion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Qué deseas hacer ahora?', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textoOscuro, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _mostrarQuiz();
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56), backgroundColor: AppColors.terracota, foregroundColor: Colors.white),
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Hacer Quiz'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentIndex = 0;
                    _showSignificado = false;
                  });
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 56), side: const BorderSide(color: AppColors.terracota)),
                icon: const Icon(Icons.replay_rounded, color: AppColors.terracota),
                label: Text('Repetir Lección', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.terracota)),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver al Inicio')),
          ],
        ),
      ),
    );
  }

  void _mostrarQuiz() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          categoria: widget.categoria,
          leccionId: widget.categoria.id,
          cantidadPreguntas: widget.vocablos.length,
          desdeLeccion: true,
          vocablosLeccion: widget.vocablos,
        ),
      ),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('¡Quiz completado exitosamente!'), backgroundColor: AppColors.verdeSelva, behavior: SnackBarBehavior.floating),
      );
    }
  }
}
