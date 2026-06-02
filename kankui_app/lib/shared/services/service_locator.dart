import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kankui_app/shared/data/local/palabra_local.dart';
import 'package:kankui_app/shared/data/remote/supabase_service.dart';
import 'package:kankui_app/shared/data/sync/sync_service.dart';
import 'package:kankui_app/features/auth/data/repositories/usuario_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/estudiante_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/maestro_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/grupo_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/reto_grupo_repository.dart';
import 'package:kankui_app/features/docente/data/repositories/progreso_grupo_repository.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<PalabraLocal>(() => PalabraLocal());
  locator.registerLazySingleton<SupabaseService>(() => SupabaseService());

  // Versión de Alejandro (requiere cliente)
  locator.registerLazySingleton<SyncService>(
    () => SyncService(Supabase.instance.client),
  );

  // Repositorios de Keiner
  locator.registerLazySingleton<UsuarioRepository>(
      () => UsuarioRepository(Supabase.instance.client));
  locator.registerLazySingleton<EstudianteRepository>(
      () => EstudianteRepository(Supabase.instance.client));
  locator.registerLazySingleton<MaestroRepository>(
      () => MaestroRepository(Supabase.instance.client));
  locator.registerLazySingleton<CategoriaRepository>(
      () => CategoriaRepository(Supabase.instance.client));
  locator.registerLazySingleton<GrupoRepository>(
      () => GrupoRepository(Supabase.instance.client));
  locator.registerLazySingleton<RetoGrupoRepository>(
      () => RetoGrupoRepository(Supabase.instance.client));
  locator.registerLazySingleton<ProgresoGrupoRepository>(
      () => ProgresoGrupoRepository(Supabase.instance.client));
}
