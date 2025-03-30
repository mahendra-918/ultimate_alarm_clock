import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StandaloneLogsProvider {
  static final StandaloneLogsProvider _instance = StandaloneLogsProvider._internal();
  Database? _database;

  factory StandaloneLogsProvider() {
    return _instance;
  }

  StandaloneLogsProvider._internal();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      debugPrint('Initializing standalone logs database...');
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'standalone_logs.db');
      
      debugPrint('Standalone logs database path: $path');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          debugPrint('Creating standalone logs table...');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS LOGS (
              ID INTEGER PRIMARY KEY AUTOINCREMENT,
              LogTime INTEGER NOT NULL,
              Status TEXT NOT NULL,
              Type TEXT NOT NULL,
              Message TEXT NOT NULL,
              HasRung INTEGER DEFAULT 0,
              AlarmID TEXT
            )
          ''');
          
          // Insert a test record to confirm the database is working
          final testId = await db.insert(
            'LOGS',
            {
              'LogTime': DateTime.now().millisecondsSinceEpoch,
              'Status': 'SUCCESS',
              'Type': 'NORMAL',
              'Message': 'Standalone logs system initialized',
              'HasRung': 0,
              'AlarmID': '',
            },
          );
          
          debugPrint('Standalone logs test record inserted with ID: $testId');
        },
        onOpen: (db) async {
          debugPrint('Standalone logs database opened');
          final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM LOGS'));
          debugPrint('Current standalone logs count: $count');
        },
      );
    } catch (e) {
      debugPrint('ERROR initializing standalone logs database: $e');
      throw Exception('Failed to initialize standalone logs database: $e');
    }
  }

  Future<int> insertLog(String message, {
    String status = 'SUCCESS',
    String type = 'NORMAL',
    int hasRung = 0,
    String alarmID = '',
  }) async {
    try {
      debugPrint('Inserting log into standalone logs: $message');
      final db = await database;
      
      final result = await db.insert(
        'LOGS',
        {
          'LogTime': DateTime.now().millisecondsSinceEpoch,
          'Status': status,
          'Type': type,
          'Message': message,
          'HasRung': hasRung,
          'AlarmID': alarmID,
        },
      );
      
      debugPrint('Successfully inserted standalone log with ID: $result');
      return result;
    } catch (e) {
      debugPrint('ERROR inserting standalone log: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      debugPrint('Getting logs from standalone logs database...');
      final db = await database;
      
      final logs = await db.query('LOGS', orderBy: 'LogTime DESC');
      debugPrint('Successfully retrieved ${logs.length} standalone logs');
      
      return logs;
    } catch (e) {
      debugPrint('ERROR getting standalone logs: $e');
      return [];
    }
  }

  Future<void> clearLogs() async {
    try {
      debugPrint('Clearing standalone logs...');
      final db = await database;
      
      await db.delete('LOGS');
      debugPrint('Successfully cleared standalone logs');
    } catch (e) {
      debugPrint('ERROR clearing standalone logs: $e');
    }
  }

  Future<bool> deleteLog(int logId) async {
    try {
      debugPrint('Deleting standalone log with ID: $logId');
      final db = await database;
      
      final rowsAffected = await db.delete(
        'LOGS',
        where: 'ID = ?',
        whereArgs: [logId],
      );
      
      final success = rowsAffected > 0;
      debugPrint(success 
          ? 'Successfully deleted standalone log with ID: $logId' 
          : 'No standalone log found with ID: $logId');
      
      return success;
    } catch (e) {
      debugPrint('ERROR deleting standalone log: $e');
      return false;
    }
  }
} 