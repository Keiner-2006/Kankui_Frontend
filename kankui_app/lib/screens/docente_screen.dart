import 'package:flutter/material.dart';
import 'package:kankui_app/repositories/estudiante_repository.dart';
import 'package:kankui_app/screens/inscribirestudiante_screen.dart';
import 'package:kankui_app/services/service_locator.dart';
import 'package:kankui_app/data/remote/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'recursos_qr_screen.dart';

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
// DATOS DE EJEMPLO (reemplazar con llamadas a API/BLoC/Provider)
// ============================================================

const _profesorEjemplo = Profesor(
  nombre: 'Laura',
  apellido: 'Martínez',
  correo: 'laura@iedemo.edu.co',
  institucion: 'I.E. Indígena Atánquez',
);

// Los datos mock se encuentran ahora dentro de _cargarEstudiantes()
// en el State de AdminPanelPage. No se necesita lista global.

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
  static const divider = Color(0xFFF0E8DF);
}

// ============================================================
// PANTALLA PRINCIPAL: Panel de Administración
// ============================================================

class DocenteScreen extends StatefulWidget {
  final Profesor profesor;
  final VoidCallback? onAgregarEstudiante;
  final VoidCallback? onExportar;
  final String? maestroId;

  const DocenteScreen({
    super.key,
    required this.profesor,
    this.onAgregarEstudiante,
    this.onExportar,
    this.maestroId,
  });

  @override
  State<DocenteScreen> createState() => _DocenteScreenState();
}

class _DocenteScreenState extends State<DocenteScreen> {
  int _currentIndex = 0;
  
  /// Lista maestra cargada desde la "API" (o mock).
  List<Estudiante> _todosLosEstudiantes = [];

  /// Lista derivada que se muestra según el filtro de búsqueda.
  List<Estudiante> _estudiantesFiltrados = [];

  /// Indica si la carga inicial está en progreso.
  bool _cargando = true;

  /// Mensaje de error en caso de fallo de red/API (null = sin error).
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  // ── Ciclo de vida ────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrar);
    _cargarEstudiantes(); // carga al entrar a la pantalla
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Carga de datos ───────────────────────────────────────────

  /// Carga la lista de estudiantes asociados al profesor.
  ///
  /// AHORA usa datos mock con un retardo simulado.
  ///
  /// PARA CONECTAR A UNA API REAL, reemplaza el bloque marcado con
  /// `// [API REAL]` por tu llamada HTTP/repositorio, por ejemplo:
  ///
  /// ```dart
  /// final response = await estudianteRepository.fetchPorProfesor(
  ///   profesorId: widget.profesor.id,
  /// );
  /// ```
  Future<void> _cargarEstudiantes() async {
    print('🚀 Iniciando carga de estudiantes...');

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final repo = EstudianteRepository(Supabase.instance.client);

      print('📡 Llamando a Supabase...');
      final data = await repo.obtenerTodos();

      print('📦 Datos crudos recibidos: $data');
      print('📊 Cantidad: ${data.length}');

      final datos = data.map((e) {
        print('👤 Procesando estudiante: ${e.toJson()}');

        return Estudiante(
          id: e.id,
          nombre: e.nombre ?? 'Sin nombre',
          apellido: e.apellido ?? '',
          pin: e.pin ?? '0000',
          identificacion: e.identificacion,
        );
      }).toList();

      print('✅ Datos mapeados: $datos');

      if (!mounted) return;

      setState(() {
        _todosLosEstudiantes = datos;
        _estudiantesFiltrados = datos;
        _cargando = false;
      });

      print('🎉 UI actualizada correctamente');
    } catch (e, stack) {
      print('❌ ERROR COMPLETO: $e');
      print('📍 STACKTRACE: $stack');

      if (!mounted) return;

      setState(() {
        _error = 'Error cargando estudiantes: $e';
        _cargando = false;
      });
    }
  }

  // ── Agregar estudiante ────────────────────────────────────────

  /// Agrega un nuevo estudiante usando Supabase.
  Future<void> _agregarEstudiante(
      String nombre, String apellido, String pin) async {
    const uuid = Uuid();
    final nuevoUsuario = {
      'id': uuid.v4(),
      'nombre': '$nombre $apellido',
      'identificacion':
            pin, // usa pin como identificación temporal (ahora es String)
    };

    try {
      await locator<SupabaseService>().insertarUsuario(nuevoUsuario);
      // Recargar lista después de agregar
      await _cargarEstudiantes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante agregado exitosamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar estudiante: $e')),
      );
    }
  }

  // ── Búsqueda ─────────────────────────────────────────────────

  /// Filtra sobre la lista maestra (_todosLosEstudiantes), no sobre la API.
  void _filtrar() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _estudiantesFiltrados = _todosLosEstudiantes.where((e) {
        return e.nombreCompleto.toLowerCase().contains(query) ||
            e.id.contains(query);
      }).toList();
    });
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: _currentIndex == 0 
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
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: _AppColors.accent,
          unselectedItemColor: _AppColors.textSecondary,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
      // ── FAB AGREGAR (Solo visible en Estudiantes) ─────────────
      floatingActionButton: _currentIndex == 0 
          ? _AddFab(
              onPressed: widget.onAgregarEstudiante,
              maestroId: widget.maestroId,
            )
          : null,
    );
  }

  Widget _buildEstudiantesTab() {
    return RefreshIndicator(
      onRefresh: _cargarEstudiantes,
      color: _AppColors.accent,
      child: Column(
        children: [
          _Header(institucion: widget.profesor.institucion),
          _SearchBar(controller: _searchController),
          _ListHeader(
            cantidad: _estudiantesFiltrados.length,
            onExportar: widget.onExportar,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// Decide qué mostrar según el estado de carga.
  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: _AppColors.accent),
      );
    }

    if (_error != null) {
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
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarEstudiantes,
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

    return _EstudiantesList(estudiantes: _estudiantesFiltrados);
  }
}

// ============================================================
// WIDGET: Header marrón con el nombre de la IE
// ============================================================

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
                  institucion, // ← viene del atributo del profesor
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
          // Botón de configuración / menú
          // TODO: conectar a pantalla de ajustes
          GestureDetector(
            onTap: () {
              // TODO: navegar a Settings
            },
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

// ============================================================
// WIDGET: Barra de búsqueda
// ============================================================

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

// ============================================================
// WIDGET: Fila con contador de estudiantes y botón Exportar
// ============================================================

class _ListHeader extends StatelessWidget {
  final int cantidad;
  final VoidCallback? onExportar;

  const _ListHeader({required this.cantidad, this.onExportar});

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
          GestureDetector(
            onTap: onExportar,
            child: const Text(
              'Exportar',
              style: TextStyle(
                fontSize: 13,
                color: _AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Lista de tarjetas de estudiantes
// ============================================================

class _EstudiantesList extends StatelessWidget {
  final List<Estudiante> estudiantes;

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
          // TODO: conectar con navegación al perfil del estudiante
          onTap: () {},
        );
      },
    );
  }
}

// ============================================================
// WIDGET: Tarjeta individual de estudiante
// ============================================================

class _EstudianteCard extends StatelessWidget {
  final Estudiante estudiante;
  final VoidCallback? onTap;

  const _EstudianteCard({required this.estudiante, this.onTap});

  @override
  Widget build(BuildContext context) {
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
            _Avatar(nombre: estudiante.nombre, url: estudiante.avatarUrl),
            const SizedBox(width: 14),

            // Nombre + ID
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estudiante.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ID: ${estudiante.identificacion}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // PIN badge
            _PinBadge(pin: estudiante.pinFormateado),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Avatar circular con inicial o imagen
// ============================================================

class _Avatar extends StatelessWidget {
  final String nombre;
  final String? url;

  const _Avatar({required this.nombre, this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _AppColors.accentLight.withValues(alpha: 0.25),
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: url == null
          ? Center(
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _AppColors.accent,
                ),
              ),
            )
          : null,
    );
  }
}

// ============================================================
// WIDGET: Badge de PIN
// ============================================================

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
            pin,
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

// ============================================================
// WIDGET: Botón flotante "+"
// ============================================================

class _AddFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? maestroId;

  const _AddFab({this.onPressed, this.maestroId});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ??
          () {
            // Navegar directamente a la página de agregar estudiante
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

// ============================================================
// PUNTO DE ENTRADA DE EJEMPLO
// Reemplaza con tu propio MaterialApp / navegación
// ============================================================

void main() {
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin IE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _AppColors.accent),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: DocenteScreen(
        profesor: _profesorEjemplo, 
        onAgregarEstudiante: () {},
        onExportar: () {},
      ),
    );
  }
}
