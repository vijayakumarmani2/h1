import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create samples table
    await db.execute('''
      CREATE TABLE samples (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sampleName TEXT NOT NULL,
        type TEXT NOT NULL,
        result TEXT NOT NULL
      )
    ''');

    // Create absorbance table
    await db.execute('''
      CREATE TABLE absorbance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sample_id INTEGER NOT NULL,
        time INTEGER NOT NULL,
        absorbance_value TEXT NOT NULL,
        FOREIGN KEY (sample_id) REFERENCES samples (id) ON DELETE CASCADE
      )
    ''');

    // Create logs table
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        page TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL -- 'info', 'error', or 'warning'
      )
    ''');
    print("database created");
  }

  Future<void> deleteLogsTable() async {
    Database db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS logs');
    // Create logs table
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        page TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL -- 'info', 'error', or 'warning'
      )
    ''');
    print('Logs table deleted successfully.');
  }

  // Insert sample
  Future<int> insertSample(Map<String, dynamic> sample) async {
    Database db = await instance.database;
    return await db.insert('samples', sample);
  }

  // Insert absorbance data
  Future<int> insertAbsorbance(Map<String, dynamic> absorbance) async {
    Database db = await instance.database;
    return await db.insert('absorbance', absorbance);
  }

  // Insert log
  Future<int> insertLog(Map<String, dynamic> log) async {
    Database db = await instance.database;
    return await db.insert('logs', log);
  }

  // Fetch all logs
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    Database db = await instance.database;
    return await db.query('logs', orderBy: 'date DESC, time DESC');
  }

  // Fetch logs by type
  Future<List<Map<String, dynamic>>> getLogsByType(String type) async {
    Database db = await instance.database;
    return await db.query('logs',
        where: 'type = ?', whereArgs: [type], orderBy: 'date DESC, time DESC');
  }

  // Fetch logs with filter
  Future<List<Map<String, dynamic>>> getLogsFiltered(
      String keyword, String type) async {
    Database db = await instance.database;
    final whereClause =
        type == "all" ? "message LIKE ?" : "type = ? AND message LIKE ?";
    final whereArgs = type == "all" ? ["%$keyword%"] : [type, "%$keyword%"];
    return await db.query('logs',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date DESC, time DESC');
  }

  // Fetch absorbance data by sample ID
  Future<List<Map<String, dynamic>>> getAbsorbanceBySampleId(
      int sampleId) async {
    Database db = await instance.database;
    return await db
        .query('absorbance', where: 'sample_id = ?', whereArgs: [sampleId]);
  }

  // Fetch all samples
  Future<List<Map<String, dynamic>>> getAllSamples() async {
    Database db = await instance.database;
    return await db.query('samples', orderBy: 'id ASC');
  }

  // Unified logging method
  Future<void> logEvent(String type, String message,
      {String page = 'general'}) async {
    Database db = await instance.database;
    final now = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(now);
    final time = DateFormat('HH:mm:ss').format(now);

    await db.insert('logs', {
      'page': page,
      'message': message,
      'date': date,
      'time': time,
      'type': type,
    });

    // Print log to the console
    print("$type Logged: $message (Date: $date, Time: $time)");
  }
}
