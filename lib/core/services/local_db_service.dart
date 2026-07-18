import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

/// SQLite-based local database service.
/// Caches dropdown options, visual styles, and app metadata
/// so the app works instantly offline without hitting the server repeatedly.
class LocalDbService {
  LocalDbService._();
  static final LocalDbService instance = LocalDbService._();

  Database? _db;

  static const int _dbVersion = 1;
  static const String _dbName = 'poster_studio_cache.db';

  // ─── Table & column names ───────────────────────────────────────
  static const String _tableDropdown = 'dropdown_cache';
  static const String _tableVisualStyle = 'visual_style_cache';
  static const String _tableMeta = 'app_meta';

  // ─── Init ────────────────────────────────────────────────────────
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return databaseFactory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Dropdown options cache
    await db.execute('''
      CREATE TABLE $_tableDropdown (
        id TEXT PRIMARY KEY,
        groupKey TEXT NOT NULL,
        label TEXT NOT NULL,
        value TEXT NOT NULL,
        helperText TEXT,
        icon TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        sortOrder INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Visual styles cache
    await db.execute('''
      CREATE TABLE $_tableVisualStyle (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        promptTemplate TEXT NOT NULL,
        previewImageUrl TEXT,
        localImagePath TEXT,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // App meta (checksum, last sync time, etc.)
    await db.execute('''
      CREATE TABLE $_tableMeta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ─── Dropdown Options ─────────────────────────────────────────────

  Future<void> saveDropdownOptions(List<Map<String, dynamic>> options) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing
    batch.delete(_tableDropdown);

    // Insert all
    for (final opt in options) {
      batch.insert(_tableDropdown, {
        'id': opt['id'] ?? '',
        'groupKey': opt['groupKey'] ?? '',
        'label': opt['label'] ?? '',
        'value': opt['value'] ?? '',
        'helperText': opt['helperText'],
        'icon': opt['icon'],
        'isActive': (opt['isActive'] == true || opt['isActive'] == 1) ? 1 : 0,
        'sortOrder': opt['sortOrder'] ?? 0,
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getDropdownOptions() async {
    final db = await database;
    return db.query(
      _tableDropdown,
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'sortOrder ASC',
    );
  }

  // ─── Visual Styles ────────────────────────────────────────────────

  Future<void> saveVisualStyles(List<Map<String, dynamic>> styles) async {
    final db = await database;
    final batch = db.batch();

    batch.delete(_tableVisualStyle);

    for (final style in styles) {
      batch.insert(_tableVisualStyle, {
        'id': style['id'] ?? '',
        'name': style['name'] ?? '',
        'promptTemplate': style['promptTemplate'] ?? '',
        'previewImageUrl': style['previewImageUrl'],
        'localImagePath': style['localImagePath'],
        'isActive': (style['isActive'] == true || style['isActive'] == 1) ? 1 : 0,
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getVisualStyles() async {
    final db = await database;
    return db.query(
      _tableVisualStyle,
      where: 'isActive = ?',
      whereArgs: [1],
    );
  }

  Future<void> updateVisualStyleLocalPath(String id, String localPath) async {
    final db = await database;
    await db.update(
      _tableVisualStyle,
      {'localImagePath': localPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── App Meta (checksum, etc.) ────────────────────────────────────

  Future<void> setMeta(String key, String value) async {
    final db = await database;
    await db.insert(
      _tableMeta,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMeta(String key) async {
    final db = await database;
    final rows = await db.query(_tableMeta, where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> saveChecksum(String checksum) async {
    await setMeta('data_checksum', checksum);
    await setMeta('last_sync_at', DateTime.now().toIso8601String());
  }

  Future<String?> getChecksum() async => getMeta('data_checksum');
  Future<String?> getLastSyncAt() async => getMeta('last_sync_at');

  Future<void> cacheHistoryJson(String jsonStr) async {
    await setMeta('history_cache', jsonStr);
  }

  Future<String?> getCachedHistoryJson() async {
    return getMeta('history_cache');
  }

  Future<void> cacheTemplatesJson(String jsonStr) async {
    await setMeta('templates_cache', jsonStr);
  }

  Future<String?> getCachedTemplatesJson() async {
    return getMeta('templates_cache');
  }

  // ─── Utility ──────────────────────────────────────────────────────

  Future<bool> hasData() async {
    final rows = await getDropdownOptions();
    return rows.isNotEmpty;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_tableDropdown);
    await db.delete(_tableVisualStyle);
    await db.delete(_tableMeta);
  }
}
