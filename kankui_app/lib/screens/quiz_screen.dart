import 'package:flutter/material.dart';
import 'package:kankui_app/theme/app_theme.dart';
import 'package:kankui_app/models/categoria_model.dart';
import 'package:kankui_app/models/reto_model.dart';
import 'package:kankui_app/data/seed/vocablos_data.dart';
import 'package:kankui_app/repositories/quiz_repository.dart';
import 'package:kankui_app/screens/quiz_question_screen.dart';

/// Pantalla principal de selección de Quiz
class QuizScreen extends StatefulWidget {
  final CategoriaModel? categoria;
  final String? leccionId;
  final int? cantidadPreguntas;
  final bool desdeLeccion;
  final List<Vocablo>? vocablosLeccion;

  const QuizScreen({
    super.key,
    this.categoria,
    this.leccionId,
    this.cantidadPreguntas,
    this.desdeLeccion = false,
    this.vocablosLeccion,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository _quizRepository = QuizRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reto Kankui',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.terracota,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            if (widget.desdeLeccion && widget.categoria != null)
              _buildEncabezadoLeccion()
            else
              _buildEncabezadoGeneral(),
            const SizedBox(height: 24),

            // Tarjeta de selección de quiz
            _buildTarjetaSeleccionQuiz(),
            const SizedBox(height: 24),

            // Opciones adicionales (solo si NO es desde lección)
            if (!widget.desdeLeccion) ...[
              Text(
                'Otros desafíos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildOpcionesAdicionales(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezadoLeccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.verdeSelva.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.verdeSelva.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.verdeSelva,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Felicidades!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.verdeSelva,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Has completado la lección',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textoMedio,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Demuestra lo aprendido',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textoOscuro,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pon a prueba tus conocimientos con este quiz de ${widget.cantidadPreguntas ?? widget.vocablosLeccion?.length ?? 10} preguntas sobre ${widget.categoria?.nombre ?? 'esta categoría'}.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textoMedio,
              ),
        ),
      ],
    );
  }

  Widget _buildEncabezadoGeneral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige tu desafío',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textoOscuro,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona una categoría y pon a prueba tus conocimientos en kankuama.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textoMedio,
              ),
        ),
      ],
    );
  }

  Widget _buildTarjetaSeleccionQuiz() {
    final categoria = widget.categoria;

    return Card(
      elevation: 8,
      shadowColor: AppColors.terracota.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColors.cremaOscuro.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _iniciarQuiz(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.terracota.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: AppColors.terracota,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoria?.nombre ?? 'Quiz General',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textoOscuro,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.cantidadPreguntas ?? widget.vocablosLeccion?.length ?? 10} preguntas • General',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textoClaro,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.terracota,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionesAdicionales() {
    return Column(
      children: [
        _buildOpcionCard(
          icon: Icons.star_rounded,
          iconColor: AppColors.doradoSol,
          gradientColors: [AppColors.doradoSol.withValues(alpha: 0.1), Colors.white],
          title: 'Palabras en Recuperación',
          subtitle: 'Refuerza tu aprendizaje de palabras difíciles',
          onTap: () => _iniciarQuizRecuperacion(),
        ),
        const SizedBox(height: 12),
        _buildOpcionCard(
          icon: Icons.shuffle_rounded,
          iconColor: AppColors.verdeMontana,
          gradientColors: [AppColors.verdeMontana.withValues(alpha: 0.1), Colors.white],
          title: 'Quiz General',
          subtitle: 'Preguntas de todas las categorías',
          onTap: () => _iniciarQuizGeneral(),
        ),
      ],
    );
  }

  Widget _buildOpcionCard({
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
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
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textoClaro,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textoClaro),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _iniciarQuiz() async {
    final categoria = widget.categoria;
    final cantidad = widget.cantidadPreguntas ?? 10;

    if (categoria == null) {
      _iniciarQuizGeneral();
      return;
    }

    // Si viene desde una lección y tiene vocablos específicos, usar el generador de preguntas de lección
    if (widget.desdeLeccion && widget.vocablosLeccion != null && widget.vocablosLeccion!.isNotEmpty) {
      final preguntas = _quizRepository.generarPreguntasDeLeccion(
        vocablos: widget.vocablosLeccion!,
      );

      final reto = RetoQuizModel(
        id: 'reto_${categoria.id}_${DateTime.now().millisecondsSinceEpoch}',
        nombre: 'Quiz: ${categoria.nombre}',
        preguntasQuiz: preguntas,
        leccionId: widget.leccionId,
      );

      if (!mounted) return;

      final resultados = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => QuizQuestionScreen(
            reto: reto,
            categoriaNombre: categoria.nombre,
          ),
        ),
      );

      if (resultados == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Quiz completado exitosamente!'),
            backgroundColor: AppColors.verdeSelva,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Modo normal: generar preguntas de la categoría
    final preguntas = _quizRepository.generarPreguntas(
      cantidad: cantidad,
      categoria: categoria.id,
      dificultadMin: 1,
      dificultadMax: 3,
    );

    final reto = RetoQuizModel(
      id: 'reto_${categoria.id}_${DateTime.now().millisecondsSinceEpoch}',
      nombre: 'Quiz: ${categoria.nombre}',
      preguntasQuiz: preguntas,
      leccionId: widget.leccionId,
    );

    if (!mounted) return;

    final resultados = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizQuestionScreen(
          reto: reto,
          categoriaNombre: categoria.nombre,
        ),
      ),
    );

    if (resultados == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Quiz completado exitosamente!'),
          backgroundColor: AppColors.verdeSelva,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _iniciarQuizGeneral() async {
    final reto = _quizRepository.crearReto(
      id: 'reto_general_${DateTime.now().millisecondsSinceEpoch}',
      cantidadPreguntas: 10,
      aleatorio: true,
    );

    if (!mounted) return;

    final resultados = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizQuestionScreen(
          reto: reto,
          categoriaNombre: 'General',
        ),
      ),
    );

    if (resultados == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Quiz completado exitosamente!'),
          backgroundColor: AppColors.verdeSelva,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _iniciarQuizRecuperacion() async {
    final reto = _quizRepository.crearReto(
      id: 'reto_recup${DateTime.now().millisecondsSinceEpoch}',
      categoria: null,
      cantidadPreguntas: 8,
      aleatorio: true,
    );

    if (!mounted) return;

    final resultados = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizQuestionScreen(
          reto: reto,
          categoriaNombre: 'Recuperación',
        ),
      ),
    );

    if (resultados == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Quiz completado exitosamente!'),
          backgroundColor: AppColors.verdeSelva,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
