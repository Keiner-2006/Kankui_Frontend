import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'kankui.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    // 📚 PALABRAS
    await db.execute('''
      CREATE TABLE palabra(
        id TEXT PRIMARY KEY,
        termino TEXT,
        pronunciacion TEXT,
        traduccion TEXT,
        audio_url TEXT,
        categoria_id TEXT,
        sync_status TEXT DEFAULT 'pending'
      )
      ''');

    // 📊 PROGRESO
    await db.execute('''
      CREATE TABLE progreso_categoria (
        id TEXT PRIMARY KEY,
        usuario_id TEXT,
        categoria_id TEXT,
        lecciones_completadas INTEGER,
        total_lecciones INTEGER,
        ultima_actividad TEXT,
        sincronizado INTEGER
      )
    ''');
  }
}