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
    String path = join(await getDatabasesPath(), 'hba1c_database.db');

     // Delete the old database (for development purposes only)
  // await deleteDatabase(path);
   // print("Old database deleted");

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

   // Create calibration_info table
    await db.execute('''
      CREATE TABLE calibration_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        lot_no TEXT NOT NULL,
        k_value REAL NOT NULL,
        b_value REAL NOT NULL
      )
    ''');

    // Create last_calibration_info table
    await db.execute('''
      CREATE TABLE last_calibration_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        lot_no TEXT NOT NULL,
        k_value REAL NOT NULL,
        b_value REAL NOT NULL
      )
    ''');

    // create db_cal table
    await db.execute('''
      CREATE TABLE db_cal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lot_no TEXT NOT NULL,
        low_value REAL NOT NULL,
        high_value REAL NOT NULL,
        low_cal_pos INTEGER NOT NULL,
        high_cal_pos INTEGER NOT NULL
      )
    ''');

 


    // create manual table
    await db.execute('''
      CREATE TABLE manual (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hba1c_k REAL,
        hba1c_b REAL
      )
    ''');

    // result table
   await db.execute('''
  CREATE TABLE result_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sample_no TEXT NOT NULL,
    type TEXT NOT NULL,
    date_time TEXT NOT NULL,
    hbf REAL NOT NULL,
    hba1c REAL NOT NULL,
    remarks TEXT,
    abs_data TEXT -- Column to store JSON
  )
''');

final result_data = {
     'id': 1,
    'sample_no': '1',
    'type': 'HbA1c',
    'date_time': DateTime.now().toIso8601String(),
    'hbf': 0.0,
    'hba1c': 0.0,
    'remarks': 'No remarks',
    'abs_data': '{"data": [{"secs": 5, "absorbance_value": 0.06}, {"secs": 10, "absorbance_value": 0.67}, {"secs": 15, "absorbance_value": 0.73}, {"secs": 20, "absorbance_value": 0.921}, {"secs": 25, "absorbance_value": 0.07}, {"secs": 30, "absorbance_value": 0.3}, {"secs": 35, "absorbance_value": 0.31}, {"secs": 40, "absorbance_value": 0.006}, {"secs": 45, "absorbance_value": 0.19}, {"secs": 50, "absorbance_value": 0.2}, {"secs": 55, "absorbance_value": 0.05}, {"secs": 60, "absorbance_value": 0.06}, {"secs": 65, "absorbance_value": 0.09}, {"secs": 70, "absorbance_value": 0.1}, {"secs": 75, "absorbance_value": 0.456}, {"secs": 80, "absorbance_value": 0.06}, {"secs": 85, "absorbance_value": 1.75}, {"secs": 90, "absorbance_value": 1.34}, {"secs": 95, "absorbance_value": 0.11}, {"secs": 100, "absorbance_value": 0.96}, {"secs": 105, "absorbance_value": 1.12}, {"secs": 110, "absorbance_value": 0.06}, {"secs": 115, "absorbance_value": 0.06}]}',
  };

await db.insert('result_table', result_data);

 // Create qc_target table
  await db.execute('''
    CREATE TABLE qc_target (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      low_target REAL NOT NULL,
      high_target REAL NOT NULL,
      lotnumber REAL NOT NULL,
      modified_date TEXT NOT NULL
    )
  ''');

 final caldata = {
    'lot_no': 'LOT12345',
    'low_value': '0',       // Example low value
    'high_value': '0',      // Example high value
    'low_cal_pos': '1',         // Example low calibration position
    'high_cal_pos': '2',        // Example high calibration position
  };

  await db.insert('db_cal', caldata);

   final qcdata = {
    'low_target': "0.0", // Updated low target value
      'high_target': "0.0", // Updated high target value
      'lotnumber': "LOT12345", // Updated lot number
      'modified_date': DateTime.now().toIso8601String(), // Updated date
  };

  await db.insert('qc_target', qcdata);

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

  // Insert calibration info
    Future<int> insertCalibrationInfo(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('calibration_info', data);
  }
  
  // Insert db_cal
  Future<int> insertDBCal(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('db_cal', data);
  }

// Insert QC Target
Future<int> insertQCTarget(Map<String, dynamic> data) async {
  final db = await instance.database;
  return await db.insert('qc_target', data);
}

Future<void> insertNewQCTarget() async {
  final data = {
    'low_target': 0.0, // Example low target value
    'high_target': 0.0, // Example high target value
    'modified_date': DateTime.now().toIso8601String(), // Current date and time
  };

  final id = await DatabaseHelper.instance.insertQCTarget(data);
  print("Inserted new QC Target record with ID: $id");
}

Future<Map<String, dynamic>?> fetchLatestQCTarget() async {
  final db = await instance.database;
  final result = await db.query(
    'qc_target',
    orderBy: 'id DESC',
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}

Future<int> updateQCTarget( Map<String, dynamic> updatedData) async {
  final db = await instance.database;
  return await db.update(
    'qc_target',
    updatedData,
    where: 'id = 1'
  );
}


Future<void> insertLatestDBCal() async {
  final data = {
    'lot_no': 'LOT12345',
    'low_value': '0',       // Example low value
    'high_value': '0',      // Example high value
    'low_cal_pos': '1',         // Example low calibration position
    'high_cal_pos': '2',        // Example high calibration position
  };

  final id = await DatabaseHelper.instance.insertDBCal(data);
  print("Inserted new record into db_cal with ID: $id");
}

  // Insert manual
  Future<int> insertManual(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('manual', data);
  }


  // Fetch  calibration info
    Future<Map<String, dynamic>?> fetchCalibrationInfo() async {
  final db = await instance.database;
  final result = await db.query(
    'calibration_info',
    orderBy: 'id DESC',
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}

  // Fetch last calibration info
  Future<Map<String, dynamic>?> fetchLastCalibrationInfo() async {
  final db = await instance.database;
  final result = await db.query(
    'last_calibration_info',
    orderBy: 'id DESC',
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}

// Fetch db_cal
Future<Map<String, dynamic>?> fetchLatestDBCal() async {
  final db = await instance.database;
  final result = await db.query(
    'db_cal',
    orderBy: 'id DESC',
    
  );
  return result.isNotEmpty ? result.first : null;
}

// insert manual data
Future<int> insertManualData(Map<String, dynamic> data) async {
  final db = await instance.database;
  return await db.insert('manual', data);
}

// Update manual data
Future<int> updateManualData(int id, Map<String, dynamic> data) async {
  final db = await instance.database;
  return await db.update(
    'manual',
    data,
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Fetch manual data
Future<Map<String, dynamic>?> fetchManualData() async {
  final db = await instance.database;
  final result = await db.query(
    'manual',
    orderBy: 'id DESC',
    limit: 1,
  );
  return result.isNotEmpty ? result.first : null;
}

// Update calibration info
Future<int> updateDBCal(int id, Map<String, dynamic> data) async {
  final db = await instance.database;
  return await db.update(
    'db_cal',
    data,
    where: 'id = ?',
    whereArgs: [id],
  );
}


Future<int> updateDBCalLotNo(int id, String newLotNo) async {
  final db = await instance.database;
  return await db.update(
    'db_cal',
    {'lot_no': newLotNo},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> updateDBCalLowValue(int id, String newLowValue) async {
  final db = await instance.database;
  return await db.update(
    'db_cal',
    {'low_value': newLowValue},
    where: 'id = ?',
    whereArgs: [id],
  );
  print("Inserted new record into db_cal with ID: $id");
}

Future<int> updateDBCalHighValue(int id, String newHighValue) async {
  final db = await instance.database;
  return await db.update(
    'db_cal',
    {'high_value': newHighValue},
    where: 'id = ?',
    whereArgs: [id],
  );
  print("Inserted new record into db_cal with ID: $id");
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

  // Insert result
   Future<int> insertResult(Map<String, dynamic> result) async {
  final db = await instance.database;
  return await db.insert('result_table', result);
}

// Fetch results
Future<List<Map<String, dynamic>>> fetchResults() async {
  final db = await instance.database;
  return await db.query('result_table', orderBy: 'id ASC');
}

// Fetch results by id
Future<List<Map<String, dynamic>>> fetchResultsByID(int id) async {
  final db = await instance.database;
  return await db.query('result_table', where: 'id = ?', whereArgs: [id],);
}

// Update result remarks
Future<int> updateResultRemarks(int id, Map<String, dynamic> updatedResult) async {
  final db = await instance.database;
  return await db.update(
    'result_table',
    updatedResult,
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Delete result by ID
Future<int> deleteResultByID(int id) async {
  final db = await instance.database;
  return await db.delete(
    'result_table',
    where: 'id = ?',
    whereArgs: [id],
  );
}


// Delete all results
Future<int> deleteAllResults() async {
  final db = await instance.database;
  return await db.delete(
    'result_table',
  );
}


}
