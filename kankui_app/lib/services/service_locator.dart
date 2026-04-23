import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/local/palabra_local.dart';
import '../data/remote/supabase_service.dart';
import '../data/sync/sync_service.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/estudiante_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<PalabraLocal>(() => PalabraLocal());
  locator.registerLazySingleton<SupabaseService>(() => SupabaseService());
  locator.registerLazySingleton<SyncService>(() => SyncService());
  locator.registerLazySingleton<UsuarioRepository>(() => UsuarioRepository(Supabase.instance.client));
  locator.registerLazySingleton<EstudianteRepository>(() => EstudianteRepository(Supabase.instance.client));
}
