import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as CalendarApi;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/quote_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/user_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/get_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/secure_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/controllers/timer_controller.dart';

import '../../../data/models/profile_model.dart';
import '../../../data/providers/google_cloud_api_provider.dart';

class Pair<T, U> {
  final T first;
  final U second;

  Pair(this.first, this.second);
}

class HomeController extends GetxController {
  MethodChannel alarmChannel = const MethodChannel('ulticlock');

  Stream<QuerySnapshot>? firestoreStreamAlarms;
  Stream<QuerySnapshot>? sharedAlarmsStream;
  Stream? isarStreamAlarms;
  Stream? streamAlarms;
  List<AlarmModel> latestFirestoreAlarms = [];
  List<AlarmModel> latestIsarAlarms = [];
  List<AlarmModel> latestSharedAlarms = [];
  final alarmTime = 'No upcoming alarms!'.obs;
  bool refreshTimer = false;
  bool isEmpty = true;
  Timer? _delayTimer;
  Timer _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {});
  List alarms = [].obs;
  List notifications = [].obs;

  int lastRefreshTime = DateTime.now().millisecondsSinceEpoch;
  Timer? delayToSchedule;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      CalendarApi.CalendarApi.calendarScope,
    ],
  );
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isUserSignedIn = false.obs;
  final floatingButtonKey = GlobalKey<ExpandableFabState>();
  final floatingButtonKeyLoggedOut = GlobalKey<ExpandableFabState>();

  final alarmIdController = TextEditingController();

  ScrollController scrollController = ScrollController();
  RxDouble scalingFactor = 1.0.obs;

  RxBool isSortedAlarmListEnabled = true.obs;
  RxBool inMultipleSelectMode = false.obs;
  RxBool isAnyAlarmHolded = false.obs;
  RxBool isAllAlarmsSelected = false.obs;
  RxInt numberOfAlarmsSelected = 0.obs;
  Pair<List<AlarmModel>, List<RxBool>> alarmListPairs = Pair([], []);

  Set<Pair<dynamic, bool>> selectedAlarmSet = {};

  final RxInt duration = 3.obs;
  final RxDouble selecteddurationDouble = 0.0.obs;

  ThemeController themeController = Get.find<ThemeController>();
  RxList Calendars = [].obs;
  RxList Events = [].obs;
  final RxString calendarFetchStatus = 'Loading'.obs;
  final RxString selectedCalendar = ''.obs;
  RxBool isCalender = true.obs;
  RxBool expandProfile = false.obs;

  RxBool isProfile = false.obs;
  RxString selectedProfile = ''.obs;
  Rx<ProfileModel> profileModel = Utils.genDefaultProfileModel().obs;

  final storage = Get.find<GetStorageProvider>();

  RxBool isProfileUpdate = false.obs;

  // Keep track of the last scheduled alarm to avoid duplicates
  String? lastScheduledAlarmId;
  TimeOfDay? lastScheduledAlarmTime;
  bool? lastScheduledAlarmIsShared;
  
  // Variables to track local alarms separately
  String? lastScheduledLocalAlarmId;
  TimeOfDay? lastScheduledLocalAlarmTime;

  // Flag to prevent multiple refresh operations overlapping
  bool isRefreshing = false;

  // Flag to prevent shared alarm rescheduling right after dismissal
  bool preventSharedAlarmRescheduling = false;
  // Timer to reset the prevention flag
  Timer? _preventReschedulingTimer;
  // Track the last dismissed shared alarm to prevent immediate rescheduling
  String? lastDismissedSharedAlarmId;
  TimeOfDay? lastDismissedSharedAlarmTime;

  // Track recently dismissed shared alarms to block their rescheduling
  Set<String> recentlyDismissedAlarmIds = {};
  Timer? _dismissedAlarmsCleanupTimer;

  // New variable to store the shared alarm subscription
  late StreamSubscription<QuerySnapshot> _sharedAlarmSubscription;

  loginWithGoogle() async {
    // Logging in again to ensure right details if User has linked account
    if (await SecureStorageProvider().retrieveUserModel() != null) {
      if (await _googleSignIn.isSignedIn()) {
        GoogleSignInAccount? googleSignInAccount =
            await _googleSignIn.signInSilently();
        String fullName = googleSignInAccount!.displayName.toString();
        List<String> parts = fullName.split(' ');
        String lastName = ' ';
        if (parts.length == 3) {
          if (parts[parts.length - 1].length == 1) {
            lastName = parts[1].toLowerCase().capitalizeFirst.toString();
          } else {
            lastName = parts[parts.length - 1]
                .toLowerCase()
                .capitalizeFirst
                .toString();
          }
        } else {
          lastName =
              parts[parts.length - 1].toLowerCase().capitalizeFirst.toString();
        }
        String firstName = parts[0].toLowerCase().capitalizeFirst.toString();

        userModel.value = UserModel(
          id: googleSignInAccount.id,
          fullName: fullName,
          firstName: firstName,
          lastName: lastName,
          email: googleSignInAccount.email,
        );
        await SecureStorageProvider().storeUserModel(userModel.value!);
        isUserSignedIn.value = true;
      }
    }
  }

  initStream(UserModel? user) async {
    // firestoreStreamAlarms = FirestoreDb.getAlarms(userModel.value);
    isarStreamAlarms = IsarDb.getAlarms(selectedProfile.value);
    firestoreStreamAlarms = FirestoreDb.getSharedAlarms(userModel.value);
    Stream<List<AlarmModel>> streamAlarms = rx.Rx.combineLatest2(
      firestoreStreamAlarms!,
      isarStreamAlarms!,
      (firestoreData, isarData) {
        List<DocumentSnapshot> firestoreDocuments = firestoreData.docs;
        latestFirestoreAlarms = firestoreDocuments.map((doc) {
          return AlarmModel.fromDocumentSnapshot(
            documentSnapshot: doc,
            user: user,
          );
        }).where((alarm) {
          // Filter out alarms that have been dismissed by the current user
          if (alarm.isSharedAlarmEnabled && user != null) {
            final docData = firestoreDocuments
                .firstWhere((d) => d.id == alarm.firestoreId)
                .data() as Map<String, dynamic>?;
            
            if (docData != null) {
              final dismissedByUsers = List<String>.from(docData['dismissedByUsers'] ?? []);
              if (dismissedByUsers.contains(user.id)) {
                debugPrint('🚫 Filtering out dismissed shared alarm: ${alarm.firestoreId}');
                return false; // Exclude this alarm
              }
            }
          }
          return true; // Include this alarm
        }).toList();

        latestIsarAlarms = isarData as List<AlarmModel>;

        List<AlarmModel> alarms = [
          ...latestFirestoreAlarms,
          ...latestIsarAlarms,
        ];

        if (isSortedAlarmListEnabled.value) {
          alarms.sort((a, b) {
            final String timeA = a.alarmTime;
            final String timeB = b.alarmTime;

            // Convert the alarm time strings to DateTime objects for comparison
            DateTime dateTimeA = DateFormat('HH:mm').parse(timeA);
            DateTime dateTimeB = DateFormat('HH:mm').parse(timeB);

            // Compare the DateTime objects to sort in ascending order
            return dateTimeA.compareTo(dateTimeB);
          });
        } else {
          alarms.sort((a, b) {
            // First sort by isEnabled
            if (a.isEnabled != b.isEnabled) {
              return a.isEnabled ? -1 : 1;
            }

            // Then sort by upcoming time
            int aUpcomingTime = a.minutesSinceMidnight;
            int bUpcomingTime = b.minutesSinceMidnight;

            // Check if alarm repeats on any day
            bool aRepeats = a.days.any((day) => day);
            bool bRepeats = b.days.any((day) => day);

            // If alarm repeats on any day, find the next up+coming day
            if (aRepeats) {
              int currentDay = DateTime.now().weekday - 1;
              for (int i = 0; i < a.days.length; i++) {
                int dayIndex = (currentDay + i) % a.days.length;
                if (a.days[dayIndex]) {
                  aUpcomingTime += i * Duration.minutesPerDay;
                  break;
                }
              }
            } else {
              // If alarm is one-time and has already passed, set upcoming time
              // to next day
              if (aUpcomingTime <=
                  DateTime.now().hour * 60 + DateTime.now().minute) {
                aUpcomingTime += Duration.minutesPerDay;
              }
            }

            if (bRepeats) {
              int currentDay = DateTime.now().weekday - 1;
              for (int i = 0; i < b.days.length; i++) {
                int dayIndex = (currentDay + i) % b.days.length;
                if (b.days[dayIndex]) {
                  bUpcomingTime += i * Duration.minutesPerDay;
                  break;
                }
              }
            } else {
              // If alarm is one-time and has already passed, set upcoming time
              // to next day
              if (bUpcomingTime <=
                  DateTime.now().hour * 60 + DateTime.now().minute) {
                bUpcomingTime += Duration.minutesPerDay;
              }
            }

            return aUpcomingTime.compareTo(bUpcomingTime);
          });
        }

        return alarms;
      },
    );

    return streamAlarms;
  }

  void readProfileName() async {
    String profileName = await storage.readProfile();
    selectedProfile.value = profileName;
    ProfileModel? p = await IsarDb.getProfile(profileName);
    if (p != null)
    {
      profileModel.value = p!;
    }
    
  }

  void writeProfileName(String name) async {
    await storage.writeProfile(name);
    selectedProfile.value = name;
    ProfileModel? p = await IsarDb.getProfile(name);
    if (p != null)
    {
      profileModel.value = p!;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    
    // Clear all alarm tracking on init to ensure clean startup
    recentlyDismissedAlarmIds.clear();
    lastScheduledAlarmId = null;
    lastScheduledAlarmTime = null;
    lastScheduledAlarmIsShared = null;
    lastDismissedSharedAlarmId = null;
    lastDismissedSharedAlarmTime = null;
    preventSharedAlarmRescheduling = false;
    
    final checkDefault = await IsarDb.getProfile('Default');
    if (checkDefault == null) {
      IsarDb.addProfile(Utils.genDefaultProfileModel());
      await storage.writeProfile("Default");
      profileModel.value = Utils.genDefaultProfileModel();
    }
    readProfileName();

    userModel.value = await SecureStorageProvider().retrieveUserModel();
    if (userModel.value == null){
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        isUserSignedIn.value = false;
      } else {
        isUserSignedIn.value = true;
      }
    });
    }
    else {
        isUserSignedIn.value = true;
        // Force refresh shared alarms on app startup to sync with Firestore
        // This ensures we get the latest shared alarm data when app is opened
        try {
          await forceRefreshSharedAlarms();
          
          // IMPORTANT: Check for persisted shared alarms and reschedule them
          await checkAndReschedulePersistedSharedAlarms();
        } catch (e) {
          debugPrint('Error during initial shared alarm refresh: $e');
          // Don't let this break the app startup
        }
        
        // Start listening for real-time shared alarm changes as backup to push notifications
        setupSharedAlarmListener();
        
        // Set up periodic checks for when app resumes from background
        setupPeriodicSharedAlarmCheck();
        
        // Set up user notification listener for background notifications
        setupUserNotificationListener();
    }


    isSortedAlarmListEnabled.value = await SecureStorageProvider()
        .readSortedAlarmListValue(key: 'sorted_alarm_list');

    scrollController.addListener(() {
      final offset = scrollController.offset;
      const maxOffset = 100.0;
      const minFactor = 0.8;
      const maxFactor = 1.0;

      final newFactor = 1.0 - (offset / maxOffset).clamp(0.0, 1.0);
      scalingFactor.value = (minFactor + (maxFactor - minFactor) * newFactor);
    });

    refreshUpcomingAlarms();
  }

  /// Checks for persisted shared alarms and reschedules them on app startup
  /// This is crucial for ensuring shared alarms work even after the app is killed
  Future<void> checkAndReschedulePersistedSharedAlarms() async {
    try {
      debugPrint('🔍 Checking for persisted shared alarms on app startup...');
      
      final result = await alarmChannel.invokeMethod('checkPersistedSharedAlarm');
      
      if (result != null && result['hasActiveSharedAlarm'] == true) {
        final alarmTime = result['alarmTime'] as String;
        final alarmId = result['alarmId'] as String;
        
        debugPrint('✅ Found persisted shared alarm: $alarmTime (ID: $alarmId)');
        
        // Parse the time and check if it's still valid (in the future)
        final now = DateTime.now();
        final todayDate = DateFormat('yyyy-MM-dd').format(now);
        final alarmDateTime = DateTime.parse('$todayDate $alarmTime:00');
        
        if (alarmDateTime.isAfter(now)) {
          debugPrint('⏰ Persisted shared alarm is still valid, keeping it scheduled');
          // Don't reschedule - it's already scheduled by the native system
        } else {
          debugPrint('🗑️ Persisted shared alarm is in the past, clearing it');
          await alarmChannel.invokeMethod('clearSharedAlarmCache');
        }
      } else {
        debugPrint('❌ No persisted shared alarm found');
      }
    } catch (e) {
      debugPrint('❌ Error checking persisted shared alarms: $e');
    }
  }

  /// Sets up a real-time listener for shared alarm changes
  void setupSharedAlarmListener() {
    if (userModel.value == null) return;
    
    debugPrint('🎧 Setting up real-time shared alarm listener...');
    
    // Listen to the sharedAlarms collection for changes
    _sharedAlarmSubscription = FirebaseFirestore.instance
        .collection('sharedAlarms')
        .where(Filter.or(
          Filter('sharedUserIds', arrayContains: userModel.value!.id),
          Filter('ownerId', isEqualTo: userModel.value!.id),
        ))
        .snapshots(includeMetadataChanges: false) // Only real changes, not metadata
        .listen((QuerySnapshot snapshot) {
      
      debugPrint('📡 Received shared alarm update: ${snapshot.docChanges.length} changes');
      
      for (DocumentChange change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          try {
            AlarmModel updatedAlarm = AlarmModel.fromDocumentSnapshot(
              documentSnapshot: change.doc,
              user: userModel.value!,
            );
            
            // Check if this alarm was updated by another user (not current user)
            Map<String, dynamic>? docData = change.doc.data() as Map<String, dynamic>?;
            String? lastEditedUserId = docData?['lastEditedUserId'];
            String? currentUserId = userModel.value?.id;
            
            debugPrint('🔍 Alarm update detected:');
            debugPrint('   - Alarm ID: ${updatedAlarm.firestoreId}');
            debugPrint('   - Alarm Time: ${updatedAlarm.alarmTime}');
            debugPrint('   - Edited by: $lastEditedUserId');
            debugPrint('   - Current user: $currentUserId');
            debugPrint('   - Is enabled: ${updatedAlarm.isEnabled}');
            debugPrint('   - Is shared: ${updatedAlarm.isSharedAlarmEnabled}');
            
            // Apply updates regardless of who edited it - this ensures receivers get updates
            if (updatedAlarm.isEnabled && updatedAlarm.isSharedAlarmEnabled) {
              
              // Calculate interval to new alarm time
              TimeOfDay alarmTimeOfDay = Utils.stringToTimeOfDay(updatedAlarm.alarmTime);
              int intervalToAlarm = Utils.getMillisecondsToAlarm(
                DateTime.now(),
                Utils.timeOfDayToDateTime(alarmTimeOfDay),
              );
              
              if (intervalToAlarm > 0) {
                debugPrint('🔄 Applying shared alarm update: ${updatedAlarm.alarmTime}');
                
                // Clear tracking for this alarm so it will be rescheduled
                clearAlarmTracking(updatedAlarm.firestoreId ?? '', true);
                
                // Update the cache with new alarm data
                updateSharedAlarmCache(updatedAlarm, intervalToAlarm);
                
                debugPrint('✅ Automatically updated shared alarm to new time: ${updatedAlarm.alarmTime}');
                
                // Force refresh to apply changes immediately
                refreshTimer = true;
                refreshUpcomingAlarms();
                
                // Show a user notification if this was updated by someone else
                if (lastEditedUserId != null && 
                    currentUserId != null && 
                    lastEditedUserId != currentUserId) {
                  debugPrint('👥 Alarm updated by another user - this is a receiver update');
                  
                  // Show notification to the user about the alarm update
                  showSharedAlarmUpdateNotification(
                    updatedAlarm.alarmTime,
                    updatedAlarm.ownerName ?? 'Someone',
                  );
                }
              } else {
                debugPrint('⏰ Updated shared alarm time is in the past, clearing cache');
                clearSharedAlarmCache();
              }
            } else {
              debugPrint('❌ Updated alarm is disabled or not shared, clearing cache');
              clearSharedAlarmCache();
            }
          } catch (e) {
            debugPrint('❌ Error processing shared alarm update: $e');
          }
        }
      }
    }, onError: (error) {
      debugPrint('❌ Error in shared alarm listener: $error');
    });
  }

  /// Forces a refresh of shared alarms and ensures local cache is synchronized
  Future<void> forceRefreshSharedAlarms() async {
    if (userModel.value == null) return;
    
    try {
      debugPrint('🔄 Force refreshing shared alarms on app startup...');
      
      // Get ALL shared alarms that this user is part of from Firestore
      QuerySnapshot sharedAlarmsSnapshot = await FirebaseFirestore.instance
          .collection('sharedAlarms')
          .where(Filter.or(
            Filter('sharedUserIds', arrayContains: userModel.value!.id),
            Filter('ownerId', isEqualTo: userModel.value!.id),
          ))
          .where('isEnabled', isEqualTo: true)
          .get();
      
      debugPrint('📊 Found ${sharedAlarmsSnapshot.docs.length} enabled shared alarms in Firestore');
      
      if (sharedAlarmsSnapshot.docs.isEmpty) {
        debugPrint('❌ No shared alarms found, clearing cache');
        await clearSharedAlarmCache();
        return;
      }
      
      // Process each shared alarm to find the most recent/relevant one
      AlarmModel? latestSharedAlarm;
      int shortestInterval = -1;
      
      for (DocumentSnapshot doc in sharedAlarmsSnapshot.docs) {
        try {
          AlarmModel alarm = AlarmModel.fromDocumentSnapshot(
            documentSnapshot: doc,
            user: userModel.value!,
          );
          
          // Calculate interval to this alarm
          TimeOfDay alarmTimeOfDay = Utils.stringToTimeOfDay(alarm.alarmTime);
          DateTime alarmDateTime = Utils.timeOfDayToDateTime(alarmTimeOfDay);
          int intervalToAlarm = Utils.getMillisecondsToAlarm(DateTime.now(), alarmDateTime);
          
          debugPrint('⏰ Checking alarm ${alarm.firestoreId}: ${alarm.alarmTime}, interval: ${intervalToAlarm}ms');
          
          // Find the alarm with the shortest positive interval (next to ring)
          if (intervalToAlarm > 0 && (shortestInterval == -1 || intervalToAlarm < shortestInterval)) {
            latestSharedAlarm = alarm;
            shortestInterval = intervalToAlarm;
            debugPrint('✅ This is now the closest alarm to ring');
          }
        } catch (e) {
          debugPrint('❌ Error processing shared alarm ${doc.id}: $e');
        }
      }
      
      if (latestSharedAlarm != null && shortestInterval > 0) {
        debugPrint('🎯 Selected shared alarm: ${latestSharedAlarm.alarmTime} (ID: ${latestSharedAlarm.firestoreId})');
        
        // Update the cache with the latest alarm data
        await updateSharedAlarmCache(latestSharedAlarm, shortestInterval);
        debugPrint('✅ Updated shared alarm cache with latest data: ${latestSharedAlarm.alarmTime}');
        
        // Force a complete refresh to reschedule with new data
        refreshTimer = true;
        refreshUpcomingAlarms();
      } else {
        debugPrint('⏰ No valid shared alarms found or all are in the past, clearing cache');
        await clearSharedAlarmCache();
      }
      
    } catch (e) {
      debugPrint('❌ Error force refreshing shared alarms: $e');
    }
  }
  
  /// Updates the Android SharedPreferences with the latest shared alarm data
  Future<void> updateSharedAlarmCache(AlarmModel sharedAlarm, int intervalToAlarm) async {
    try {
      // Use method channel to update native SharedPreferences
      await alarmChannel.invokeMethod('updateSharedAlarmCache', {
        'alarmTime': sharedAlarm.alarmTime,
        'alarmID': sharedAlarm.firestoreId ?? '',
        'intervalToAlarm': intervalToAlarm,
        'isActivityEnabled': sharedAlarm.isActivityEnabled,
        'isLocationEnabled': sharedAlarm.isLocationEnabled,
        'location': sharedAlarm.location,
        'isWeatherEnabled': sharedAlarm.isWeatherEnabled,
        'weatherTypes': jsonEncode(sharedAlarm.weatherTypes),
      });
      debugPrint('✅ Updated native SharedPreferences cache for shared alarm');
    } catch (e) {
      debugPrint('❌ Error updating shared alarm cache: $e');
      // Don't rethrow - this shouldn't break normal alarm operation
    }
  }
  
  /// Clears the Android SharedPreferences shared alarm cache
  Future<void> clearSharedAlarmCache() async {
    try {
      await alarmChannel.invokeMethod('clearSharedAlarmCache');
      debugPrint('✅ Cleared native SharedPreferences shared alarm cache');
    } catch (e) {
      debugPrint('❌ Error clearing shared alarm cache: $e');
      // Don't rethrow - this shouldn't break normal alarm operation
    }
  }

  refreshUpcomingAlarms() async {
    // Check if we're already refreshing
    if (isRefreshing) {
      debugPrint('Skipping refresh - already in progress');
      return;
    }
    
    // Check if 2 seconds have passed since the last call
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastRefreshTime < 2000) {
      delayToSchedule?.cancel();
      return;
    }

    if (delayToSchedule != null && delayToSchedule!.isActive) {
      return;
    }

    delayToSchedule = Timer(const Duration(seconds: 1), () async {
      isRefreshing = true;
      try {
        debugPrint('Starting alarm refresh...');
        lastRefreshTime = DateTime.now().millisecondsSinceEpoch;
        // Cancel timer if we have to refresh
        if (refreshTimer == true) {
          if (_timer.isActive) _timer.cancel();
          if (_delayTimer != null) _delayTimer?.cancel();
          refreshTimer = false;
        }

        // Fake object to get latest alarm
        AlarmModel alarmRecord = genFakeAlarmModel();
        
        // Get local non-shared alarms from Isar
        AlarmModel isarLatestAlarm =
            await IsarDb.getLatestAlarm(alarmRecord, true);
        
        // Get shared alarms from Firestore
        AlarmModel firestoreLatestAlarm =
            await FirestoreDb.getLatestAlarm(userModel.value, alarmRecord, true);
        
        // Check if the firestore alarm is blocked OR dismissed by current user
        bool isFirestoreAlarmBlocked = false;
        if (firestoreLatestAlarm.isSharedAlarmEnabled) {
          // First check if dismissed by current user (this is the main check)
          if (userModel.value != null) {
            try {
              final alarmDoc = await FirebaseFirestore.instance
                  .collection('sharedAlarms')
                  .doc(firestoreLatestAlarm.firestoreId)
                  .get();
              
              if (alarmDoc.exists) {
                final data = alarmDoc.data() as Map<String, dynamic>;
                final dismissedByUsers = List<String>.from(data['dismissedByUsers'] ?? []);
                
                if (dismissedByUsers.contains(userModel.value!.id)) {
                  isFirestoreAlarmBlocked = true;
                  debugPrint('🚫 Shared alarm dismissed by current user, blocking: ${firestoreLatestAlarm.alarmTime}');
                }
              }
            } catch (e) {
              debugPrint('⚠️ Error checking dismissal status: $e');
            }
          }
          
          // Only check the old blocking mechanism if not dismissed
          if (!isFirestoreAlarmBlocked && isBlockedSharedAlarm(firestoreLatestAlarm.firestoreId)) {
            isFirestoreAlarmBlocked = true;
            debugPrint('Blocking blocked shared alarm in refresh: ${firestoreLatestAlarm.alarmTime}, ID: ${firestoreLatestAlarm.firestoreId}');
          }
        }
        
        // IMPORTANT: We need to schedule BOTH types of alarms (local and shared)
        // to ensure that local alarms aren't canceled when shared alarms ring
        
        // 1. First, schedule the local alarm if it's valid
          if (isarLatestAlarm.minutesSinceMidnight > 0 && isarLatestAlarm.isEnabled) {
          await scheduleAlarmIfNeeded(isarLatestAlarm, false);
          debugPrint('Scheduled local alarm: ${isarLatestAlarm.alarmTime}');
          } else {
          debugPrint('No valid local alarm to schedule');
        }
        
        // 2. Then, schedule the shared alarm if it's valid and not blocked
        if (firestoreLatestAlarm.minutesSinceMidnight > 0 && 
            firestoreLatestAlarm.isEnabled &&
            firestoreLatestAlarm.isSharedAlarmEnabled &&
            !isFirestoreAlarmBlocked) {
          await scheduleAlarmIfNeeded(firestoreLatestAlarm, true);
          debugPrint('Scheduled shared alarm: ${firestoreLatestAlarm.alarmTime}');
        } else if (isFirestoreAlarmBlocked) {
          debugPrint('Skipped blocked shared alarm: ${firestoreLatestAlarm.alarmTime}');
        } else {
          debugPrint('No valid shared alarm to schedule');
        }
        
        // For display purposes only, determine which is the next to ring
        AlarmModel? displayAlarm;
        bool hasValidAlarm = false;
        
        if (isarLatestAlarm.minutesSinceMidnight > 0 && isarLatestAlarm.isEnabled &&
            firestoreLatestAlarm.minutesSinceMidnight > 0 && firestoreLatestAlarm.isEnabled &&
            !isFirestoreAlarmBlocked) {
          // Compare times if both are valid
          TimeOfDay localTime = Utils.stringToTimeOfDay(isarLatestAlarm.alarmTime);
          TimeOfDay sharedTime = Utils.stringToTimeOfDay(firestoreLatestAlarm.alarmTime);
          
          int localTimeInMinutes = localTime.hour * 60 + localTime.minute;
          int sharedTimeInMinutes = sharedTime.hour * 60 + sharedTime.minute;
          
          if (localTimeInMinutes < sharedTimeInMinutes) {
            displayAlarm = isarLatestAlarm;
          } else {
            displayAlarm = firestoreLatestAlarm;
          }
          hasValidAlarm = true;
        } else if (isarLatestAlarm.minutesSinceMidnight > 0 && isarLatestAlarm.isEnabled) {
          displayAlarm = isarLatestAlarm;
          hasValidAlarm = true;
        } else if (firestoreLatestAlarm.minutesSinceMidnight > 0 && firestoreLatestAlarm.isEnabled && !isFirestoreAlarmBlocked) {
          displayAlarm = firestoreLatestAlarm;
          hasValidAlarm = true;
        } else {
          // No valid alarms - don't use fake alarm data for display
          debugPrint('No valid alarms found for display');
          hasValidAlarm = false;
        }

        if (hasValidAlarm && displayAlarm != null) {
          String timeToAlarm = Utils.timeUntilAlarm(
            Utils.stringToTimeOfDay(displayAlarm.alarmTime),
            displayAlarm.days,
          );
          alarmTime.value = 'Rings in $timeToAlarm';
          
          // Cancel any existing timer to prevent leaks
          if (_timer.isActive) _timer.cancel();
          if (_delayTimer != null && _delayTimer!.isActive) _delayTimer!.cancel();
          
          // Start a periodic timer that updates every 30 seconds for higher accuracy
          _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
            try {
              String updatedTimeToAlarm = Utils.timeUntilAlarm(
                Utils.stringToTimeOfDay(displayAlarm!.alarmTime),
                displayAlarm.days,
              );
              alarmTime.value = 'Rings in $updatedTimeToAlarm';
              debugPrint('Updated time-to-alarm: $updatedTimeToAlarm');
            } catch (e) {
              debugPrint('Error updating time display: $e');
            }
          });
        } else {
          // No valid alarms - stop any existing timer and show appropriate message
          if (_timer.isActive) _timer.cancel();
          if (_delayTimer != null && _delayTimer!.isActive) _delayTimer!.cancel();
          alarmTime.value = 'No upcoming alarms!';
          debugPrint('Set display to: No upcoming alarms!');
        }
        
        debugPrint('Alarm refresh completed successfully');
      } catch (e) {
        debugPrint('Error in refreshUpcomingAlarms: $e');
      } finally {
        isRefreshing = false;
      }
    });
  }

  // Helper method to schedule an alarm if needed
  Future<void> scheduleAlarmIfNeeded(AlarmModel alarm, bool isShared) async {
    if (!alarm.isEnabled) {
      debugPrint('Alarm is disabled, not scheduling: ${alarm.alarmTime}');
      return;
    }
    
    // Note: Dismissal check is now handled at the higher level in refreshUpcomingAlarms()
    // to avoid duplicate checks and improve performance
    
    // Calculate time to alarm
    TimeOfDay alarmTimeOfDay = Utils.stringToTimeOfDay(alarm.alarmTime);
    int intervalToAlarm = Utils.getMillisecondsToAlarm(
      DateTime.now(),
      Utils.timeOfDayToDateTime(alarmTimeOfDay),
      );
    
    if (intervalToAlarm <= 0) {
      debugPrint('Alarm time is in the past, not scheduling: ${alarm.alarmTime}');
      return;
    }
    
    String alarmId = isShared ? (alarm.firestoreId ?? '') : alarm.alarmID.toString();
    
    // Check if this same alarm is already scheduled WITH THE SAME TIME
    bool alreadyScheduled = false;
    if (isShared) {
      alreadyScheduled = lastScheduledAlarmIsShared == true && 
                        lastScheduledAlarmId == alarmId &&
                        lastScheduledAlarmTime?.hour == alarmTimeOfDay.hour &&
                        lastScheduledAlarmTime?.minute == alarmTimeOfDay.minute;
    } else {
      alreadyScheduled = lastScheduledLocalAlarmId == alarmId &&
                        lastScheduledLocalAlarmTime?.hour == alarmTimeOfDay.hour &&
                        lastScheduledLocalAlarmTime?.minute == alarmTimeOfDay.minute;
    }
    
    if (alreadyScheduled) {
      debugPrint('${isShared ? "Shared" : "Local"} alarm already scheduled with same time, skipping: ${alarm.alarmTime}');
      return;
    }
    
    // If we reach here, either it's a new alarm or the time has changed, so schedule it
    try {
      debugPrint('Scheduling ${isShared ? "shared" : "local"} alarm: ${alarm.alarmTime}, id: $alarmId');
      
      // Schedule the alarm via native code
      await alarmChannel.invokeMethod('scheduleAlarm', {
        'isSharedAlarm': isShared,
        'isActivityEnabled': alarm.isActivityEnabled,
        'isLocationEnabled': alarm.isLocationEnabled,
        'isWeatherEnabled': alarm.isWeatherEnabled,
        'intervalToAlarm': intervalToAlarm,
        'location': alarm.location,
        'weatherTypes': jsonEncode(alarm.weatherTypes),
        'alarmID': alarmId,
      });
      
      // Track each alarm type separately - never override the other type
      if (isShared) {
      lastScheduledAlarmId = alarmId;
        lastScheduledAlarmTime = alarmTimeOfDay;
        lastScheduledAlarmIsShared = true;
        debugPrint('Updated shared alarm tracking: $alarmId at ${alarm.alarmTime}');
      } else {
        lastScheduledLocalAlarmId = alarmId;
        lastScheduledLocalAlarmTime = alarmTimeOfDay;
        debugPrint('Updated local alarm tracking: $alarmId at ${alarm.alarmTime}');
      }
      
      debugPrint('✅ Scheduled ${isShared ? "shared" : "local"} alarm successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling ${isShared ? "shared" : "local"} alarm: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
    _dismissedAlarmsCleanupTimer?.cancel();
    _preventReschedulingTimer?.cancel();
    if (delayToSchedule != null) {
      delayToSchedule!.cancel();
    }
    _sharedAlarmSubscription.cancel();
  }

  Future<void> fetchGoogleCalendars() async {
    Calendars.value = (await GoogleCloudProvider.getCalenders()) ?? [];
    if (Calendars.value == []) {
      calendarFetchStatus.value = 'Empty';
    } else {
      calendarFetchStatus.value = 'Loaded';
    }
  }

  Future<void> fetchEvents(String calenderId) async {
    Events.value = await GoogleCloudProvider.getEvents(calenderId) ?? [];
    if (Events.value == []) {
      calendarFetchStatus.value = 'Empty';
      Get.snackbar('Events', 'No events available');
    } else {
      calendarFetchStatus.value = 'Loaded';
      isCalender.value = false;
    }
    print(Events.value);
  }

  Future<void> setAlarmFromEvent(CalendarApi.Event event, String date) async {
    AlarmModel alarmModel = genFakeAlarmModel();
    alarmModel.alarmTime = Utils.formatDateTimeToHHMMSS(
      event.start?.dateTime?.toLocal() ?? event.start!.date!.toLocal(),
    );
    alarmModel.isEnabled = true;
    alarmModel.intervalToAlarm = Utils.calculateTimeDifference(
      event.start?.dateTime ?? event.start!.date!,
    );
    alarmModel.ringOn = true;

    alarmModel.label = event.summary!;
    alarmModel.isOneTime = true;
    isProfile.value = false;
    Get.toNamed(
      '/add-update-alarm',
      arguments: alarmModel,
    );
  }

  // Add all alarms to seleted alarm set
  void addAllAlarmsToSelectedAlarmSet() {
    for (int index = 0; index < alarmListPairs.first.length; index++) {
      AlarmModel alarm = alarmListPairs.first[index];
      alarmListPairs.second[index].value = true;
      selectedAlarmSet.add(
        alarm.isSharedAlarmEnabled
            ? Pair(
                alarm.firestoreId,
                true,
              )
            : Pair(
                alarm.isarId,
                false,
              ),
      );
    }
  }

  // Remove all alarms from the selected alarm set
  void removeAllAlarmsFromSelectedAlarmSet() {
    for (int index = 0; index < alarmListPairs.first.length; index++) {
      alarmListPairs.second[index].value = false;
      selectedAlarmSet.clear();
    }
  }

  // Delete alarms mentioned in the selected alarm set
  Future<void> deleteAlarms() async {
    try {
      if (selectedAlarmSet.isEmpty) {
        Get.snackbar(
          'Error',
          'No alarms selected for deletion',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      int successCount = 0;
      List<AlarmModel> deletedAlarms = [];

      for (var alarm in selectedAlarmSet) {
        var alarmId = alarm.first;
        var isSharedAlarmEnabled = alarm.second;

        try {
          if (isSharedAlarmEnabled) {
            
            AlarmModel? alarmToDelete = await FirestoreDb.getAlarm(userModel.value, alarmId);
            if (alarmToDelete != null) {
              deletedAlarms.add(alarmToDelete);
              
              // Cancel the native Android alarm BEFORE deleting from database
              try {
                await alarmChannel.invokeMethod('cancelAlarmById', {
                  'alarmID': alarmId,
                  'isSharedAlarm': true,
                });
                debugPrint('🗑️ Canceled native shared alarm before deletion: $alarmId');
              } catch (e) {
                debugPrint('⚠️ Error canceling native shared alarm: $e');
              }
              
              await FirestoreDb.deleteAlarm(userModel.value, alarmId);
              successCount++;
            }
          } else {
            
            AlarmModel? alarmToDelete = await IsarDb.getAlarm(alarmId);
            if (alarmToDelete != null) {
              deletedAlarms.add(alarmToDelete);
              
              // Cancel the native Android alarm BEFORE deleting from database
              try {
                await alarmChannel.invokeMethod('cancelAlarmById', {
                  'alarmID': alarmToDelete.alarmID,
                  'isSharedAlarm': false,
                });
                debugPrint('🗑️ Canceled native local alarm before deletion: ${alarmToDelete.alarmID}');
              } catch (e) {
                debugPrint('⚠️ Error canceling native local alarm: $e');
              }
              
              await IsarDb.deleteAlarm(alarmId);
              successCount++;
            }
          }
        } catch (e) {
          debugPrint('Error deleting alarm: $e');
          continue;
        }
      }

      if (successCount > 0) {
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }

        Get.snackbar(
          'Success',
          '$successCount ${successCount == 1 ? 'alarm' : 'alarms'} deleted',
          duration: Duration(seconds: duration.toInt()),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 15,
          ),
          mainButton: TextButton(
            onPressed: () async {
              
              for (var alarm in deletedAlarms) {
                if (alarm.isSharedAlarmEnabled) {
                  await FirestoreDb.addAlarm(userModel.value, alarm);
                } else {
                  await IsarDb.addAlarm(alarm);
                }
              }
              
              refreshTimer = true;
              refreshUpcomingAlarms();
            },
            child: Text(
              'Undo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        
        selectedAlarmSet.clear();
        numberOfAlarmsSelected.value = 0;
      } else {
        Get.snackbar(
          'Error',
          'No alarms were deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error in deleteAlarms: $e');
      Get.snackbar(
        'Error',
        'Failed to delete alarms',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> swipeToDeleteAlarm(UserModel? user, AlarmModel alarm) async {
    AlarmModel? alarmToDelete;

    if (alarm.isSharedAlarmEnabled == true) {
      alarmToDelete = await FirestoreDb.getAlarm(user, alarm.firestoreId!);
      
      // Cancel the native Android alarm BEFORE deleting from database
      try {
        await alarmChannel.invokeMethod('cancelAlarmById', {
          'alarmID': alarm.firestoreId!,
          'isSharedAlarm': true,
        });
        debugPrint('🗑️ Canceled native shared alarm before deletion: ${alarm.firestoreId}');
      } catch (e) {
        debugPrint('⚠️ Error canceling native shared alarm: $e');
      }
      
      await FirestoreDb.deleteAlarm(user, alarm.firestoreId!);
    } else {
      alarmToDelete = await IsarDb.getAlarm(alarm.isarId);
      
      // Cancel the native Android alarm BEFORE deleting from database
      try {
        await alarmChannel.invokeMethod('cancelAlarmById', {
          'alarmID': alarm.alarmID,
          'isSharedAlarm': false,
        });
        debugPrint('🗑️ Canceled native local alarm before deletion: ${alarm.alarmID}');
      } catch (e) {
        debugPrint('⚠️ Error canceling native local alarm: $e');
      }
      
      await IsarDb.deleteAlarm(alarm.isarId);
    }

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.snackbar(
      'Alarm deleted',
      'The alarm has been deleted.',
      duration: Duration(seconds: duration.toInt()),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      mainButton: TextButton(
        onPressed: () async {
          if (alarm.isSharedAlarmEnabled == true) {
            await FirestoreDb.addAlarm(user, alarmToDelete!);
          } else {
            await IsarDb.addAlarm(alarmToDelete!);
          }
        },
        child: Text('Undo'.tr),
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) async {
    Get.defaultDialog(
      titlePadding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      backgroundColor: themeController.secondaryBackgroundColor.value,
      title: 'Are you sure you want to delete these alarms?'.tr,
      titleStyle: Theme.of(context).textTheme.displaySmall,
      content: Column(
        children: [
          Text(
            'This action will permanently delete these alarms from your device.'
                .tr,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(kprimaryColor),
                  ),
                  child: Text(
                    'Cancel'.tr,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: kprimaryBackgroundColor,
                        ),
                  ),
                ),
                Obx(
                  () => OutlinedButton(
                    onPressed: () async {
                      await deleteAlarms();

                      // Closing the multiple select mode
                      inMultipleSelectMode.value = false;
                      isAnyAlarmHolded.value = false;
                      isAllAlarmsSelected.value = false;

                      numberOfAlarmsSelected.value = 0;
                      selectedAlarmSet.clear();
                      // After deleting alarms, refreshing to schedule latest one
                      refreshTimer = true;
                      refreshUpcomingAlarms();

                      Get.offNamedUntil(
                        '/bottom-navigation-bar',
                        (route) => route.settings.name == '/splash-screen',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Okay'.tr,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getCurrentProfileModel() async {
    profileModel.value = (await IsarDb.getProfile(selectedProfile.value))!;
  }

  AlarmModel genFakeAlarmModel() {
    return AlarmModel(
        volMax: profileModel.value.volMax,
        volMin: profileModel.value.volMin,
        snoozeDuration: profileModel.value.snoozeDuration,
        gradient: profileModel.value.gradient,
        label: profileModel.value.label,
        isOneTime: profileModel.value.isOneTime,
        deleteAfterGoesOff: profileModel.value.deleteAfterGoesOff,
        offsetDetails: profileModel.value.offsetDetails,
        mainAlarmTime: Utils.timeOfDayToString(TimeOfDay.now()),
        lastEditedUserId: profileModel.value.lastEditedUserId,
        mutexLock: profileModel.value.mutexLock,
        ownerName: profileModel.value.ownerName,
        ownerId: profileModel.value.ownerId,
        alarmID: '',
        activityInterval: profileModel.value.activityInterval,
        isMathsEnabled: profileModel.value.isMathsEnabled,
        numMathsQuestions: profileModel.value.numMathsQuestions,
        mathsDifficulty: profileModel.value.mathsDifficulty,
        qrValue: profileModel.value.qrValue,
        isQrEnabled: profileModel.value.isQrEnabled,
        isShakeEnabled: profileModel.value.isShakeEnabled,
        shakeTimes: profileModel.value.shakeTimes,
        isPedometerEnabled: profileModel.value.isPedometerEnabled,
        numberOfSteps: profileModel.value.numberOfSteps,
        days: profileModel.value.days,
        weatherTypes: profileModel.value.weatherTypes,
        isWeatherEnabled: profileModel.value.isWeatherEnabled,
        isEnabled: profileModel.value.isEnabled,
        isActivityEnabled: profileModel.value.isActivityEnabled,
        isLocationEnabled: profileModel.value.isLocationEnabled,
        isSharedAlarmEnabled: profileModel.value.isSharedAlarmEnabled,
        intervalToAlarm: 0,
        location: profileModel.value.location,
        alarmTime: Utils.timeOfDayToString(TimeOfDay.now()),
        minutesSinceMidnight: Utils.timeOfDayToInt(TimeOfDay.now()),
        ringtoneName: profileModel.value.ringtoneName,
        note: profileModel.value.note,
        showMotivationalQuote: profileModel.value.showMotivationalQuote,
        activityMonitor: profileModel.value.activityMonitor,
        alarmDate: profileModel.value.alarmDate,
        profile: profileModel.value.profileName,
        isGuardian: profileModel.value.isGuardian,
        guardianTimer: profileModel.value.guardianTimer,
        guardian: profileModel.value.guardian,
        isCall: profileModel.value.isCall,
        ringOn: false);
  }

  // Method to clear the last scheduled alarm tracking data
  Future<void> clearLastScheduledAlarm() async {
    // Check if we have a valid alarm type flag
    if (lastScheduledAlarmIsShared == null) {
      debugPrint('⚠️ Warning: lastScheduledAlarmIsShared is null, defaulting to false');
      lastScheduledAlarmIsShared = false;
    }
    
    bool isShared = lastScheduledAlarmIsShared ?? false;
    debugPrint('🔔 Clearing ${isShared ? "SHARED" : "LOCAL"} alarm');
    
    // Use the cancelSpecificAlarm method in our native channel
    // This will only cancel the specific alarm type (shared or local) that rang
    // without canceling other scheduled alarms
    await alarmChannel.invokeMethod('cancelSpecificAlarm', {
      'isSharedAlarm': isShared,
    });
    
    // Only clear tracking for the specific type of alarm
    if (isShared) {
    lastScheduledAlarmId = null;
    lastScheduledAlarmTime = null;
    lastScheduledAlarmIsShared = null;
      debugPrint('🔔 Cleared last scheduled shared alarm');
    } else {
      lastScheduledLocalAlarmId = null;
      lastScheduledLocalAlarmTime = null;
      debugPrint('🔔 Cleared last scheduled local alarm');
    }
  }
  
  // Method to clear alarm tracking for a specific alarm being updated
  void clearAlarmTracking(String alarmId, bool isShared) {
    if (isShared) {
      if (lastScheduledAlarmId == alarmId) {
        lastScheduledAlarmId = null;
        lastScheduledAlarmTime = null;
        lastScheduledAlarmIsShared = null;
        debugPrint('🔄 Cleared shared alarm tracking for update: $alarmId');
      }
    } else {
      if (lastScheduledLocalAlarmId == alarmId) {
        lastScheduledLocalAlarmId = null;
        lastScheduledLocalAlarmTime = null;
        debugPrint('🔄 Cleared local alarm tracking for update: $alarmId');
      }
    }
  }
  
  // Method to clear all alarm prevention and tracking
  Future<void> clearAllAlarmTracking() async {
    // For complete cancellation, use the cancelAllAlarms method
    await alarmChannel.invokeMethod('cancelAllAlarms');
    
    // Clear all tracking variables
    lastScheduledAlarmId = null;
    lastScheduledAlarmTime = null;
    lastScheduledAlarmIsShared = null;
    lastScheduledLocalAlarmId = null;
    lastScheduledLocalAlarmTime = null;
    
    lastDismissedSharedAlarmId = null;
    lastDismissedSharedAlarmTime = null;
    preventSharedAlarmRescheduling = false;
    _preventReschedulingTimer?.cancel();
    debugPrint('🔔 Cleared all alarms and tracking data');
  }

  // Method to temporarily prevent shared alarm scheduling (used after dismissal)
  void temporarilyPreventSharedAlarmRescheduling() {
    preventSharedAlarmRescheduling = true;
    // Cancel any existing timer
    _preventReschedulingTimer?.cancel();
    // Reset the flag after 5 seconds to allow scheduling again
    _preventReschedulingTimer = Timer(const Duration(seconds: 5), () {
      preventSharedAlarmRescheduling = false;
      debugPrint('Shared alarm scheduling prevention cleared');
    });
    debugPrint('Temporarily prevented shared alarm rescheduling');
  }

  // Method to block a specific shared alarm from being rescheduled
  void blockSharedAlarmRescheduling(String? firestoreId, String alarmTime) {
    if (firestoreId == null) return;
    
    // Add the alarm ID to the blocked set
    recentlyDismissedAlarmIds.add(firestoreId);
    debugPrint('Blocked rescheduling of shared alarm: $alarmTime, ID: $firestoreId');
    
    // Cancel any existing cleanup timer
    _dismissedAlarmsCleanupTimer?.cancel();
    
    // Clear the blocked list after 10 seconds to prevent memory leaks
    // and allow rescheduling in the future if needed
    _dismissedAlarmsCleanupTimer = Timer(const Duration(seconds: 10), () {
      recentlyDismissedAlarmIds.clear();
      debugPrint('Cleared blocked shared alarm IDs list');
    });
  }
  
  // Method to check if an alarm is in the blocked list
  bool isBlockedSharedAlarm(String? firestoreId) {
    if (firestoreId == null) return false;
    return recentlyDismissedAlarmIds.contains(firestoreId);
  }

  // Force a refresh of alarm schedules
  void forceRefreshAlarms() {
    refreshTimer = true;
    refreshUpcomingAlarms();
  }
  
  // Force refresh alarms after an alarm update, clearing tracking first
  void forceRefreshAfterAlarmUpdate(String? alarmId, bool isShared) {
    debugPrint('🔄 Force refreshing alarms after ${isShared ? "shared" : "local"} alarm update: $alarmId');
    
    // Clear tracking for this specific alarm so it will be rescheduled
    if (alarmId != null) {
      clearAlarmTracking(alarmId, isShared);
    }
    
    // Force a complete refresh
    refreshTimer = true;
    refreshUpcomingAlarms();
  }

  /// Sets up periodic checks for shared alarm updates (every 30 seconds when app is active)
  void setupPeriodicSharedAlarmCheck() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        if (userModel.value != null) {
          // Silently check for shared alarm updates
          await forceRefreshSharedAlarms();
        }
      } catch (e) {
        debugPrint('Error in periodic shared alarm check: $e');
      }
    });
  }

  /// Shows a notification when a shared alarm is updated by another user
  void showSharedAlarmUpdateNotification(String alarmTime, String ownerName) {
    try {
      // Show a snackbar notification for immediate user feedback
      Get.snackbar(
        'Shared Alarm Updated! 🔔',
        '$ownerName updated the alarm time to $alarmTime',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blueAccent.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(
          Icons.alarm,
          color: Colors.white,
          size: 30,
        ),
        shouldIconPulse: true,
        barBlur: 20,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack,
      );
      
      // Also send a native notification for better visibility
      try {
        alarmChannel.invokeMethod('showAlarmUpdateNotification', {
          'title': 'Shared Alarm Updated',
          'message': '$ownerName updated the alarm time to $alarmTime',
          'alarmTime': alarmTime,
        });
      } catch (e) {
        debugPrint('⚠️ Could not send native notification: $e');
      }
      
      debugPrint('🔔 Showed alarm update notification: $ownerName -> $alarmTime');
    } catch (e) {
      debugPrint('❌ Error showing shared alarm update notification: $e');
    }
  }

  /// Sets up a listener for user notifications (works as backup when push notifications fail)
  void setupUserNotificationListener() {
    if (userModel.value == null) return;
    
    debugPrint('🔔 Setting up user notification listener...');
    
    FirebaseFirestore.instance
        .collection('userNotifications')
        .doc(userModel.value!.id)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .where('type', isEqualTo: 'alarm_update')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      
      for (DocumentChange change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          try {
            Map<String, dynamic> notificationData = change.doc.data() as Map<String, dynamic>;
            
            String title = notificationData['title'] ?? 'Alarm Updated';
            String message = notificationData['message'] ?? 'Your shared alarm has been updated';
            String alarmId = notificationData['alarmId'] ?? '';
            String newAlarmTime = notificationData['newAlarmTime'] ?? '';
            String ownerName = notificationData['ownerName'] ?? 'Someone';
            
            debugPrint('📬 Received Firestore notification: $title');
            
            // Show the notification to the user
            showSharedAlarmUpdateNotification(newAlarmTime, ownerName);
            
            // Mark the notification as read
            change.doc.reference.update({'read': true});
            
            // Trigger a shared alarm refresh to apply the update
            if (alarmId.isNotEmpty) {
              debugPrint('🔄 Triggering alarm refresh due to notification');
              forceRefreshSharedAlarms();
            }
            
          } catch (e) {
            debugPrint('❌ Error processing user notification: $e');
          }
        }
      }
    }, onError: (error) {
      debugPrint('❌ Error in user notification listener: $error');
    });
  }

  // Add method to handle shared alarm firing state
  Future<void> handleSharedAlarmFiring() async {
    try {
      debugPrint('🔔 Shared alarm is firing, preventing immediate Firestore refresh');
      
      // Wait 10 seconds before refreshing to allow alarm to ring properly
      await Future.delayed(Duration(seconds: 10));
      
      debugPrint('🔄 Delayed refresh after shared alarm fired');
      await forceRefreshSharedAlarms();
    } catch (e) {
      debugPrint('❌ Error handling shared alarm firing: $e');
    }
  }
}