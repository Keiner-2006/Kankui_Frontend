import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/domain/models/grupo_model.dart';
import 'package:kankui_app/features/docente/presentation/controllers/reto_grupo_controller.dart';
import 'package:kankui_app/shared/ui/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class AsignarRetoScreen extends StatefulWidget {
  final GrupoModel grupo;

  const AsignarRetoScreen({super.key, required this.grupo});

  @override
  State<AsignarRetoScreen> createState() => _AsignarRetoScreenState();
}

class _AsignarRetoScreenState extends State<AsignarRetoScreen> {
  late final RetoGrupoController controller;
  final _nombreCtrl = TextEditingController();
  final _puntajeCtrl = TextEditingController(text: '100');
  DateTime? _fechaLimite;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RetoGrupoController>();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _puntajeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        title: const Text('Asignar Reto',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGrupoInfo(context),
            const SizedBox(height: 24),
            _buildForm(context),
            const SizedBox(height: 32),
            _buildBotonAsignar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cremaOscuro),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.terracota.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.group_rounded,
                color: AppColors.terracota, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Asignando a:',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textoClaro)),
                Text(widget.grupo.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre del Reto',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textoOscuro)),
        const SizedBox(height: 8),
        TextField(
          controller: _nombreCtrl,
          decoration: const InputDecoration(
            hintText: 'Ej: Reto de vocabulario - Semana 1',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Puntaje Maximo',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textoOscuro)),
        const SizedBox(height: 8),
        TextField(
          controller: _puntajeCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '100',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Fecha Limite (opcional)',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textoOscuro)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _seleccionarFecha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cremaOscuro),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fechaLimite != null
                      ? '${_fechaLimite!.day}/${_fechaLimite!.month}/${_fechaLimite!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    color: _fechaLimite != null
                        ? AppColors.textoOscuro
                        : AppColors.textoClaro,
                  ),
                ),
                const Icon(Icons.calendar_today_rounded,
                    color: AppColors.terracota, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() => _fechaLimite = fecha);
    }
  }

  Widget _buildBotonAsignar(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _guardando ? null : _asignarReto,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracota,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _guardando
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Asignar Reto al Grupo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _asignarReto() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el reto')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await controller.asignarReto(
        retoId: const Uuid().v4(),
        grupoId: widget.grupo.id,
        nombreReto: _nombreCtrl.text.trim(),
        puntajeMaximo: int.tryParse(_puntajeCtrl.text) ?? 100,
        fechaLimite: _fechaLimite,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reto asignado exitosamente'),
            backgroundColor: AppColors.verdeSelva,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
