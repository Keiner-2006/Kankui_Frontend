import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';

class PalabraLocal {
  final dbService = DatabaseService();
  final uuid = Uuid();

Future<List<Map<String, dynamic>>> obtenerTodas() async {
  final db = await dbService.database;

  return await db.query('palabra');
}
  Future<void> insertarPalabra(
  String termino,
  String traduccion,
  String categoriaId,
) async {
  final db = await dbService.database;

  await db.insert('palabra', {
    'id': uuid.v4(),
    'termino': termino,
    'traduccion': traduccion,
    'categoria_id': categoriaId,
    'sync_status': 'pending'
  });
}
Future<List<Map<String, dynamic>>> obtenerPorCategoria(String categoriaId) async {
  final db = await dbService.database;

  return await db.query(
    'palabra',
    where: 'categoria_id = ?',
    whereArgs: [categoriaId],
  );
}


  Future<List<Map<String, dynamic>>> obtenerPendientes() async {
    final db = await dbService.database;

    return await db.query(
      'palabra',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }

  Future<void> marcarSincronizado(String id) async {
    final db = await dbService.database;

    await db.update(
      'palabra',
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}