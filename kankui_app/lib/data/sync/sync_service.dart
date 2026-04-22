import '../local/palabra_local.dart';
import '../remote/supabase_service.dart';

class SyncService {
  final local = PalabraLocal();
  final remote = SupabaseService();

  Future<void> sincronizarPalabras() async {
    final pendientes = await local.obtenerPendientes();

    for (var palabra in pendientes) {
      try {
        await remote.insertarPalabra(palabra);

        await local.marcarSincronizado(palabra['id']);
      } catch (e) {
        print('Error sincronizando: $e');
      }
    }
  }
}