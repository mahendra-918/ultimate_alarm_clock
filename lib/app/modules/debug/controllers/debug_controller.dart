import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'dart:async';
import '../../../data/providers/isar_provider.dart';
import '../../../modules/settings/controllers/theme_controller.dart';
import '../../../utils/utils.dart';
import '../../../utils/constants.dart';
import '../../../data/models/debug_model.dart';
import 'package:intl/intl.dart';

class DebugController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final TextEditingController searchController = TextEditingController();
  
  var logs = <Map<String, dynamic>>[].obs;
  var filteredLogs = <Map<String, dynamic>>[].obs;
  var selectedLogLevel = Rxn<LogLevel>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  RxBool isDevMode = false.obs;
  
  Timer? _timer;

  // Add this new property for tab selection
  final tabIndex = 0.obs;

  // Insights properties
  final isInsightsLoading = true.obs;
  final totalAlarmsCreated = 0.obs;
  final totalAlarmsTriggered = 0.obs;
  final totalAlarmsSkipped = 0.obs;
  final earlyMorningWakeups = 0.obs; // Before 7 AM
  final lateMorningWakeups = 0.obs;  // 7 AM - 11 AM
  final afternoonWakeups = 0.obs;    // After 11 AM
  final commonWakeupDays = <String, int>{}.obs;
  final averageSnoozeTime = 0.obs;
  final mostUsedFeatures = <String, int>{}.obs;
  final mostSuccessfulFeatures = <String, int>{}.obs;
  final isShowingInsights = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchLogs();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void toggleDevMode() {
    isDevMode.value = !isDevMode.value;
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final fetchedLogs = await IsarDb().getLogs();
      logs.value = fetchedLogs.reversed.toList();
      applyFilters();
      generateInsights();
      debugPrint('Debug screen: Successfully loaded ${fetchedLogs.length} logs');
    } catch (e) {
      debugPrint('Debug screen: Error loading logs: $e');
      Get.snackbar(
        'Error',
        'Error loading logs: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void applyFilters() {
    filteredLogs.value = logs.where((log) {
      // Log the alarm-related entries with their IDs
      if (log['Message'].toString().toLowerCase().contains('alarm')) {
        debugPrint('Found alarm log: "${log['Message']}" with AlarmID: "${log['AlarmID']}"');
      }
      
      bool matchesSearch = searchController.text.isEmpty ||
          log['Status'].toString().toLowerCase().contains(searchController.text.toLowerCase()) ||
          log['LogID'].toString().contains(searchController.text) ||
          Utils.getFormattedDate(DateTime.fromMillisecondsSinceEpoch(log['LogTime']))
              .toLowerCase()
              .contains(searchController.text.toLowerCase());
      
      // Add category filtering based on tabIndex
      bool matchesCategory = true;
      if (tabIndex.value > 0) {
        final message = log['Message'].toString().toLowerCase();
        final hasRung = log['HasRung'] ?? 0;
        
        switch (tabIndex.value) {
          case 1: // Triggered
            matchesCategory = message.contains('alarm triggered') || 
                              message.contains('alarm ringing') || 
                              message.contains('triggered alarm') || 
                              hasRung == 1;
            break;
          case 2: // Skipped
            matchesCategory = message.contains('alarm didn\'t ring') || 
                              message.contains('skipped') || 
                              message.contains('missed');
            break;
          case 3: // Condition
            matchesCategory = message.contains('weather') || 
                              message.contains('location') || 
                              message.contains('condition');
            break;
        }
      }
      
      return matchesSearch && matchesCategory;
    }).toList();
    
    debugPrint('Total logs: ${logs.length}');
    debugPrint('Filtered logs: ${filteredLogs.length}');
    if (filteredLogs.isEmpty) {
      debugPrint('First few log statuses:');
      for (var i = 0; i < logs.length && i < 5; i++) {
        debugPrint('Log ${i + 1}: "${logs[i]['Status']}"');
      }
    }
  }

  Future<void> clearLogs() async {
    try {
      await IsarDb().clearLogs();
      logs.value = [];
      filteredLogs.value = [];
      Get.snackbar(
        'Success',
        'Logs cleared successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error clearing logs: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: startDate.value ?? DateTime.now().subtract(const Duration(days: 7)),
        end: endDate.value ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kprimaryColor,
              onPrimary: Colors.white,
              surface: themeController.secondaryBackgroundColor.value,
              onSurface: themeController.primaryTextColor.value,
              background: themeController.primaryBackgroundColor.value,
              onBackground: themeController.primaryTextColor.value,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kprimaryColor,
              ),
            ),
            dialogBackgroundColor: themeController.secondaryBackgroundColor.value,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      applyFilters();
    }
  }

  Color getLogLevelColor(String status) {
    status = status.toLowerCase();
    if (status.contains('error')) return Colors.red;
    if (status.contains('warning')) return Colors.orange;
    return Colors.green;
  }
  
  Future<Map<String, dynamic>?> getAlarmDetails(String alarmID) async {
    if (alarmID == null || alarmID.isEmpty) {
      debugPrint('getAlarmDetails: alarmID is null or empty');
      return null;
    }
    
    debugPrint('getAlarmDetails: Attempting to retrieve details for alarm ID: $alarmID');
    
    try {
      final db = await IsarDb().getAlarmSQLiteDatabase();
      if (db == null) {
        debugPrint('getAlarmDetails: Failed to initialize database for alarms');
        return null;
      }
      
      debugPrint('getAlarmDetails: Database initialized successfully');
      
      final alarmData = await db.query(
        'alarms',
        where: 'alarmID = ?',
        whereArgs: [alarmID],
      );
      
      debugPrint('getAlarmDetails: Query executed, results count: ${alarmData.length}');
      
      if (alarmData.isNotEmpty) {
        debugPrint('getAlarmDetails: Found alarm with ID: $alarmID');
        // Print fields for debugging
        final keys = alarmData.first.keys.toList();
        debugPrint('getAlarmDetails: Available fields: $keys');
        return alarmData.first;
      } else {
        debugPrint('getAlarmDetails: No alarm found with ID: $alarmID');
        return null;
      }
    } catch (e) {
      debugPrint('getAlarmDetails: Error retrieving alarm details: $e');
      return null;
    }
  }
  
  String getDaysText(List<bool> days) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> activeDays = [];
    
    for (int i = 0; i < days.length && i < dayNames.length; i++) {
      if (days[i]) {
        activeDays.add(dayNames[i]);
      }
    }
    
    if (activeDays.isEmpty) {
      return 'One-time';
    } else if (activeDays.length == 7) {
      return 'Every day';
    } else if (activeDays.length == 5 && !days[5] && !days[6]) {
      return 'Weekdays';
    } else if (activeDays.length == 2 && days[5] && days[6]) {
      return 'Weekends';
    } else {
      return activeDays.join(', ');
    }
  }

  Future<Map<String, dynamic>?> getAlarmDetailsByTime(String timeString) async {
    if (timeString.isEmpty) {
      debugPrint('getAlarmDetailsByTime: time string is empty');
      return null;
    }
    
    debugPrint('getAlarmDetailsByTime: Attempting to retrieve details for alarm time: $timeString');
    
    try {
      final db = await IsarDb().getAlarmSQLiteDatabase();
      if (db == null) {
        debugPrint('getAlarmDetailsByTime: Failed to initialize database for alarms');
        return null;
      }
      
      // First try exact match
      var alarmData = await db.query(
        'alarms',
        where: 'alarmTime = ?',
        whereArgs: [timeString],
      );
      
      // If no exact match, try different time formats
      if (alarmData.isEmpty) {
        // If time format is "1:30 PM", try also "01:30 PM"
        final timeRegex = RegExp(r'^(\d):(\d{2}(?:\s?[AP]M)?)$');
        final timeMatch = timeRegex.firstMatch(timeString);
        if (timeMatch != null && timeMatch.groupCount >= 2) {
          final hour = timeMatch.group(1);
          final rest = timeMatch.group(2);
          final paddedTime = '0$hour:$rest';
          
          debugPrint('getAlarmDetailsByTime: Trying alternate format: $paddedTime');
          alarmData = await db.query(
            'alarms',
            where: 'alarmTime = ?',
            whereArgs: [paddedTime],
          );
        }
      }
      
      // If still no match, try LIKE query
      if (alarmData.isEmpty) {
        // Extract just the hour and minute
        final basicTimeRegex = RegExp(r'(\d{1,2}):(\d{2})');
        final basicMatch = basicTimeRegex.firstMatch(timeString);
        if (basicMatch != null && basicMatch.groupCount >= 2) {
          final hour = basicMatch.group(1);
          final minute = basicMatch.group(2);
          final partialTime = '$hour:$minute';
          
          debugPrint('getAlarmDetailsByTime: Trying partial time: $partialTime');
          alarmData = await db.query(
            'alarms',
            where: 'alarmTime LIKE ?',
            whereArgs: ['%$partialTime%'],
          );
        }
      }
      
      debugPrint('getAlarmDetailsByTime: Query executed, results count: ${alarmData.length}');
      
      if (alarmData.isNotEmpty) {
        debugPrint('getAlarmDetailsByTime: Found alarm with time: $timeString');
        return alarmData.first;
      } else {
        debugPrint('getAlarmDetailsByTime: No alarm found with time: $timeString');
        return null;
      }
    } catch (e) {
      debugPrint('getAlarmDetailsByTime: Error retrieving alarm details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMostRecentAlarm() async {
    debugPrint('getMostRecentAlarm: Attempting to retrieve most recent alarm');
    
    try {
      final db = await IsarDb().getAlarmSQLiteDatabase();
      if (db == null) {
        debugPrint('getMostRecentAlarm: Failed to initialize database for alarms');
        return null;
      }
      
      // Get all alarms ordered by their ID (assuming higher ID = more recent)
      final alarmData = await db.query(
        'alarms',
        orderBy: 'rowid DESC',
        limit: 1
      );
      
      debugPrint('getMostRecentAlarm: Query executed, results count: ${alarmData.length}');
      
      if (alarmData.isNotEmpty) {
        debugPrint('getMostRecentAlarm: Found most recent alarm');
        return alarmData.first;
      } else {
        debugPrint('getMostRecentAlarm: No alarms found');
        return null;
      }
    } catch (e) {
      debugPrint('getMostRecentAlarm: Error retrieving alarm details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEnabledAlarms() async {
    debugPrint('getEnabledAlarms: Attempting to retrieve enabled alarms');
    
    try {
      final db = await IsarDb().getAlarmSQLiteDatabase();
      if (db == null) {
        debugPrint('getEnabledAlarms: Failed to initialize database for alarms');
        return null;
      }
      
      // Get all enabled alarms
      final alarmData = await db.query(
        'alarms',
        where: 'isEnabled = ?',
        whereArgs: [1], // 1 = true in SQLite
        orderBy: 'rowid DESC',
        limit: 1
      );
      
      debugPrint('getEnabledAlarms: Query executed, results count: ${alarmData.length}');
      
      if (alarmData.isNotEmpty) {
        debugPrint('getEnabledAlarms: Found enabled alarm');
        return alarmData.first;
      } else {
        debugPrint('getEnabledAlarms: No enabled alarms found');
        return null;
      }
    } catch (e) {
      debugPrint('getEnabledAlarms: Error retrieving alarm details: $e');
      return null;
    }
  }

  // Add this method to change the tab and filter logs
  void changeTab(int index) {
    tabIndex.value = index;
    applyFilters();
  }

  // New method to generate insights from logs
  void generateInsights() async {
    isInsightsLoading.value = true;
    try {
      // Reset all counters
      totalAlarmsCreated.value = 0;
      totalAlarmsTriggered.value = 0;
      totalAlarmsSkipped.value = 0;
      earlyMorningWakeups.value = 0;
      lateMorningWakeups.value = 0;
      afternoonWakeups.value = 0;
      commonWakeupDays.clear();
      averageSnoozeTime.value = 0;
      mostUsedFeatures.clear();
      mostSuccessfulFeatures.clear();
      
      // Start analyzing all logs
      for (final log in logs) {
        final message = log['Message'].toString().toLowerCase();
        final logTime = DateTime.fromMillisecondsSinceEpoch(log['LogTime']);
        final hasRung = log['HasRung'] ?? 0;
        final weekday = DateFormat('EEEE').format(logTime); // Full weekday name
        
        // Count creations, triggers, and skips
        if (message.contains('alarm created')) {
          totalAlarmsCreated.value++;
        }
        
        if (message.contains('alarm triggered') || 
            message.contains('alarm ringing') || 
            hasRung == 1) {
          totalAlarmsTriggered.value++;
          
          // Analyze time of day when alarms ring
          final hour = logTime.hour;
          if (hour < 7) {
            earlyMorningWakeups.value++;
          } else if (hour < 11) {
            lateMorningWakeups.value++;
          } else {
            afternoonWakeups.value++;
          }
          
          // Track which days the user wakes up most
          commonWakeupDays[weekday] = (commonWakeupDays[weekday] ?? 0) + 1;
        }
        
        if (message.contains('alarm didn\'t ring') || 
            message.contains('skipped') || 
            message.contains('missed')) {
          totalAlarmsSkipped.value++;
        }
        
        // Analyze features usage and success
        if (message.contains('weather') && message.contains('enabled')) {
          mostUsedFeatures['Weather'] = (mostUsedFeatures['Weather'] ?? 0) + 1;
          if (message.contains('success')) {
            mostSuccessfulFeatures['Weather'] = (mostSuccessfulFeatures['Weather'] ?? 0) + 1;
          }
        }
        
        if (message.contains('math') && message.contains('enabled')) {
          mostUsedFeatures['Math Problems'] = (mostUsedFeatures['Math Problems'] ?? 0) + 1;
          if (message.contains('success')) {
            mostSuccessfulFeatures['Math Problems'] = (mostSuccessfulFeatures['Math Problems'] ?? 0) + 1;
          }
        }
        
        if (message.contains('shake') && message.contains('enabled')) {
          mostUsedFeatures['Shake'] = (mostUsedFeatures['Shake'] ?? 0) + 1;
          if (message.contains('success')) {
            mostSuccessfulFeatures['Shake'] = (mostSuccessfulFeatures['Shake'] ?? 0) + 1;
          }
        }
        
        if (message.contains('qr') && message.contains('enabled')) {
          mostUsedFeatures['QR Code'] = (mostUsedFeatures['QR Code'] ?? 0) + 1;
          if (message.contains('success')) {
            mostSuccessfulFeatures['QR Code'] = (mostSuccessfulFeatures['QR Code'] ?? 0) + 1;
          }
        }
        
        if (message.contains('pedometer') && message.contains('enabled')) {
          mostUsedFeatures['Pedometer'] = (mostUsedFeatures['Pedometer'] ?? 0) + 1;
          if (message.contains('success')) {
            mostSuccessfulFeatures['Pedometer'] = (mostUsedFeatures['Pedometer'] ?? 0) + 1;
          }
        }
        
        if (message.contains('location') && message.contains('enabled')) {
          mostUsedFeatures['Location'] = (mostUsedFeatures['Location'] ?? 0) + 1;
          if (message.contains('success')) {
            mostSuccessfulFeatures['Location'] = (mostUsedFeatures['Location'] ?? 0) + 1;
          }
        }
        
        // Analyze snooze behavior
        if (message.contains('snoozed')) {
          // Try to extract snooze duration from logs if available
          final snoozeDurationMatch = RegExp(r'for (\d+) minutes').firstMatch(message);
          if (snoozeDurationMatch != null && snoozeDurationMatch.groupCount >= 1) {
            final minutes = int.tryParse(snoozeDurationMatch.group(1) ?? '0') ?? 0;
            averageSnoozeTime.value = (averageSnoozeTime.value + minutes) ~/ 2; // Simple averaging
          }
        }
      }
      
      // Sort features by usage count
      final sortedFeatures = mostUsedFeatures.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      mostUsedFeatures.clear();
      for (var entry in sortedFeatures) {
        mostUsedFeatures[entry.key] = entry.value;
      }
      
    } catch (e) {
      debugPrint('Error generating insights: $e');
    } finally {
      isInsightsLoading.value = false;
    }
  }
  
  void toggleInsights() {
    isShowingInsights.value = !isShowingInsights.value;
  }

  // Get most common wakeup day
  String getMostCommonWakeupDay() {
    if (commonWakeupDays.isEmpty) {
      return 'Not enough data';
    }
    return commonWakeupDays.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  // Get most used feature
  String getMostUsedFeature() {
    if (mostUsedFeatures.isEmpty) {
      return 'Not enough data';
    }
    return mostUsedFeatures.entries.first.key;
  }
  
  // Calculate success rate for wakeups
  double getWakeupSuccessRate() {
    final total = totalAlarmsTriggered.value + totalAlarmsSkipped.value;
    if (total == 0) return 0.0;
    return (totalAlarmsTriggered.value / total) * 100;
  }
} 