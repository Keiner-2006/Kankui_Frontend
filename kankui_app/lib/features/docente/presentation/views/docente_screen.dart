import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kankui_app/features/docente/presentation/controllers/docente_controller.dart';
import 'package:kankui_app/features/docente/presentation/views/inscribirestudiante_screen.dart';
import 'package:kankui_app/features/qr_scanner/presentation/views/recursos_qr_screen.dart';

// ============================================================
// MODELOS DE DATOS
// ============================================================

/// Modelo del Profesor autenticado.
/// El nombre de la institución se obtiene desde este objeto.
class Profesor {
  final String nombre;
  final String apellido;
  final String correo;
  final String institucion; // <-- nombre de la IE que aparece en el header
  final String? avatarUrl;

  const Profesor({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.institucion,
    this.avatarUrl,
  });
}

/// Modelo de Estudiante registrado.
class Estudiante {
  final String id;
  final String nombre;
  final String apellido;
  final String pin;
  final String identificacion; // Número de identificación (join con usuario)
  final String? avatarUrl;

  const Estudiante({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.pin,
    this.identificacion = '',
    this.avatarUrl,
  });

  String get nombreCompleto => '$nombre $apellido';
  String get pinFormateado => 'K-$pin';
}

// ============================================================
// PALETA DE COLORES
// ============================================================

class _AppColors {
  static const headerBrown = Color(0xFF5C2E00);
  static const headerSubtitle = Color(0xFFD4956A);
  static const accent = Color(0xFFD4730A);
  static const accentLight = Color(0xFFF4A535);
  static const background = Color(0xFFFFF8F0);
  static const cardBackground = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2C1A0E);
  static const textSecondary = Color(0xFF8A6E5C);
  static const pinBackground = Color(0xFFF0EBE5);
  static const pinText = Color(0xFF3A7D44);
  static const searchBorder = Color(0xFFE0D5CB);
}

class DocenteScreen extends StatefulWidget {
  final String? maestroId;

  const DocenteScreen({super.key, this.maestroId});

  @override
  State<DocenteScreen> createState() => _DocenteScreenState();
}

class _DocenteScreenState extends State<DocenteScreen> {
  late final DocenteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DocenteController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentTab.value;

      return Scaffold(
        backgroundColor: _AppColors.background,
        body: SafeArea(
          child: currentIndex == 0
              ? _buildEstudiantesTab()
              : const RecursosQrScreen(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: controller.changeTab,
            selectedItemColor: _AppColors.accent,
            unselectedItemColor: _AppColors.textSecondary,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.group_rounded),
                activeIcon: Icon(Icons.group_rounded),
                label: 'Estudiantes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_2_rounded),
                activeIcon: Icon(Icons.qr_code_2_rounded),
                label: 'Recursos QR',
              ),
            ],
          ),
        ),
        floatingActionButton: currentIndex == 0
            ? _AddFab(
                onPressed: widget.onAgregarEstudiante,
                maestroId: widget.maestroId,
              )
            : null,
      );
    });
  }

  Widget _buildEstudiantesTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.cargarEstudiantes,
      color: _AppColors.accent,
      child: Column(
        children: [
          _Header(institucion: widget.profesor.institucion),
          _SearchBar(controller: controller.searchController),
          _ListHeader(
            cantidad: controller.estudiantesFiltrados.length,
            onExportar: widget.onExportar,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.cargando.value) {
      return const Center(
        child: CircularProgressIndicator(color: _AppColors.accent),
      );
    }

    if (controller.error.value != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: _AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                controller.error.value!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: _AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.cargarEstudiantes,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _EstudiantesList(estudiantes: controller.estudiantesFiltrados);
  }
}

class _Header extends StatelessWidget {
  final String institucion;
  const _Header({required this.institucion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _AppColors.headerBrown,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  institucion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Panel de Administración',
                  style: TextStyle(
                    color: _AppColors.headerSubtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: _AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.searchBorder),
          boxShadow: [
            BoxShadow(
              color: _AppColors.headerBrown.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(
            fontSize: 14,
            color: _AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Buscar estudiante...',
            hintStyle: TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _AppColors.textSecondary,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final int cantidad;
  const _ListHeader({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$cantidad Estudiante${cantidad == 1 ? '' : 's'} Registrado${cantidad == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 13,
              color: _AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstudiantesList extends StatelessWidget {
  final List<Map<String, dynamic>> estudiantes;

  const _EstudiantesList({required this.estudiantes});

  @override
  Widget build(BuildContext context) {
    if (estudiantes.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron estudiantes',
          style: TextStyle(color: _AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: estudiantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _EstudianteCard(
          estudiante: estudiantes[index],
          onTap: () {},
        );
      },
    );
  }
}

class _EstudianteCard extends StatelessWidget {
  final Map<String, dynamic> estudiante;
  final VoidCallback? onTap;

  const _EstudianteCard({required this.estudiante, this.onTap});

  @override
  Widget build(BuildContext context) {
    final nombre = (estudiante['nombre'] ?? 'Sin nombre').toString();
    final apellido = (estudiante['apellido'] ?? '').toString();
    final nombreCompleto = '$nombre $apellido'.trim();
    final identificacion = (estudiante['identificacion'] ?? '').toString();
    final pin = (estudiante['pin'] ?? '0000').toString();
    final avatarUrl = estudiante['avatarUrl']?.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _AppColors.headerBrown.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            _Avatar(nombre: nombre, url: avatarUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreCompleto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ID: $identificacion',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // PIN badge
            _PinBadge(pin: 'K-$pin'),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String nombre;
  const _Avatar({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _AppColors.accentLight,
      ),
      child: Center(
        child: Text(
          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _PinBadge extends StatelessWidget {
  final String pin;
  const _PinBadge({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _AppColors.pinBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'PIN',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'K-$pin',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _AppColors.pinText,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  final String? maestroId;

  const _AddFab({this.maestroId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => InscribirEstudiantePage(
                    maestroId: maestroId,
                  )),
        );
      },
      backgroundColor: _AppColors.accent,
      elevation: 4,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
