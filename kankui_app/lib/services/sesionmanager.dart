import 'package:kankui_app/data/user_progress.dart';
import 'package:kankui_app/models/usuario_model.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  UsuarioModel? _usuarioActual;
  UserProgress _progreso = const UserProgress();

  UsuarioModel? get usuario => _usuarioActual;
  UserProgress get progreso => _progreso;

  bool get estaLogueado => _usuarioActual != null;

  void loginEstudiante(UsuarioModel usuario) {
    _usuarioActual = usuario;

    // 🔥 sincroniza progreso desde el usuario
    _progreso = UserProgress(
      xpTotal: usuario.xpTotal,
      xpHoy: usuario.xpHoy,
      rachaDias: usuario.rachaDias,
      leccionesCompletadas: usuario.leccionesCompletadas,
      escaneoExitosos: usuario.escaneosExitosos,
      logrosDesbloqueados: usuario.logros,
    );
  }

  void actualizarProgreso(UserProgress nuevo) {
    _progreso = nuevo;
  }

  void logout() {
    _usuarioActual = null;
    _progreso = const UserProgress();
  }
  void syncFromUsuario(UsuarioModel usuario) {
  _usuarioActual = usuario;

  _progreso = UserProgress(
    xpTotal: usuario.xpTotal,
    xpHoy: usuario.xpHoy,
    rachaDias: usuario.rachaDias,
    leccionesCompletadas: usuario.leccionesCompletadas,
    escaneoExitosos: usuario.escaneosExitosos,
    logrosDesbloqueados: usuario.logros,
  );
}
}