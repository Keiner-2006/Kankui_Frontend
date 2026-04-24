import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/local/palabra_local.dart';
import '../data/local/analytics_local_db.dart';
import '../data/remote/supabase_service.dart';
import '../data/sync/sync_service.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/estudiante_repository.dart';
import '../repositories/maestro_repository.dart';
import '../repositories/categoria_repository.dart';
import '../repositories/analytics_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Servicios de datos locales
  locator.registerLazySingleton<PalabraLocal>(() => PalabraLocal());
  locator.registerLazySingleton<AnalyticsLocalDB>(() => AnalyticsLocalDB());

  // Servicios remotos
  locator.registerLazySingleton<SupabaseService>(() => SupabaseService());

  // Sync service (requiere cliente Supabase)
  locator.registerLazySingleton<SyncService>(
    () => SyncService(Supabase.instance.client),
  );

  // Repositorios
  locator.registerLazySingleton<UsuarioRepository>(
      () => UsuarioRepository(Supabase.instance.client));
  locator.registerLazySingleton<EstudianteRepository>(
      () => EstudianteRepository(Supabase.instance.client));
  locator.registerLazySingleton<MaestroRepository>(
      () => MaestroRepository(Supabase.instance.client));
  locator.registerLazySingleton<CategoriaRepository>(
      () => CategoriaRepository(Supabase.instance.client));

  // Analytics Repository (nuevo)
  locator.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepository(
      Supabase.instance.client,
      locator<AnalyticsLocalDB>(),
    ),
  );
}
