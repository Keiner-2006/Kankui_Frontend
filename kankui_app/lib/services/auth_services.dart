import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> login(String correo, String password) async {
    final response = await supabase
        .from('usuario')
        .select()
        .eq('correo', correo)
        .eq('password', password)
        .maybeSingle();

    return response;
  }
}