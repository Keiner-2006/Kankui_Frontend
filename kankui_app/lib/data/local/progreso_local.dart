import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../../models/progreso.dart';

class ProgresoLocal {
  final DatabaseService _dbService = DatabaseService();

  Future<void> guardarProgreso(Progreso progreso) async {
    final db = await _dbService.database;

    await db.insert(
      'progreso_categoria',
      progreso.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Progreso>> obtenerProgreso() async {
    final db = await _dbService.database;

    final maps = await db.query('progreso_categoria');

    return maps.map((e) => Progreso.fromMap(e)).toList();
  }
}