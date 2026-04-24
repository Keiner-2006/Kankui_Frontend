import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kankui_app/theme/app_theme.dart';
import 'package:kankui_app/models/reto_model.dart';
import 'package:kankui_app/models/pregunta_quiz_model.dart';
import 'package:kankui_app/repositories/quiz_repository.dart';
import 'package:kankui_app/widgets/opcion_respuesta_widget.dart';
import 'package:kankui_app/services/audio_service.dart';

/// Pantalla de pregunta individual del Quiz
/// Muestra una pregunta con opciones múltiples
/// Navega a la siguiente pregunta o al resumen al finalizar
class QuizQuestionScreen extends StatefulWidget {
  final RetoQuizModel reto;
  final String? categoriaNombre;

  const QuizQuestionScreen({
    super.key,
    required this.reto,
    this.categoriaNombre,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen>
    with SingleTickerProviderStateMixin {
  final QuizRepository _quizRepository = QuizRepository();
  late List<PreguntaQuizModel> _preguntas;
  late List<int?> _respuestasUsuario;
  late int _preguntaIndex;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  int? _selectedOptionIndex;
  bool _mostrandoResultado = false;
  bool _respondida = false;

  @override
  void initState() {
    super.initState();
    _preguntas = widget.reto.preguntasQuiz;
    _respuestasUsuario = List<int?>.filled(_preguntas.length, null);
    _preguntaIndex = 0;

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.easeInOut),
    );

    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_respondida && mounted) {
        // ⏰️ Tiempo agotado: registrar como no respondida y mostrar resultado
        setState(() {
          _mostrandoResultado = true;
          // No cambiamos _respondida para evitar que aparezca el botón "Continuar"
        });
        _respuestasUsuario[_preguntaIndex] = null;

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _mostrandoResultado = false;
              _selectedOptionIndex = null;
              _preguntaIndex++;
              if (_preguntaIndex < _preguntas.length) {
                _timerController.reset();
                _timerController.forward();
              } else {
                _finalizarQuiz();
              }
            });
          }
        });
      }
    });

    _timerController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = _preguntas[_preguntaIndex];

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _mostrarConfirmacionSalida,
        ),
        title: Text(
          widget.categoriaNombre ?? 'Quiz',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.terracota,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.verdeSelva.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_preguntaIndex + 1}/${_preguntas.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.verdeSelva,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de tiempo
            _buildBarraTiempo(),
            const SizedBox(height: 8),

            // Progreso general
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: (_preguntaIndex + 1) / _preguntas.length,
                backgroundColor: AppColors.cremaOscuro,
                color: AppColors.terracota,
                minHeight: 4,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enunciado
                    _buildEnunciado(pregunta),
                    const SizedBox(height: 24),

                    // Opciones de respuesta
                    _buildOpcionesRespuesta(pregunta),

                    // Pista
                    if (pregunta.pista != null && !_respondida)
                      _buildPista(pregunta.pista!),

                    // Resultado
                    if (_mostrandoResultado) _buildResultadoPregunta(pregunta),
                  ],
                ),
              ),
            ),

            // Botón siguiente
            if (_respondida) _buildBotonSiguiente(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraTiempo() {
    return AnimatedBuilder(
      animation: _timerAnimation,
      builder: (context, child) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.terracota, AppColors.terracotaLight],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          width: MediaQuery.of(context).size.width * _timerAnimation.value,
        );
      },
    );
  }

  Widget _buildEnunciado(PreguntaQuizModel pregunta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge de tipo de pregunta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pregunta.tipo == TipoPreguntaQuiz.kankuamaASignificado
                  ? AppColors.verdeSelva.withValues(alpha: 0.2)
                  : AppColors.terracota.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pregunta.tipo == TipoPreguntaQuiz.kankuamaASignificado
                  ? 'Palabra Kankuama → Significado'
                  : 'Significado → Palabra Kankuama',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        pregunta.tipo == TipoPreguntaQuiz.kankuamaASignificado
                            ? AppColors.verdeSelva
                            : AppColors.terracota,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.terracota.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_rounded,
                  color: AppColors.terracota,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  pregunta.enunciado,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textoOscuro,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionesRespuesta(PreguntaQuizModel pregunta) {
    return Column(
      children: pregunta.opciones.asMap().entries.map((entry) {
        final index = entry.key;
        final opcion = entry.value;
        final esCorrecta = index == pregunta.respuestaCorrectaIndex;
        final esSeleccionada = _selectedOptionIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OpcionRespuestaWidget(
            opcion: opcion,
            index: index,
            esSeleccionada: esSeleccionada,
            esCorrecta: _mostrandoResultado && esCorrecta,
            esIncorrecta: _mostrandoResultado && esSeleccionada && !esCorrecta,
            bloqueada: _respondida,
            onTap: _respondida || _mostrandoResultado
                ? null
                : () => _seleccionarRespuesta(index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPista(String pista) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.doradoSol.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.doradoSol),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pista,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textoMedio,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadoPregunta(PreguntaQuizModel pregunta) {
    // Si no hay respuesta seleccionada (tiempo agotado)
    if (_selectedOptionIndex == null) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.terracota.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.timer_off_rounded,
              color: AppColors.terracota,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Tiempo agotado!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.terracota,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'La respuesta correcta es: ${pregunta.respuestaCorrecta}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoMedio,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final acierto = _selectedOptionIndex == pregunta.respuestaCorrectaIndex;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: acierto
            ? AppColors.verdeSelva.withValues(alpha: 0.15)
            : AppColors.terracota.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            acierto ? Icons.check_circle_rounded : Icons.error_rounded,
            color: acierto ? AppColors.verdeSelva : AppColors.terracota,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acierto ? '¡Correcto!' : 'Incorrecto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: acierto
                            ? AppColors.verdeSelva
                            : AppColors.terracota,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!acierto)
                  Text(
                    'La respuesta correcta es: ${pregunta.respuestaCorrecta}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textoMedio,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonSiguiente() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton.icon(
        onPressed: _siguientePregunta,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: AppColors.terracota,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: Icon(
          _preguntaIndex < _preguntas.length - 1
              ? Icons.arrow_forward_rounded
              : Icons.check_rounded,
        ),
        label: Text(
          _preguntaIndex < _preguntas.length - 1 ? 'Siguiente' : 'Finalizar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  void _seleccionarRespuesta(int index) {
    setState(() {
      _selectedOptionIndex = index;
      _respondida = true;
      _timerController.stop();
    });

    _respuestasUsuario[_preguntaIndex] = index;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _mostrandoResultado = true;
        });
      }
    });
  }

  void _siguientePregunta() {
    if (_preguntaIndex < _preguntas.length - 1) {
      setState(() {
        _preguntaIndex++;
        _mostrandoResultado = false;
        _respondida = false;
        _selectedOptionIndex = null;
        _timerController.reset();
        _timerController.forward();
      });
    } else {
      _finalizarQuiz();
    }
  }

  void _finalizarQuiz() {
    _timerController.stop();

    // 🔥 Cálculo manual: comparar cada respuesta con la correcta
    int correctas = 0;
    for (int i = 0; i < _preguntas.length; i++) {
      final respuesta = _respuestasUsuario[i];
      if (respuesta != null &&
          respuesta == _preguntas[i].respuestaCorrectaIndex) {
        correctas++;
      }
    }

    final respuestasValidas = _respuestasUsuario.where((r) => r != null).length;

    final resultado = {
      'total': _preguntas.length,
      'respondidas': respuestasValidas,
      'correctas': correctas,
      'puntos': correctas * 10,
      'porcentaje': (correctas / _preguntas.length * 100).round(),
    };

    _guardarProgreso(resultado);

    if (!mounted) return;

    final mostroResumen = Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResumenScreen(
          reto: widget.reto,
          resultado: resultado,
          preguntas: _preguntas,
          respuestasUsuario: _respuestasUsuario,
        ),
      ),
    );

    mostroResumen.then((value) {
      if (value == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  Future<void> _guardarProgreso(Map<String, dynamic> resultado) async {
    debugPrint('Progreso guardado: $resultado');
  }

  void _mostrarConfirmacionSalida() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('¿Salir del quiz?'),
        content: const Text('Tu progreso actual no se guardará.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracota,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de resumen final del Quiz
class QuizResumenScreen extends StatelessWidget {
  final RetoQuizModel reto;
  final Map<String, dynamic> resultado;
  final List<PreguntaQuizModel> preguntas;
  final List<int?> respuestasUsuario;

  const QuizResumenScreen({
    super.key,
    required this.reto,
    required this.resultado,
    required this.preguntas,
    required this.respuestasUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final correctas = resultado['correctas'] as int;
    final total = resultado['total'] as int;
    final porcentaje = resultado['porcentaje'] as int;
    final puntos = resultado['puntos'] as int;

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: correctas >= total * 0.7
                      ? AppColors.verdeSelva.withValues(alpha: 0.15)
                      : AppColors.terracota.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correctas >= total * 0.7
                      ? Icons.celebration_rounded
                      : Icons.school_rounded,
                  color: correctas >= total * 0.7
                      ? AppColors.verdeSelva
                      : AppColors.terracota,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Reto Completado!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has demostrado tu conocimiento en kankuama',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textoMedio,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildMetricCard(
                    context,
                    label: 'Correctas',
                    value: '$correctas/$total',
                    color: AppColors.verdeSelva,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    context,
                    label: 'Puntos',
                    value: '$puntos',
                    color: AppColors.doradoSol,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    context,
                    label: 'Precisión',
                    value: '$porcentaje%',
                    color: AppColors.terracota,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revisión de Respuestas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textoOscuro,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(preguntas.length, (index) {
                      final pregunta = preguntas[index];
                      final respuestaUsuario = respuestasUsuario[index];
                      final respondida = respuestaUsuario != null;
                      final correcta = respondida &&
                          respuestaUsuario == pregunta.respuestaCorrectaIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: correcta
                                    ? AppColors.verdeSelva
                                        .withValues(alpha: 0.2)
                                    : AppColors.terracota
                                        .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                correcta ? Icons.check : Icons.close,
                                color: correcta
                                    ? AppColors.verdeSelva
                                    : AppColors.terracota,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pregunta ${index + 1}: ${pregunta.enunciado}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textoOscuro,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tu respuesta: ${respondida ? pregunta.opciones[respuestaUsuario] : "No respondida"}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: respondida
                                              ? (correcta
                                                  ? AppColors.verdeSelva
                                                  : AppColors.terracota)
                                              : AppColors.textoClaro,
                                        ),
                                  ),
                                  if (!correcta && respondida)
                                    Text(
                                      'Correcta: ${pregunta.respuestaCorrecta}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.verdeSelva,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppColors.terracota,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Volver al Inicio'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textoClaro,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
