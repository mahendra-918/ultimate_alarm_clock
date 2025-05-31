import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/user_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:sqflite/sqflite.dart';

import '../../modules/home/controllers/home_controller.dart';
import 'get_storage_provider.dart';

class FirestoreDb {
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  static final _firebaseAuthInstance = FirebaseAuth.instance;

  static final storage = Get.find<GetStorageProvider>();

  Future<Database?> getSQLiteDatabase() async {
    Database? db;

    final dir = await getDatabasesPath();
    final dbPath = '$dir/alarms.db';
    print(dir);
    db = await openDatabase(dbPath, version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
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
        alarmDate TEXT NOT NULL DEFAULT "",
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

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add missing alarmDate column
      try {
        await db.execute('ALTER TABLE alarms ADD COLUMN alarmDate TEXT NOT NULL DEFAULT ""');
        print('Successfully added alarmDate column to alarms table');
      } catch (e) {
        print('Error adding alarmDate column: $e');
      }
    }
  }

  static CollectionReference _alarmsCollection(UserModel? user) {
    if (user == null) {
      // Hacky fix to prevent stream from not emitting
      return _firebaseFirestore.collection('alarms');
    } else {
      // return _firebaseFirestore
      //     .collection('users')
      //     .doc(user.id)
      //     .collection('alarms');

      return _firebaseFirestore
            .collection('sharedAlarms');
    }
  }

  static Future<void> addUser(UserModel userModel) async {
    final DocumentReference docRef = _usersCollection.doc(userModel.id);
    final user = await docRef.get();
    if (!user.exists) await docRef.set(userModel.toJson());
  }

  static addAlarm(UserModel? user, AlarmModel alarmRecord) async {
    if (user == null) {
      return alarmRecord;
    }
    
    // Only store in SQLite if it's NOT a shared alarm
    if (!alarmRecord.isSharedAlarmEnabled) {
      final sql = await FirestoreDb().getSQLiteDatabase();
      await sql!
          .insert('alarms', alarmRecord.toSQFliteMap())
          .then((value) => print('insert success'));
    }

    // Always store shared alarms in Firestore
    await _alarmsCollection(user)
        .add(AlarmModel.toMap(alarmRecord))
        .then((value) => alarmRecord.firestoreId = value.id);
    
    return alarmRecord;
  }

  static Future<UserModel?> fetchUserDetails(String userId) async {
    final DocumentSnapshot userSnapshot =
        await _usersCollection.doc(userId).get();

    if (userSnapshot.exists) {
      final UserModel user =
          UserModel.fromJson(userSnapshot.data() as Map<String, dynamic>);
      return user;
    }

    return null;
  }

  static Future<bool> doesAlarmExist(UserModel? user, String alarmID) async {
    QuerySnapshot snapshot = await _alarmsCollection(user)
        .where('alarmID', isEqualTo: alarmID)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<AlarmModel> getTriggeredAlarm(
    UserModel? user,
    String time,
  ) async {
    HomeController homeController = Get.find<HomeController>();
    if (user == null) return homeController.genFakeAlarmModel();
    QuerySnapshot snapshot = await _alarmsCollection(user)
        .where('isEnabled', isEqualTo: true)
        .where('alarmTime', isEqualTo: time)
        .get();

    List list = snapshot.docs.map((DocumentSnapshot document) {
      return AlarmModel.fromDocumentSnapshot(
        documentSnapshot: document,
        user: user,
      );
    }).toList();

    return list[0];
  }

  static Future<AlarmModel> getLatestAlarm(
    UserModel? user,
    AlarmModel alarmRecord,
    bool wantNextAlarm,
  ) async {
    if (user == null) {
      alarmRecord.minutesSinceMidnight = -1;
      return alarmRecord;
    }

    int nowInMinutes = Utils.timeOfDayToInt(
      TimeOfDay(
        hour: TimeOfDay.now().hour,
        minute: TimeOfDay.now().minute + 1,
      ),
    );

    late List<AlarmModel> alarms = [];

    // Get shared alarms from Firestore ONLY
    QuerySnapshot snapshotSharedAlarms = await _firebaseFirestore
        .collection('sharedAlarms')
        .where('isEnabled', isEqualTo: true)
        .where(      
        Filter.or(
        Filter('sharedUserIds', arrayContains:  user.id),
        Filter('ownerId', isEqualTo: user.id),
      ),)
        .get();

    final sharedAlarms = snapshotSharedAlarms.docs.map((DocumentSnapshot document) {
      return AlarmModel.fromDocumentSnapshot(
        documentSnapshot: document,
        user: user,
      );
    }).toList();
    
    alarms.addAll(sharedAlarms);

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

        // If alarm is one-time and has already passed, set time until
        // next alarm to next day
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

  static updateAlarm(String? userId, AlarmModel alarmRecord) async {
    // Only update SQLite if it's NOT a shared alarm
    if (!alarmRecord.isSharedAlarmEnabled) {
      final sql = await FirestoreDb().getSQLiteDatabase();
      await sql!.update(
        'alarms',
        alarmRecord.toSQFliteMap(),
        where: 'alarmID = ?',
        whereArgs: [alarmRecord.alarmID],
      );
    }
    
    // Always update Firestore for shared alarms
    await _firebaseFirestore
        .collection('sharedAlarms')
        .doc(alarmRecord.firestoreId)
        .update(AlarmModel.toMap(alarmRecord));
  }

static Future<String> userExists(String email) async {
  final querySnapshot = await _firebaseFirestore
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.data()['fullName'];
  }

  return 'error';
}

  static shareProfile(List emails) async {
    final profileSet = await IsarDb.getProfileAlarms();
    final currentProfileName = await storage.readProfile();

    final currentUserEmail = _firebaseAuthInstance.currentUser!.email;
    profileSet['owner'] = currentUserEmail;
    Map sharedItem = {
      'type': 'profile',
      'profileName': currentProfileName,
      'owner': currentUserEmail
    };
    await _firebaseFirestore
        .collection('users')
        .doc(currentUserEmail)
        .collection('sharedProfile')
        .doc(currentProfileName)
        .set(profileSet)
        .then((v) {
      Get.snackbar('Notification', 'Item Shared!');
    });
    ;
    for (final email in emails) {
      await _firebaseFirestore.collection('users').doc(email).update({
        'receivedItems': FieldValue.arrayUnion([sharedItem])
      });
    }
  }

static Future<List<String>> getUserIdsByEmails(List emails) async {
  List<String> userIds = [];

  const batchSize = 10;
  for (int i = 0; i < emails.length; i += batchSize) {
    final batch = emails.sublist(i, i + batchSize > emails.length ? emails.length : i + batchSize);
    final querySnapshot = await _firebaseFirestore
        .collection('users')
        .where('email', whereIn: batch)
        .get();

    for (var doc in querySnapshot.docs) {
      userIds.add(doc.id);
    }
  }

  return userIds;
}


  static Future<void> shareAlarm(List emails, AlarmModel alarm) async {
    if (emails.isEmpty) {
      debugPrint('No emails provided for sharing');
      return;
    }

    final currentUserId = _firebaseAuthInstance.currentUser!.providerData[0].uid;
    alarm.profile = 'Default';
    Map sharedItem = {
      'type': 'alarm',
      'AlarmName': alarm.firestoreId,
      'owner': currentUserId,
      'alarmTime': alarm.alarmTime
    };

    try {
      // Process all email operations in parallel with error handling
      final results = await Future.wait(
        emails.map((email) => addItemToUserByEmail(email, sharedItem).catchError((e) {
          debugPrint('Error sharing to $email: $e');
          return false; // Return false to indicate failure
        })),
        eagerError: false // Don't stop on first error
      );
      
      // Check if any operations succeeded
      if (results.any((success) => success != false)) {
        debugPrint('Alarm shared with at least one recipient');
      } else {
        debugPrint('Failed to share alarm with any recipients');
        // Don't throw error - let the alarm still be created locally
        debugPrint('Continuing with alarm creation despite sharing failures');
      }
    } catch (e) {
      debugPrint('Error in shareAlarm: $e');
      // Don't rethrow - continue with alarm creation
      debugPrint('Continuing with alarm creation despite sharing error: $e');
    }
  }

static Future<bool> addItemToUserByEmail(String email, dynamic sharedItem) async {
  try {
    final querySnapshot = await _firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await _firebaseFirestore.collection('users').doc(docId).update({
        'receivedItems': FieldValue.arrayUnion([sharedItem])
      });
      return true; // Success
    }
    return false; // User not found
  } catch (e) {
    debugPrint('Error adding item to user $email: $e');
    return false; // Failed
  }
}


  static Future receiveProfile(String email, String profileName) async {
    final profile = await _firebaseFirestore
        .collection('users')
        .doc(email)
        .collection('sharedProfile')
        .doc(profileName)
        .get();
    return profile.data();
  }

  static Future receiveAlarm(String ownerId, String alarmId) async {
    final alarm = await _firebaseFirestore
        .collection('sharedAlarms')
        .doc(alarmId)
        .get();
    return alarm.data();
  }

  static Future<void> deleteOneTimeAlarm(
    String? ownerId,
    String? firestoreId,
  ) async {
    try {
      // Delete alarm remotely (from Firestore)
      await FirebaseFirestore.instance
          .collection('sharedAlarms')
          .doc(firestoreId)
          .delete();
      
      // Check if it exists in SQLite and delete if found
      final sql = await FirestoreDb().getSQLiteDatabase();
      await sql!.delete('alarms', where: 'firestoreId = ?', whereArgs: [firestoreId]);

      debugPrint('Alarm deleted successfully from Firestore.');
    } catch (e) {
      debugPrint('Error deleting alarm from Firestore: $e');
    }
  }

  static getAlarm(UserModel? user, String id) async {
    if (user == null) return null;
    return await _alarmsCollection(user).doc(id).get();
  }

  // static Stream<QuerySnapshot<Object?>> getAlarms(UserModel? user) {
  //   return _alarmsCollection(user)
  //       .orderBy('minutesSinceMidnight', descending: false)
  //       .snapshots();
  // }

  static Stream<QuerySnapshot<Object?>> getSharedAlarms(UserModel? user) {
    if (user != null) {
      Stream<QuerySnapshot<Object?>> sharedAlarmsStream = _firebaseFirestore
          .collection('sharedAlarms')
        .where(      
        Filter.or(
        Filter('sharedUserIds', arrayContains:  user.id),
        Filter('ownerId', isEqualTo: user.id),
      ),)          .snapshots();

      return sharedAlarmsStream;
    } else {
      return _alarmsCollection(user)
          .orderBy('minutesSinceMidnight', descending: false)
          .snapshots();
    }
  }

  static Stream<QuerySnapshot<Object?>> getAlarms(UserModel? user) {
    if (user != null) {
      Stream<QuerySnapshot<Object?>> userAlarmsStream = _alarmsCollection(user)
                .where(      
        Filter.or(
        Filter('sharedUserIds', arrayContains:  user.id),
        Filter('ownerId', isEqualTo: user.id),
      ),)
          .snapshots(includeMetadataChanges: true);

      return userAlarmsStream;
    } else {
      return _alarmsCollection(user)
          .orderBy('minutesSinceMidnight', descending: false)
          .snapshots();
    }
  }

  static deleteAlarm(UserModel? user, String id) async {
    if (user == null) return;
    
    try {
      // Delete from Firestore (for shared alarms)
      await _firebaseFirestore
          .collection('sharedAlarms')
          .doc(id)
          .delete();
      
      // Also attempt to delete from SQLite if it exists there
      final sql = await FirestoreDb().getSQLiteDatabase();
      await sql!.delete('alarms', where: 'firestoreId = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
    }
  }

  static addUserToAlarmSharedUsers(UserModel? userModel, String alarmID) async {
    String userModelId = userModel!.id;

    final alarmQuerySnapshot = await _firebaseFirestore
        .collectionGroup('alarms')
        .where('alarmID', isEqualTo: alarmID)
        .get();

    if (alarmQuerySnapshot.size == 0) {
      return false;
    }
    final alarmDoc = alarmQuerySnapshot.docs[0];

    if (alarmDoc.data()['ownerId'] == userModelId) {
      return null;
    }

    final sharedUserIds =
        List<String>.from(alarmDoc.data()['sharedUserIds'] ?? []);
    final offsetDetails =
        Map<String, dynamic>.from(alarmDoc.data()['offsetDetails'] ?? {});

    offsetDetails[userModelId] = {
      'isOffsetBefore': true,
      'offsetDuration': 0,
      'offsettedTime': alarmDoc.data()['alarmTime'],
    };

    if (!sharedUserIds.contains(userModelId)) {
      sharedUserIds.add(userModelId);
      await alarmDoc.reference.update(
        {'sharedUserIds': sharedUserIds, 'offsetDetails': offsetDetails},
      );
    }
    return true;
  }

  static Future<List<String>> removeUserFromAlarmSharedUsers(
    UserModel? userModel,
    String alarmID,
  ) async {
    String userModelId = userModel!.id;

    final alarmQuerySnapshot = await _firebaseFirestore
        .collection('alarms')
        .where('alarmID', isEqualTo: alarmID)
        .get();

    if (alarmQuerySnapshot.size == 0) {
      return []; // Return an empty list if the alarm is not found
    }

    final alarmDoc = alarmQuerySnapshot.docs[0];
    final sharedUserIds =
        List<String>.from(alarmDoc.data()['sharedUserIds'] ?? []);

    if (sharedUserIds.contains(userModelId)) {
      sharedUserIds.remove(userModelId); // Remove the userId from the list
      await alarmDoc.reference.update({'sharedUserIds': sharedUserIds});
    }

    return sharedUserIds; // Return the updated sharedUserIds list
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>>
      getNotifications() async* {
    Stream<DocumentSnapshot<Map<String, dynamic>>> userNotifications =
        _firebaseFirestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.providerData[0].uid)
            .snapshots();

    yield* userNotifications;
  }

  static removeItem(Map item) async {
    print(item);

    await _firebaseFirestore
        .collection('users')
        .doc(_firebaseAuthInstance.currentUser!.providerData[0].uid)
        .update({
      'receivedItems': FieldValue.arrayRemove([item])
    });
  }


  static updateToken(String token) async {
    try {
      if (_firebaseAuthInstance.currentUser != null && 
          _firebaseAuthInstance.currentUser!.providerData.isNotEmpty) {
        await _firebaseFirestore
            .collection('users')
            .doc(_firebaseAuthInstance.currentUser!.providerData[0].uid)
            .update({
          'fcmToken': token
        });
      } else {
        debugPrint('No authenticated user found when updating FCM token');
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  static acceptSharedAlarm(String alarmOwnerId, AlarmModel alarm)
  async {

    String? currentUserId = _firebaseAuthInstance.currentUser!.providerData[0].uid;
await _firebaseFirestore
    .collection('sharedAlarms')
    .doc(alarm.firestoreId)
    .update({
  'offsetDetails': FieldValue.arrayUnion([{
    'userId': currentUserId,
    'isOffsetBefore': true,
    'offsetDuration': 0,
    'offsettedTime': alarm.alarmTime,
  }]),
  'sharedUserIds': FieldValue.arrayUnion([currentUserId]), 
});
  }

  static Future<AlarmModel> saveSharedAlarm(UserModel? user, AlarmModel alarmRecord) async {
    if (user == null) {
      return alarmRecord;
    }
    
    // Make sure it's marked as a shared alarm
    alarmRecord.isSharedAlarmEnabled = true;
    
    // Store only in Firestore
    await _firebaseFirestore
        .collection('sharedAlarms')
        .add(AlarmModel.toMap(alarmRecord))
        .then((value) => alarmRecord.firestoreId = value.id);
    
    return alarmRecord;
  }

  static Future<void> triggerRescheduleUpdate(AlarmModel alarmData) async {
    try {
      // Update the alarm document with a timestamp to trigger real-time listeners
      // This ensures receivers get notified even if push notifications fail
      await _firebaseFirestore
          .collection('sharedAlarms')
          .doc(alarmData.firestoreId)
          .update({
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastEditedUserId': _firebaseAuthInstance.currentUser?.providerData[0].uid,
        // Force update the main alarm fields to ensure change detection
        'alarmTime': alarmData.alarmTime,
        'minutesSinceMidnight': alarmData.minutesSinceMidnight,
        'isEnabled': alarmData.isEnabled,
      });
      
      debugPrint('✅ Triggered Firestore update for shared alarm reschedule: ${alarmData.firestoreId}');
    } catch (e) {
      debugPrint('❌ Error triggering Firestore reschedule update: $e');
    }
  }
}