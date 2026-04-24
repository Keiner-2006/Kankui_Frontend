import 'package:kankui_app/models/usuario_model.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  UsuarioModel? _usuarioActual;

  UsuarioModel? get usuario => _usuarioActual;

  bool get estaLogueado => _usuarioActual != null;

  void loginEstudiante(UsuarioModel usuario) {
    _usuarioActual = usuario;
  }

  void logout() {
    _usuarioActual = null;
  }
}