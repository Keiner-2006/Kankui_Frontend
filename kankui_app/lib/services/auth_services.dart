import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ✅ LOGIN con Supabase Auth (seguro)
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Error en login: $e');
      rethrow;
    }
  }

  // ✅ REGISTRO de nuevo usuario
  Future<AuthResponse> register(String email, String password, Map<String, dynamic> userData) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userData, // metadata del usuario (nombre, rol, etc.)
      );
      return response;
    } catch (e) {
      print('Error en registro: $e');
      rethrow;
    }
  }

  // ✅ CERRAR SESIÓN
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ✅ OBTENER USUARIO ACTUAL
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // ✅ VERIFICAR SI ESTÁ AUTENTICADO
  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  // ✅ OBTENER ID DEL USUARIO ACTUAL
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  // ✅ STREAM de cambios en autenticación
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}