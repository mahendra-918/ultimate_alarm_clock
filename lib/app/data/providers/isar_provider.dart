import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/profile_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/ringtone_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/saved_emails.dart';
import 'package:ultimate_alarm_clock/app/data/models/timer_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/get_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

enum Status {
  error('ERROR'),
  success('SUCCESS'),
  warning('WARNING');

  final String value;
  const Status(this.value);

  @override
  String toString() => value;
}

enum LogType {
  dev("DEV"),
  normal("NORMAL");

  final String value;
  const LogType(this.value);

  @override
  String toString() => value;
}


class IsarDb {
  static final IsarDb _instance = IsarDb._internal();
  late Future<Isar> db;

  factory IsarDb() {
    return _instance;
  }

  IsarDb._internal() {
    db = openDB();
  }
  static final storage = Get.find<GetStorageProvider>();

  Future<Database?> getAlarmSQLiteDatabase() async {
    Database? db;

    final dir = await getDatabasesPath();
    final dbPath = '$dir/alarms.db';
    db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<Database?> getTimerSQLiteDatabase() async {
    Database? db;
    final dir = await getDatabasesPath();
    db = await openDatabase(
      '$dir/timer.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE timers ( 
            id integer primary key autoincrement, 
            startedOn text not null,
            timerValue integer not null,
            timeElapsed integer not null,
            ringtoneName text not null,
            timerName text not null,
            isPaused integer not null)
        ''');
      },
    );
    return db;
  }

  Future<Database?> setAlarmLogs() async {
    try {
      final dir = await getDatabasesPath();
      debugPrint('Database directory: $dir');
      final dbPath = '$dir/AlarmLogs.db';
      debugPrint('Attempting to open or create logs database at: $dbPath');
      
      // Try to create the database with more explicit error handling
      Database? db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (Database db, int version) async {
          debugPrint('Creating alarm logs table - this should happen on first run');
          try {
            await db.execute('''
              CREATE TABLE LOG (
                LogID INTEGER PRIMARY KEY AUTOINCREMENT,  
                LogTime DATETIME NOT NULL,            
                Status TEXT CHECK(Status IN ('ERROR', 'SUCCESS', 'WARNING')) NOT NULL,
                LogType TEXT CHECK(LogType IN ('DEV', 'NORMAL')) NOT NULL,
                Message TEXT NOT NULL,
                HasRung INTEGER DEFAULT 0,
                AlarmID TEXT
              )
            ''');
            
            // Test the table was created by inserting a record
            final testId = await db.insert(
              'LOG',
              {
                'LogTime': DateTime.now().millisecondsSinceEpoch,
                'Status': 'SUCCESS',
                'LogType': 'NORMAL',
                'Message': 'Log system initialized',
                'HasRung': 0,
                'AlarmID': '',
              },
            );
            
            debugPrint('Test record inserted with ID: $testId');
          } catch (e) {
            debugPrint('Error creating logs table: $e');
            // Try to handle specific SQL errors here
          }
        },
        onOpen: (db) async {
          // Check if table exists
          try {
            final tables = await db.query('sqlite_master', 
                where: "type = 'table' AND name = 'LOG'");
            
            if (tables.isEmpty) {
              debugPrint('LOG table not found! Attempting to create it.');
              await db.execute('''
                CREATE TABLE IF NOT EXISTS LOG (
                  LogID INTEGER PRIMARY KEY AUTOINCREMENT,  
                  LogTime DATETIME NOT NULL,            
                  Status TEXT CHECK(Status IN ('ERROR', 'SUCCESS', 'WARNING')) NOT NULL,
                  LogType TEXT CHECK(LogType IN ('DEV', 'NORMAL')) NOT NULL,
                  Message TEXT NOT NULL,
                  HasRung INTEGER DEFAULT 0,
                  AlarmID TEXT
                )
              ''');
            } else {
              debugPrint('LOG table exists with structure: ${tables.first}');
              
              // Count the records
              final count = Sqflite.firstIntValue(
                  await db.rawQuery('SELECT COUNT(*) FROM LOG'));
              debugPrint('Current log count: $count');
            }
          } catch (e) {
            debugPrint('Error checking LOG table: $e');
          }
        },
      );
      
      return db;
    } catch (e) {
      debugPrint('Critical error opening database: $e');
      // Try a fallback location if possible
      try {
        final dir = await getApplicationDocumentsDirectory();
        final dbPath = '${dir.path}/AlarmLogsBackup.db';
        debugPrint('Attempting fallback database at: $dbPath');
        
        return await openDatabase(
          dbPath,
          version: 1,
          onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE LOG (
                LogID INTEGER PRIMARY KEY AUTOINCREMENT,  
                LogTime DATETIME NOT NULL,            
                Status TEXT CHECK(Status IN ('ERROR', 'SUCCESS', 'WARNING')) NOT NULL,
                LogType TEXT CHECK(LogType IN ('DEV', 'NORMAL')) NOT NULL,
                Message TEXT NOT NULL,
                HasRung INTEGER DEFAULT 0,
                AlarmID TEXT
              )
            ''');
          },
        );
      } catch (fallbackError) {
        debugPrint('Even fallback database failed: $fallbackError');
        return null;
      }
    }
  }

  void _onCreate(Database db, int version) async {
    // Create tables for alarms and ringtones (modify column types as needed)
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firestoreId TEXT,
        alarmTime TEXT NOT NULL,
        alarmID TEXT NOT NULL UNIQUE,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        isLocationEnabled INTEGER NOT NULL DEFAULT 0,
        isSharedAlarmEnabled INTEGER NOT NULL DEFAULT 0,
        isWeatherEnabled INTEGER NOT NULL DEFAULT 0,
        location TEXT,
        activityInterval INTEGER,
        minutesSinceMidnight INTEGER NOT NULL,
        days TEXT NOT NULL,
        weatherTypes TEXT NOT NULL,
        isMathsEnabled INTEGER NOT NULL DEFAULT 0,
        mathsDifficulty INTEGER,
        numMathsQuestions INTEGER,
        isShakeEnabled INTEGER NOT NULL DEFAULT 0,
        shakeTimes INTEGER,
        isQrEnabled INTEGER NOT NULL DEFAULT 0,
        qrValue TEXT,
        isPedometerEnabled INTEGER NOT NULL DEFAULT 0,
        numberOfSteps INTEGER,
        intervalToAlarm INTEGER,
        isActivityEnabled INTEGER NOT NULL DEFAULT 0,
        sharedUserIds TEXT,
        ownerId TEXT NOT NULL,
        ownerName TEXT NOT NULL,
        lastEditedUserId TEXT,
        mutexLock INTEGER NOT NULL DEFAULT 0,
        mainAlarmTime TEXT,
        label TEXT,
        isOneTime INTEGER NOT NULL DEFAULT 0,
        snoozeDuration INTEGER,
        gradient INTEGER,
        ringtoneName TEXT,
        note TEXT,
        deleteAfterGoesOff INTEGER NOT NULL DEFAULT 0,
        showMotivationalQuote INTEGER NOT NULL DEFAULT 0,
        volMin REAL,
        volMax REAL,
        activityMonitor INTEGER,
        alarmDate TEXT NOT NULL,
        profile TEXT NOT NULL,
        isGuardian INTEGER,
        guardianTimer INTEGER,
        guardian TEXT,
        isCall INTEGER,
        ringOn INTEGER
        
      )
    ''');
    await db.execute('''
      CREATE TABLE ringtones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ringtoneName TEXT NOT NULL,
        ringtonePath TEXT NOT NULL,
        currentCounterOfUsage INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }


  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [
          AlarmModelSchema,
          RingtoneModelSchema,
          TimerModelSchema,
          ProfileModelSchema,
          Saved_EmailsSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
  Future<int> insertLog(String msg, {Status status = Status.warning, LogType type = LogType.dev, int hasRung = 0, String alarmID = ''}) async {
    try {
      final db = await setAlarmLogs();
      if (db == null) {
        debugPrint('Failed to initialize database for logs');
        return -1;
      }
      
      // Trim message if too long (SQLite has limits)
      String trimmedMsg = msg;
      if (trimmedMsg.length > 500) {
        trimmedMsg = trimmedMsg.substring(0, 497) + '...';
      }
      
      // Ensure alarmID is not null
      String safeAlarmID = alarmID.isEmpty ? '' : alarmID;
      
      String st = status.toString();
      String t = type.toString();
      
      // Print the exact values we're inserting for debugging
      debugPrint('Inserting log with Status: $st, LogType: $t, Message: $trimmedMsg, HasRung: $hasRung, AlarmID: $safeAlarmID');
      
      final result = await db.insert(
        'LOG',
        {
          'LogTime': DateTime.now().millisecondsSinceEpoch,
          'Status': st,
          'LogType': t,
          'Message': trimmedMsg,
          'HasRung': hasRung,
          'AlarmID': safeAlarmID,
        },
      );
      
      // Add a small delay to ensure the database write completes
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('Successfully inserted log with ID: $result, Message: $trimmedMsg, AlarmID: $safeAlarmID');
      
      return result;
    } catch (e) {
      debugPrint('Error inserting log: $e');
      // Try one more time with a simplified message
      try {
        final db = await setAlarmLogs();
        if (db == null) return -1;
        
        final result = await db.insert(
          'LOG',
          {
            'LogTime': DateTime.now().millisecondsSinceEpoch,
            'Status': status.toString(),
            'LogType': type.toString(),
            'Message': 'Alarm operation (details unavailable)',
            'HasRung': hasRung,
            'AlarmID': alarmID.isEmpty ? '' : alarmID,
          },
        );
        
        debugPrint('Successfully inserted fallback log: $result');
        return result;
      } catch (fallbackError) {
        debugPrint('Even fallback log insert failed: $fallbackError');
        return -1;
      }
    }
  }

  // Fetch all log entries
  Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      debugPrint('Attempting to fetch logs from database...');
      final db = await setAlarmLogs();
      if (db == null) {
        debugPrint('Failed to initialize database for logs');
        return [];
      }
      
      // Verify the database is actually open
      if (!db.isOpen) {
        debugPrint('Warning: Database not open, trying to reopen...');
        try {
          final dir = await getDatabasesPath();
          final dbPath = '$dir/AlarmLogs.db';
          final reopenedDb = await openDatabase(dbPath);
          if (!reopenedDb.isOpen) {
            debugPrint('Failed to reopen database!');
            return [];
          }
          debugPrint('Successfully reopened database');
          
          // Try to access the logs
          final logs = await reopenedDb.query('LOG');
          debugPrint('Successfully retrieved ${logs.length} logs after reopening');
          return logs;
        } catch (e) {
          debugPrint('Error reopening database: $e');
          return [];
        }
      }
      
      // If we get here, the database should be open
      try {
        // First check if the LOG table exists
        final tables = await db.query('sqlite_master', 
            where: "type = 'table' AND name = 'LOG'");
        
        if (tables.isEmpty) {
          debugPrint('LOG table not found! Creating it now...');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS LOG (
              LogID INTEGER PRIMARY KEY AUTOINCREMENT,  
              LogTime DATETIME NOT NULL,            
              Status TEXT CHECK(Status IN ('ERROR', 'SUCCESS', 'WARNING')) NOT NULL,
              LogType TEXT CHECK(LogType IN ('DEV', 'NORMAL')) NOT NULL,
              Message TEXT NOT NULL,
              HasRung INTEGER DEFAULT 0,
              AlarmID TEXT
            )
          ''');
          
          // Insert a test entry to verify the table was created successfully
          final testId = await db.insert(
            'LOG',
            {
              'LogTime': DateTime.now().millisecondsSinceEpoch,
              'Status': Status.success.toString(),
              'LogType': LogType.normal.toString(),
              'Message': 'Log system initialized',
              'HasRung': 0,
              'AlarmID': '',
            },
          );
          
          debugPrint('Created LOG table and inserted test entry with ID: $testId');
          
          // Return the single test log
          return [
            {
              'LogID': testId,
              'LogTime': DateTime.now().millisecondsSinceEpoch,
              'Status': Status.success.toString(),
              'LogType': LogType.normal.toString(),
              'Message': 'Log system initialized',
              'HasRung': 0,
              'AlarmID': '',
            }
          ];
        }
        
        // Table exists, so query the logs
        final logs = await db.query('LOG');
        debugPrint('Successfully retrieved ${logs.length} logs');
        
        if (logs.isEmpty) {
          debugPrint('No logs found in the database - creating a test entry');
          final testId = await db.insert(
            'LOG',
            {
              'LogTime': DateTime.now().millisecondsSinceEpoch,
              'Status': Status.success.toString(),
              'LogType': LogType.normal.toString(),
              'Message': 'No logs found - creating initial log entry',
              'HasRung': 0,
              'AlarmID': '',
            },
          );
          
          debugPrint('Created test log entry with ID: $testId');
          
          // Return the single test log
          return [
            {
              'LogID': testId,
              'LogTime': DateTime.now().millisecondsSinceEpoch,
              'Status': Status.success.toString(),
              'LogType': LogType.normal.toString(),
              'Message': 'No logs found - creating initial log entry',
              'HasRung': 0,
              'AlarmID': '',
            }
          ];
        }
        
        return logs;
      } catch (e) {
        debugPrint('Error querying logs: $e');
        
        // Try to create the table anyway as a last resort
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS LOG (
              LogID INTEGER PRIMARY KEY AUTOINCREMENT,  
              LogTime DATETIME NOT NULL,            
              Status TEXT CHECK(Status IN ('ERROR', 'SUCCESS', 'WARNING')) NOT NULL,
              LogType TEXT CHECK(LogType IN ('DEV', 'NORMAL')) NOT NULL,
              Message TEXT NOT NULL,
              HasRung INTEGER DEFAULT 0,
              AlarmID TEXT
            )
          ''');
          
          debugPrint('Created LOG table as a fallback');
          return [];
        } catch (e2) {
          debugPrint('Failed even creating fallback table: $e2');
          return [];
        }
      }
    } catch (e) {
      debugPrint('Critical error retrieving logs: $e');
      // Create an in-memory database as a last resort
      try {
        final tempDb = await openDatabase(':memory:');
        await tempDb.execute('''
          CREATE TABLE LOG (
            LogID INTEGER PRIMARY KEY AUTOINCREMENT,  
            LogTime DATETIME NOT NULL,            
            Status TEXT CHECK(Status IN ('ERROR', 'SUCCESS', 'WARNING')) NOT NULL,
            LogType TEXT CHECK(LogType IN ('DEV', 'NORMAL')) NOT NULL,
            Message TEXT NOT NULL,
            HasRung INTEGER DEFAULT 0,
            AlarmID TEXT
          )
        ''');
        
        // Insert a fallback entry
        final testId = await tempDb.insert(
          'LOG',
          {
            'LogTime': DateTime.now().millisecondsSinceEpoch,
            'Status': Status.warning.toString(),
            'LogType': LogType.normal.toString(),
            'Message': 'FALLBACK LOG: Database error occurred',
            'HasRung': 0,
            'AlarmID': '',
          },
        );
        
        debugPrint('Created in-memory fallback log with ID: $testId');
        
        return [
          {
            'LogID': testId,
            'LogTime': DateTime.now().millisecondsSinceEpoch,
            'Status': Status.warning.toString(),
            'LogType': LogType.normal.toString(),
            'Message': 'FALLBACK LOG: Database error occurred',
            'HasRung': 0,
            'AlarmID': '',
          }
        ];
      } catch (e2) {
        debugPrint('Even in-memory database failed: $e2');
        return [];
      }
    }
  }

  Future<void> clearLogs() async {
    try {
      final db = await setAlarmLogs();
      if (db == null) {
        debugPrint('Failed to initialize database for logs');
        return;
      }
      await db.delete('LOG');
      debugPrint('Successfully cleared all logs');
    } catch (e) {
      debugPrint('Error clearing logs: $e');
      rethrow;
    }
  }

  Future<bool> deleteLog(int logId) async {
    try {
      debugPrint('Deleting log with LogID: $logId');
      final db = await setAlarmLogs();
      if (db == null) {
        debugPrint('Failed to initialize database for logs');
        return false;
      }
      
      final rowsAffected = await db.delete(
        'LOG',
        where: 'LogID = ?',
        whereArgs: [logId],
      );
      
      final success = rowsAffected > 0;
      debugPrint(success 
          ? 'Successfully deleted log with LogID: $logId' 
          : 'No log found with LogID: $logId');
      
      return success;
    } catch (e) {
      debugPrint('Error deleting log: $e');
      return false;
    }
  }

  static Future<AlarmModel> addAlarm(AlarmModel alarmRecord) async {
    debugPrint('ADDING ALARM: ${alarmRecord.alarmID}, time: ${alarmRecord.alarmTime}');
    
    try {
      final isarProvider = IsarDb();
      final sql = await IsarDb().getAlarmSQLiteDatabase();
      if (sql == null) {
        debugPrint('ERROR: SQLite database is null!');
        throw Exception('SQLite database is null');
      }
      
      final db = await isarProvider.db;
      await db.writeTxn(() async {
        await db.alarmModels.put(alarmRecord);
        debugPrint('Successfully added alarm to Isar DB');
      });
      
      final sqlmap = alarmRecord.toSQFliteMap();
      debugPrint('Alarm SQLite map: $sqlmap');
      
      final sqlResult = await sql.insert('alarms', sqlmap);
      debugPrint('Successfully added alarm to SQLite DB with result: $sqlResult');
      
      // Generate a more detailed log message
      String details = "Alarm created for ${alarmRecord.alarmTime}";
      if (alarmRecord.label.isNotEmpty) {
        details += " - ${alarmRecord.label}";
      }
      
      // Add day information if it's a repeating alarm
      if (alarmRecord.days.contains(true)) {
        List<String> dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
        List<String> activeDays = [];
        for (int i = 0; i < alarmRecord.days.length; i++) {
          if (alarmRecord.days[i]) {
            activeDays.add(dayNames[i]);
          }
        }
        if (activeDays.isNotEmpty) {
          details += " on ${activeDays.join(", ")}";
        }
      }
      
      // Log insertion
      final logResult = await IsarDb().insertLog(
        details,
        status: Status.success,
        type: LogType.normal,
        alarmID: alarmRecord.alarmID,
      );
      
      debugPrint('Added log entry with ID: $logResult, message: $details');
      
      // Verify logs were added
      final logs = await IsarDb().getLogs();
      debugPrint('Current logs: ${logs.length}');
      if (logs.isNotEmpty) {
        debugPrint('Latest log: ${logs.first}');
      } else {
        debugPrint('WARNING: No logs found after insertion!');
      }
      
      return alarmRecord;
    } catch (e) {
      debugPrint('Error in addAlarm: $e');
      // Try to log the error
      await IsarDb().insertLog(
        'Failed to add alarm: $e',
        status: Status.error,
        type: LogType.normal,
      );
      rethrow;
    }
  }

  static Future<ProfileModel> addProfile(ProfileModel profileModel) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    await db.writeTxn(() async {
      await db.profileModels.put(profileModel);
    });
    return profileModel;
  }

  static Stream<List<ProfileModel>> getProfiles() async* {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;
      yield* db.profileModels.where().watch(fireImmediately: true);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<ProfileModel?> getProfile(String name) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final a = await db.profileModels.filter().profileNameEqualTo(name).findFirst();
    print('$a appkle');
    return a;
  }

  static Future<List> getProfileList() async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final p = await db.profileModels.where().findAll();
    List profileNames = [];
    for (final profiles in p) {
      profileNames.add(profiles.profileName);
    }
    return profileNames;
  }

  static Future<bool> profileExists(String name) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
     final a =
        await db.profileModels.filter().profileNameEqualTo(name).findFirst();

    return a != null;
  }

  static Future profileId(String name) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final a =
        await db.profileModels.filter().profileNameEqualTo(name).findFirst();
    return a == null ? 'null' : a.isarId;
  }

  static Future<AlarmModel> getTriggeredAlarm(String time) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;

    final alarms = await db.alarmModels
        .where()
        .filter()
        .isEnabledEqualTo(true)
        .and()
        .alarmTimeEqualTo(time)
        .findAll();
    return alarms.first;
  }

  static Future<bool> doesAlarmExist(String alarmID) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final alarms =
        await db.alarmModels.where().filter().alarmIDEqualTo(alarmID).findAll();
    print('checkEmpty ${alarms[0].alarmID} ${alarms.isNotEmpty}');

    return alarms.isNotEmpty;
  }

  static Future<AlarmModel?> getAlarmByID(String alarmID) async {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;
      final alarm = await db.alarmModels.where().filter().alarmIDEqualTo(alarmID).findFirst();
      if (alarm == null) {
        // Try to find in SQLite if not found in Isar
        final sql = await IsarDb().getAlarmSQLiteDatabase();
        if (sql != null) {
          final results = await sql.query(
            'alarms',
            where: 'alarmID = ?',
            whereArgs: [alarmID],
          );
          if (results.isNotEmpty) {
            // Convert SQLite record to AlarmModel
            final firstMap = results.first;
            final model = AlarmModel(
              alarmTime: '',
              alarmID: '',
              ownerId: '',
              ownerName: '',
              lastEditedUserId: '',
              mutexLock: false,
              days: [],
              intervalToAlarm: 0,
              isActivityEnabled: false,
              minutesSinceMidnight: 0,
              isLocationEnabled: false,
              isSharedAlarmEnabled: false,
              isWeatherEnabled: false,
              location: '',
              weatherTypes: [],
              isMathsEnabled: false,
              mathsDifficulty: 0,
              numMathsQuestions: 0,
              isShakeEnabled: false,
              shakeTimes: 0,
              isQrEnabled: false,
              qrValue: '',
              isPedometerEnabled: false,
              numberOfSteps: 0,
              activityInterval: 0,
              mainAlarmTime: '',
              label: '',
              isOneTime: false,
              snoozeDuration: 0,
              gradient: 0,
              ringtoneName: '',
              note: '',
              deleteAfterGoesOff: false,
              showMotivationalQuote: false,
              volMax: 0,
              volMin: 0,
              activityMonitor: 0,
              alarmDate: '',
              ringOn: false,
              profile: '',
              isGuardian: false,
              guardianTimer: 0,
              guardian: '',
              isCall: false,
            ).fromMapSQFlite(firstMap);
            return model;
          }
        }
      }
      return alarm;
    } catch (e) {
      debugPrint('Error getting alarm by ID: $e');
      return null;
    }
  }

  static Future<AlarmModel> getLatestAlarm(
    AlarmModel alarmRecord,
    bool wantNextAlarm,
  ) async {
    int nowInMinutes = 0;
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final currentProfile = await storage.readProfile();

// Increasing a day since we need alarms AFTER the current time
// Logically, alarms at current time will ring in the future ;-;
    if (wantNextAlarm == true) {
      nowInMinutes = Utils.timeOfDayToInt(
        TimeOfDay(
          hour: TimeOfDay.now().hour,
          minute: TimeOfDay.now().minute + 1,
        ),
      );
    } else {
      nowInMinutes = Utils.timeOfDayToInt(
        TimeOfDay(
          hour: TimeOfDay.now().hour,
          minute: TimeOfDay.now().minute,
        ),
      );
    }

    // Get all enabled alarms
    List<AlarmModel> alarms = await db.alarmModels
        .where()
        .filter()
        .isEnabledEqualTo(true)
        .profileEqualTo(currentProfile)
        .findAll();

    if (alarms.isEmpty) {
      alarmRecord.minutesSinceMidnight = -1;
      return alarmRecord;
    } else {
      // Get the closest alarm to the current time
      AlarmModel closestAlarm = alarms.reduce((a, b) {
        int aTimeUntilNextAlarm = a.minutesSinceMidnight - nowInMinutes;
        int bTimeUntilNextAlarm = b.minutesSinceMidnight - nowInMinutes;

        // Check if alarm repeats on any day
        bool aRepeats = a.days.any((day) => day);
        bool bRepeats = b.days.any((day) => day);

        // If alarm is one-time and has already passed or is happening now,
        // set time until next alarm to next day
        if (!aRepeats && aTimeUntilNextAlarm < 0) {
          aTimeUntilNextAlarm += Duration.minutesPerDay;
        }
        if (!bRepeats && bTimeUntilNextAlarm < 0) {
          bTimeUntilNextAlarm += Duration.minutesPerDay;
        }

        // If alarm repeats on any day, find the next upcoming day
        if (aRepeats) {
          int currentDay = DateTime.now().weekday - 1;
          for (int i = 0; i < a.days.length; i++) {
            int dayIndex = (currentDay + i) % a.days.length;
            if (a.days[dayIndex]) {
              aTimeUntilNextAlarm += i * Duration.minutesPerDay;
              break;
            }
          }
        }

        if (bRepeats) {
          int currentDay = DateTime.now().weekday - 1;
          for (int i = 0; i < b.days.length; i++) {
            int dayIndex = (currentDay + i) % b.days.length;
            if (b.days[dayIndex]) {
              bTimeUntilNextAlarm += i * Duration.minutesPerDay;
              break;
            }
          }
        }

        return aTimeUntilNextAlarm < bTimeUntilNextAlarm ? a : b;
      });
      return closestAlarm;
    }
  }

  static Future<void> updateAlarm(AlarmModel alarmRecord) async {
    final isarProvider = IsarDb();
    final sql = await IsarDb().getAlarmSQLiteDatabase();
    final db = await isarProvider.db;
    await db.writeTxn(() async {
      await db.alarmModels.put(alarmRecord);
    });
    await IsarDb().insertLog('Alarm updated ${alarmRecord.alarmTime}', status: Status.success, type: LogType.normal, alarmID: alarmRecord.alarmID);
    await sql!.update(
      'alarms',
      alarmRecord.toSQFliteMap(),
      where: 'alarmID = ?',
      whereArgs: [alarmRecord.alarmID],
    );
  }

  static Future<AlarmModel?> getAlarm(int id) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    return db.alarmModels.get(id);
  }

  static getAlarms(String name) async* {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;
      yield* db.alarmModels
          .filter()
          .profileEqualTo(name)
          .watch(fireImmediately: true);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfileAlarms() async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final currentProfileName = await storage.readProfile();
    final currentProfile = await IsarDb.getProfile(currentProfileName);
    List<AlarmModel> alarmsModels = await db.alarmModels
        .where()
        .filter()
        .profileEqualTo(currentProfileName)
        .findAll();
    List alarmMaps = [];
    for (final item in alarmsModels) {
      alarmMaps.add(AlarmModel.toMap(item));
    }
    final Map<String, dynamic> profileSet = {
      'profileName': currentProfileName,
      'profileData': ProfileModel.toMap(currentProfile!),
      'alarmData': alarmMaps,
      'owner': ''
    };
    return profileSet;
  }

  static Future updateAlarmProfiles(String newName) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final currentProfileName = await storage.readProfile();
    final currentProfile = await IsarDb.getProfile(currentProfileName);
    List<AlarmModel> alarmsModels = await db.alarmModels
        .where()
        .filter()
        .profileEqualTo(currentProfileName)
        .findAll();
    for (final item in alarmsModels) {
      item.profile = newName;
      updateAlarm(item);
    }
  }

  static Future<void> deleteAlarm(int id) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final sql = await IsarDb().getAlarmSQLiteDatabase();
    final tobedeleted = await db.alarmModels.get(id);
    await db.writeTxn(() async {
      await db.alarmModels.delete(id);
    });
    await IsarDb().insertLog('Alarm deleted ${tobedeleted!.alarmTime}', alarmID: tobedeleted!.alarmID);
    await sql!.delete(
      'alarms',
      where: 'alarmID = ?',
      whereArgs: [tobedeleted!.alarmID],
    );
  }

  // Timer Functions

  static Future<TimerModel> insertTimer(TimerModel timer) async {
    final isarProvider = IsarDb();
    final sql = await IsarDb().getTimerSQLiteDatabase();
    final db = await isarProvider.db;
    await db.writeTxn(() async {
      await db.timerModels.put(timer);
    });

    await sql!.insert('timers', timer.toMap());
    return timer;
  }

  static Future<int> updateTimer(TimerModel timer) async {
    final sql = await IsarDb().getTimerSQLiteDatabase();
    return await sql!.update(
      'timers',
      timer.toMap(),
      where: 'id = ?',
      whereArgs: [timer.timerId],
    );
  }

  static Future<int> updateTimerName(int id, String newTimerName) async {
    final sql = await IsarDb().getTimerSQLiteDatabase();
    return await sql!.update(
      'timers',
      {'timerName': newTimerName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteTimer(int id) async {
    final isarProvider = IsarDb();
    final sql = await IsarDb().getTimerSQLiteDatabase();
    final db = await isarProvider.db;
    await db.writeTxn(() async {
      await db.timerModels.delete(id);
    });
    return await sql!.delete('timers', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TimerModel>> getAllTimers() async {
    final sql = await IsarDb().getTimerSQLiteDatabase();
    List<Map<String, dynamic>> maps = await sql!.query(
      'timers',
      columns: [
        'id',
        'startedOn',
        'timerValue',
        'timeElapsed',
        'ringtoneName',
        'timerName',
        'isPaused',
      ],
    );
    if (maps.isNotEmpty) {
      return maps.map((timer) => TimerModel.fromMap(timer)).toList();
    }
    return [];
  }

  static Future updateTimerTick(TimerModel timer) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    await db.writeTxn(() async {
      await db.timerModels.put(timer);
    });
    final sql = await IsarDb().getTimerSQLiteDatabase();
    await sql!.update(
      'timers',
      {'timeElapsed': timer.timeElapsed},
      where: 'id = ?',
      whereArgs: [timer.timerId],
    );
  }

  static Stream<List<TimerModel>> getTimers() {
    final isarProvider = IsarDb();
    final controller = StreamController<List<TimerModel>>.broadcast();

    isarProvider.db.then((db) {
      final stream = db.timerModels.where().watch(fireImmediately: true);
      stream.listen(
        (data) => controller.add(data),
        onError: (error) => controller.addError(error),
        onDone: () => controller.close(),
      );
    }).catchError((error) {
      debugPrint(error.toString());
      controller.addError(error);
    });

    return controller.stream;
  }

  static Future updateTimerPauseStatus(TimerModel timer) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    await db.writeTxn(() async {
      await db.timerModels.put(timer);
    });
    final sql = await IsarDb().getTimerSQLiteDatabase();
    await sql!.update(
      'timers',
      {'isPaused': timer.isPaused},
      where: 'id = ?',
      whereArgs: [timer.timerId],
    );
  }

  static Future<int> getNumberOfTimers() async {
    final sql = await IsarDb().getTimerSQLiteDatabase();
    List<Map<String, dynamic>> x =
        await sql!.rawQuery('SELECT COUNT (*) from timers');
    sql.close();
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

// Ringtone functions
  static Future<void> addCustomRingtone(
    RingtoneModel customRingtone,
  ) async {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;
      await db.writeTxn(() async {
        await db.ringtoneModels.put(customRingtone);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<RingtoneModel?> getCustomRingtone({
    required int customRingtoneId,
  }) async {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;
      final query = db.ringtoneModels
          .where()
          .filter()
          .isarIdEqualTo(customRingtoneId)
          .findFirst();

      return query;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<RingtoneModel>> getAllCustomRingtones() async {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;

      final query = db.ringtoneModels.where().sortByRingtoneName().findAll();

      return query;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<void> deleteCustomRingtone({
    required int ringtoneId,
  }) async {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;

      await db.writeTxn(() async {
        await db.ringtoneModels.delete(ringtoneId);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> addEmail(String email) async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final userInDb = await db.saved_Emails
        .filter()
        .emailEqualTo(email, caseSensitive: false)
        .findFirst();
    if (userInDb != null) {
      Get.snackbar('Error', 'Email already exists');
    } else {
      final username = await FirestoreDb.userExists(email);
      if (username == 'error') {
        Get.snackbar('Error', 'User not available');
      } else {
        await db.writeTxn(() async {
          await db.saved_Emails
              .put(Saved_Emails(email: email, username: username));
        }).then((value) => Get.snackbar('Success', 'Email Added'));
      }
    }
  }

  static Stream<List<Saved_Emails>> getEmails() async* {
    try {
      final isarProvider = IsarDb();
      final db = await isarProvider.db;
      yield* db.saved_Emails.where().watch(fireImmediately: true);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  static loadDefaultRingtones() async {
    final isarProvider = IsarDb();
    final db = await isarProvider.db;
    final ringtoneCount = await db.ringtoneModels.where().findAll();
    if (ringtoneCount.isEmpty) {
      await db.writeTxn(() async {
        await db.ringtoneModels.importJson([
          {'isarId' : fastHash('Digital Alarm 1'),
            'ringtoneName': 'Digital Alarm 1',
            'ringtonePath': 'ringtones/digialarm.mp3',
            'currentCounterOfUsage': 0
          },
          {'isarId' : fastHash('Digital Alarm 2'),
            'ringtoneName': 'Digital Alarm 2',
            'ringtonePath': 'ringtones/digialarm2.mp3',
            'currentCounterOfUsage': 0
          },
          {'isarId' : fastHash('Digital Alarm 3'),
            'ringtoneName': 'Digital Alarm 3',
            'ringtonePath': 'ringtones/digialarm3.mp3',
            'currentCounterOfUsage': 0
          },
          {'isarId' : fastHash('Mystery'),
            'ringtoneName': 'Mystery',
            'ringtonePath': 'ringtones/mystery.mp3',
            'currentCounterOfUsage': 0
          },
          {'isarId' : fastHash('New Day'),
            'ringtoneName': 'New Day',
            'ringtonePath': 'ringtones/newday.mp3',
            'currentCounterOfUsage': 0
          },
        ]);
      });
    }
  }
}
