import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<void> insertarPalabra(Map<String, dynamic> palabra) async {
    await supabase.from('palabra').insert({
      'id': palabra['id'],
      'termino': palabra['termino'],
      'traduccion': palabra['traduccion'],
      'audio_url': palabra['audio_url'],
      'categoria_id': palabra['categoria_id'],
    });
  }
}