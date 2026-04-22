import 'package:flutter/material.dart';
import 'package:kankui_app/screens/inscribirestudiante_screen.dart';

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
  final String? avatarUrl;

  const Estudiante({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.pin,
    this.avatarUrl,
  });

  String get nombreCompleto => '$nombre $apellido';
  String get pinFormateado => 'K-$pin';
}

// ============================================================
// DATOS DE EJEMPLO (reemplazar con llamadas a API/BLoC/Provider)
// ============================================================

final _profesorEjemplo = const Profesor(
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

class AdminPanelPage extends StatefulWidget {
  /// Único dato requerido desde el exterior: el profesor autenticado.
  /// Flujo esperado: Login → envía Profesor → AdminPanel carga estudiantes.
  final Profesor profesor;

  /// Callback al pulsar "+" para agregar un estudiante.
  final VoidCallback? onAgregarEstudiante;

  /// Callback al pulsar "Exportar".
  final VoidCallback? onExportar;

  const AdminPanelPage({
    super.key,
    required this.profesor,
    this.onAgregarEstudiante,
    this.onExportar,
  });

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  // ── Estado interno ───────────────────────────────────────────
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
    // Reinicia estado antes de cada carga (útil en pull-to-refresh)
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // ── [API REAL] Sustituye estas líneas por tu llamada real ──
      await Future.delayed(const Duration(milliseconds: 900)); // simula latencia

      final datos = [
        const Estudiante(id: '1045231789', nombre: 'Juan',   apellido: 'Kakuamo',   pin: '4281'),
        const Estudiante(id: '1043567821', nombre: 'María',  apellido: 'Izquierdo', pin: '3947'),
        const Estudiante(id: '1044890234', nombre: 'Carlos', apellido: 'Ríos',      pin: '5612'),
        const Estudiante(id: '1042341567', nombre: 'Ana',    apellido: 'Torres',    pin: '2834'),
        const Estudiante(id: '1045678923', nombre: 'Luis',   apellido: 'Villafaña', pin: '7195'),
      ];
      // ── [FIN BLOQUE MOCK] ──────────────────────────────────────

      if (!mounted) return; // evita setState si el widget fue desmontado
      setState(() {
        _todosLosEstudiantes = datos;
        _estudiantesFiltrados = datos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los estudiantes.\nIntenta de nuevo.';
        _cargando = false;
      });
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
      body: RefreshIndicator(
        // Pull-to-refresh llama a _cargarEstudiantes() de nuevo
        onRefresh: _cargarEstudiantes,
        color: _AppColors.accent,
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            _Header(
              institucion: widget.profesor.institucion, // <-- viene del Profesor
            ),

            // ── BARRA DE BÚSQUEDA ───────────────────────────────
            _SearchBar(controller: _searchController),

            // ── CONTADOR + BOTÓN EXPORTAR ───────────────────────
            _ListHeader(
              cantidad: _estudiantesFiltrados.length,
              onExportar: widget.onExportar,
            ),

            // ── CUERPO: cargando / error / lista ────────────────
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),

      // ── FAB AGREGAR ─────────────────────────────────────────
      floatingActionButton: _AddFab(onPressed: widget.onAgregarEstudiante),
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
                color: Colors.white.withOpacity(0.15),
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
              color: _AppColors.headerBrown.withOpacity(0.06),
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
              color: _AppColors.headerBrown.withOpacity(0.06),
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
                    'ID: ${estudiante.id}',
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
        color: _AppColors.accentLight.withOpacity(0.25),
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

  const _AddFab({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {
        // Navegar directamente a la página de agregar estudiante
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InscribirEstudiantePage()),
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
      home: AdminPanelPage(
        profesor: _profesorEjemplo,       // ← inyectar desde auth/state
        // 'estudiantes' ya NO existe: AdminPanel los carga internamente
        onAgregarEstudiante: () {
          // TODO: Navigator.push(...) a formulario de nuevo estudiante
        },
        onExportar: () {
          // TODO: generar CSV / PDF y compartir
        },
      ),
    );
  }
}