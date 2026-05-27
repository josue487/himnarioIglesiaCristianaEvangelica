import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/himno.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _db;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get db async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbsPath = await getDatabasesPath();
    final path = join(dbsPath, 'dbHimnosEstructuraCompleta.db');

    if (!await databaseExists(path)) {
      await Directory(dbsPath).create(recursive: true);
      final data = await rootBundle.load('assets/dbHimnosEstructuraCompleta.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path);
  }

  Future<Himno> buscarHimno(int idHimno) async {
    final database = await db;
    final results = await database.rawQuery(
      'SELECT * FROM Himnos WHERE id = ?',
      [idHimno],
    );
    if (results.isEmpty) return const Himno();
    return Himno.fromMap(results.first);
  }

  Future<List<Himno>> buscarPorTexto(String query) async {
    if (query.trim().isEmpty) return [];
    final database = await db;
    final exactId = int.tryParse(query.trim());
    final results = await database.rawQuery(
      '''SELECT * FROM Himnos
         WHERE titulo LIKE ? OR id = ?
         ORDER BY CASE WHEN id = ? THEN 0 ELSE 1 END, id
         LIMIT 50''',
      ['%${query.trim()}%', exactId ?? -1, exactId ?? -1],
    );
    return results.map(Himno.fromMap).toList();
  }

  Future<List<Himno>> buscarFavoritos() async {
    final database = await db;
    final results = await database.rawQuery(
      'SELECT * FROM Himnos WHERE favorito = 1 ORDER BY id',
    );
    return results.map(Himno.fromMap).toList();
  }

  Future<bool> cambiarEstadoFavorito(int idHimno) async {
    final database = await db;
    final results = await database.rawQuery(
      'SELECT favorito FROM Himnos WHERE id = ?',
      [idHimno],
    );
    if (results.isEmpty) return false;
    final actual = (results.first['favorito'] as int? ?? 0) == 1;
    final nuevo = !actual;
    await database.rawUpdate(
      'UPDATE Himnos SET favorito = ? WHERE id = ?',
      [nuevo ? 1 : 0, idHimno],
    );
    return nuevo;
  }
}
