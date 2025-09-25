// lib/utils/persistence_test_helper.dart
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PersistenceTestHelper {
  PersistenceTestHelper._privateConstructor();
  static final PersistenceTestHelper instance =
      PersistenceTestHelper._privateConstructor();

  static const _dbFileName = 'alammobile.db';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Database? _db;

  Future<String> _dbPath() async {
    // menggunakan getDatabasesPath() agar konsisten dengan sqflite default
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _dbFileName);
  }

  Future<Database> initDatabase() async {
    final path = await _dbPath();
    // pastikan folder ada
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    _db ??= await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // buat tabel test sederhana (tidak mengganggu tabel asli)
        await db.execute(
            'CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
      },
      onOpen: (db) {
        // nothing
      },
    );
    return _db!;
  }

  Future<bool> dbExistsOnDisk() async {
    final path = await _dbPath();
    return File(path).existsSync();
  }

  Future<int> ensureTestRow() async {
    final db = await initDatabase();
    await db.execute(
        'CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
    final rows = await db.query('test');
    if (rows.isEmpty) {
      await db.insert('test', {'name': 'first-run'});
    }
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM test')) ??
            0;
    return count;
  }

  Future<int> countTestRows() async {
    final db = await initDatabase();
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM test')) ??
            0;
    return count;
  }

  Future<void> deleteDatabaseFile() async {
    final path = await _dbPath();
    try {
      await closeDb();
      final f = File(path);
      if (f.existsSync()) {
        await f.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> closeDb() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  // Secure storage helpers (simulate token persistence)
  Future<void> writeToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> readToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // helper untuk debug path
  Future<String> debugPath() async => await _dbPath();
}
