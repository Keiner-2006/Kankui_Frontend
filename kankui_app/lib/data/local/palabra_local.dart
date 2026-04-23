import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';

class PalabraLocal {
  final dbService = DatabaseService();
  final uuid = Uuid();

  Future<void> insertarPalabra(String termino, String traduccion) async {
    final db = await dbService.database;

    await db.insert('palabra', {
      'id': uuid.v4(),
      'termino': termino,
      'traduccion': traduccion,
      'sync_status': 'pending'
    });
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