import 'package:get_it/get_it.dart';
import '../data/local/palabra_local.dart';
import '../data/remote/supabase_service.dart';
import '../data/sync/sync_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<PalabraLocal>(() => PalabraLocal());
  locator.registerLazySingleton<SupabaseService>(() => SupabaseService());
  locator.registerLazySingleton<SyncService>(() => SyncService());
}
