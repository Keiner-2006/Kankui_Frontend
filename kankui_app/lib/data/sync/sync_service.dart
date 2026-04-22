import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/content_repository.dart';
import '../local/user_repository.dart';
import '../local/progress_repository.dart';
import '../seed/vocablos_data.dart';
import '../local/models_local.dart';

class SyncService {
  final SupabaseClient _supabase;
  final ContentRepository _contentRepo = ContentRepository();
  final UserRepository _userRepo = UserRepository();
  final ProgressRepository _progressRepo = ProgressRepository();

  SyncService(this._supabase);

  Future<void> syncApp() async {
    print('🔄 Iniciando sync híbrido...');

    // 1. Verificar si hay datos locales
    final hasLocal = await _contentRepo.hasLocalContent();

    if (!hasLocal) {
      print('📦 No hay datos → cargando seed...');
      await _seedLocalData();
    }

    // 2. Intentar conexión
    final online = await hasConnection();

    if (online) {
      print('🌐 Online → sincronizando con Supabase...');
      await syncAllContent(force: true);
      await syncProgressToSupabase();
    } else {
      print('📴 Offline → usando datos locales');
    }

    print('✅ Sync completado');
  }

  // ============================================
  // 🌱 SEED LOCAL (OFFLINE)
  // ============================================

  Future<void> _seedLocalData() async {
    // Categorías
    final categorias = VocablosData.categorias.map((c) {
      return CategoriaLocal(
        id: c.id,
        nombre: c.nombre,
        icono: c.icono,
        totalPalabras: 0,
        orden: c.orden,
      );
    }).toList();

    await _contentRepo.saveCategorias(categorias);

    // Palabras
    final palabras = VocablosData.vocablos.map((v) {
      return PalabraLocal(
        id: v.id,
        termino: v.palabra,
        pronunciacion: v.fonetica,
        traduccion: v.significado,
        audioUrl: v.audioPath,
        categoriaId: v.categoria,
      );
    }).toList();

    await _contentRepo.savePalabras(palabras);

    print('✅ Seed cargado correctamente');
  }

  // ============================================
  // 🌐 SYNC CONTENIDO (ONLINE)
  // ============================================

  Future<void> syncAllContent({bool force = false}) async {
    await syncCategorias(force: force);
    await syncPalabras(force: force);
    await syncLecciones(force: force);
    await syncPreguntas(force: force);
    await syncRetos(force: force);
  }

  Future<void> syncCategorias({bool force = false}) async {
    if (!force && !await _contentRepo.needsSync('categoria')) return;

    final response = await _supabase
        .from('categoria')
        .select()
        .order('orden');

    final categorias = (response as List)
        .map((e) => CategoriaLocal.fromSupabase(e))
        .toList();

    await _contentRepo.saveCategorias(categorias);
    await _contentRepo.updateSyncMetadata('categoria');
  }

  Future<void> syncPalabras({bool force = false}) async {
    if (!force && !await _contentRepo.needsSync('palabra')) return;

    final response = await _supabase.from('palabra').select();

    final palabras = (response as List)
        .map((e) => PalabraLocal.fromSupabase(e))
        .toList();

    await _contentRepo.savePalabras(palabras);
    await _contentRepo.updateSyncMetadata('palabra');
  }

  Future<void> syncLecciones({bool force = false}) async {
    if (!force && !await _contentRepo.needsSync('leccion')) return;

    final response = await _supabase
        .from('leccion')
        .select()
        .order('orden');

    final lecciones = (response as List)
        .map((e) => LeccionLocal.fromSupabase(e))
        .toList();

    await _contentRepo.saveLecciones(lecciones);
    await _contentRepo.updateSyncMetadata('leccion');
  }

  Future<void> syncPreguntas({bool force = false}) async {
    if (!force && !await _contentRepo.needsSync('pregunta')) return;

    final response = await _supabase.from('pregunta').select();

    final preguntas = (response as List)
        .map((e) => PreguntaLocal.fromSupabase(e))
        .toList();

    await _contentRepo.savePreguntas(preguntas);
    await _contentRepo.updateSyncMetadata('pregunta');
  }

  Future<void> syncRetos({bool force = false}) async {
    if (!force && !await _contentRepo.needsSync('reto')) return;

    final response = await _supabase
        .from('reto')
        .select()
        .order('orden');

    final retos = (response as List)
        .map((e) => RetoLocal.fromSupabase(e))
        .toList();

    await _contentRepo.saveRetos(retos);
    await _contentRepo.updateSyncMetadata('reto');
  }

  // ============================================
  // 📤 SYNC PROGRESO (LOCAL → SUPABASE)
  // ============================================

  Future<void> syncProgressToSupabase() async {
    await _syncProgresoCategoria();
    await _syncProgresoReto();
    await _syncResultados();
  }

  Future<void> _syncProgresoCategoria() async {
    final unsynced = await _progressRepo.getUnsyncedProgresoCategoria();

    for (var p in unsynced) {
      try {
        await _supabase.from('progreso_categoria').upsert(p.toSupabase());
        await _progressRepo.markProgresoCategoriaAsSynced(p.id);
      } catch (_) {}
    }
  }

  Future<void> _syncProgresoReto() async {
    final unsynced = await _progressRepo.getUnsyncedProgresoReto();

    for (var p in unsynced) {
      try {
        await _supabase.from('progreso_reto').upsert(p.toSupabase());
        await _progressRepo.markProgresoRetoAsSynced(p.id);
      } catch (_) {}
    }
  }

  Future<void> _syncResultados() async {
    final unsynced = await _progressRepo.getUnsyncedResultados();

    for (var r in unsynced) {
      try {
        await _supabase.from('resultado_quiz').upsert(r.toSupabase());
        await _progressRepo.markResultadoAsSynced(r.id);
      } catch (_) {}
    }
  }

  // ============================================
  // 🔌 UTILIDADES
  // ============================================

  Future<bool> hasConnection() async {
    try {
      await _supabase.from('categoria').select('id').limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }
}