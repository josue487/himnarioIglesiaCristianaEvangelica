import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/himno.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _db;

  // Increment this every time the DB asset changes (new choruses, fixed references, etc).
  static const _dbVersion = 2;
  static const _dbVersionKey = 'db_version';

  // Favorites are stored here instead of in the DB so they survive reinstalls/updates.
  static const _favKey = 'user_favoritos';

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get db async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbsPath = await getDatabasesPath();
    final path = join(dbsPath, 'dbHimnosEstructuraCompleta.db');
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_dbVersionKey) ?? 0;

    if (!await databaseExists(path) || storedVersion < _dbVersion) {
      await Directory(dbsPath).create(recursive: true);
      final data = await rootBundle.load('assets/dbHimnosEstructuraCompleta.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      await prefs.setInt(_dbVersionKey, _dbVersion);
    }

    final database = await openDatabase(path);
    await _migrateFavoritosIfNeeded(database);
    return database;
  }

  // One-time migration: reads the DB's favorito column and saves IDs to SharedPreferences.
  // After this runs once the DB column is no longer used.
  Future<void> _migrateFavoritosIfNeeded(Database database) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_favKey)) return;
    final results = await database.rawQuery(
      'SELECT id FROM Himnos WHERE favorito = 1',
    );
    final ids = results.map((r) => (r['id'] as int).toString()).toList();
    await prefs.setStringList(_favKey, ids);
  }

  Future<Set<int>> _loadFavIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favKey) ?? []).map(int.parse).toSet();
  }

  Future<void> _saveFavIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, ids.map((id) => '$id').toList());
  }

  Future<Himno> buscarHimno(int idHimno) async {
    final database = await db;
    final results = await database.rawQuery(
      'SELECT * FROM Himnos WHERE id = ?',
      [idHimno],
    );
    if (results.isEmpty) return const Himno();
    final favIds = await _loadFavIds();
    final map = Map<String, dynamic>.from(results.first);
    map['favorito'] = favIds.contains(idHimno) ? 1 : 0;
    return Himno.fromMap(map);
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
    final favIds = await _loadFavIds();
    return results.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['favorito'] = favIds.contains(row['id'] as int) ? 1 : 0;
      return Himno.fromMap(map);
    }).toList();
  }

  Future<List<Himno>> buscarFavoritos() async {
    final favIds = await _loadFavIds();
    if (favIds.isEmpty) return [];
    final database = await db;
    final placeholders = List.filled(favIds.length, '?').join(',');
    final results = await database.rawQuery(
      'SELECT * FROM Himnos WHERE id IN ($placeholders) ORDER BY id',
      favIds.toList(),
    );
    return results.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['favorito'] = 1;
      return Himno.fromMap(map);
    }).toList();
  }

  Future<bool> cambiarEstadoFavorito(int idHimno) async {
    await db; // ensures migration runs before first toggle
    final ids = await _loadFavIds();
    final wasFavorite = ids.contains(idHimno);
    if (wasFavorite) {
      ids.remove(idHimno);
    } else {
      ids.add(idHimno);
    }
    await _saveFavIds(ids);
    return !wasFavorite;
  }
}
