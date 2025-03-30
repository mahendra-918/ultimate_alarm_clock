import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'dart:async';
import '../../../data/providers/isar_provider.dart' as isar_db;
import '../../../modules/settings/controllers/theme_controller.dart';
import '../../../modules/settings/controllers/settings_controller.dart';
import '../../../utils/utils.dart';
import '../../../utils/constants.dart';
import '../../../data/models/debug_model.dart';
import '../../../data/models/alarm_model.dart';
import '../views/alarm_details_widget.dart';
import 'dart:math' as Math;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../data/providers/stand_alone_logs.dart';

class DebugController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final SettingsController settingsController = Get.find<SettingsController>();
  final TextEditingController searchController = TextEditingController();
  
  var logs = <Map<String, dynamic>>[].obs;
  var filteredLogs = <Map<String, dynamic>>[].obs;
  var selectedLogLevel = Rxn<LogLevel>();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  RxBool isDevMode = false.obs;
  
  Timer? _timer;

  @override
  void onInit() async {
    super.onInit();
    isDevMode.value = settingsController.isDevMode.value;
    fetchLogs();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchLogs();
    });
    
    // Force immediate refresh when view appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLogs();
      debugPrint('Initial refresh of alarm history logs');
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void toggleDevMode() {
    // First update the controller's internal isDevMode value
    isDevMode.value = !isDevMode.value;
    
    // Then sync with the settings controller
    settingsController.toggleDevMode(isDevMode.value);
    
    debugPrint('Developer mode is now: ${isDevMode.value ? 'ON' : 'OFF'}');
    
    // Create a visible log indicating toggle status - will help diagnose filtering
    _createDevModeToggleLog();
    
    // Always force a complete refresh of logs when toggling dev mode
    // This ensures we get a clean slate with the current dev mode setting
    forceRefreshLogs();
    
    // Show a confirmation to the user
    Get.snackbar(
      'Dev Mode ${isDevMode.value ? 'Enabled' : 'Disabled'}',
      'Developer logs are now ${isDevMode.value ? 'visible' : 'hidden'}',
      backgroundColor: isDevMode.value ? Colors.orange : Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  // Helper to create a log that should always be visible when toggling dev mode
  Future<void> _createDevModeToggleLog() async {
    final now = DateTime.now();
    final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    try {
      final standaloneProvider = StandaloneLogsProvider();
      final db = await standaloneProvider.database;
      
      // Insert both a normal log and a dev log to test filtering
      final batch = db.batch();
      
      // Normal log - should always be visible
      batch.insert('LOGS', {
        'LogTime': now.millisecondsSinceEpoch,
        'Status': 'SUCCESS',
        'Type': 'NORMAL',
        'Message': 'DEV-MODE: Alarm Created at $formattedTime (should be ALWAYS visible)',
        'HasRung': 0,
        'AlarmID': 'dev-mode-test-${now.millisecondsSinceEpoch}',
      });
      
      // Dev log - only visible in dev mode
      batch.insert('LOGS', {
        'LogTime': now.millisecondsSinceEpoch,
        'Status': 'SUCCESS',
        'Type': 'DEV',
        'Message': 'DEV-MODE: Technical log at $formattedTime (only in dev mode)',
        'HasRung': 0,
        'AlarmID': 'dev-mode-test-${now.millisecondsSinceEpoch}',
      });
      
      await batch.commit(noResult: true);
      debugPrint('Created dev mode toggle test logs');
    } catch (e) {
      debugPrint('Error creating dev mode toggle logs: $e');
    }
  }

  // Method to update log visibility
  void updateLogsForDevMode() {
    debugPrint('Updating log visibility based on dev mode: ${isDevMode.value ? 'ON' : 'OFF'}');
    
    // Force counting how many logs would be visible before filtering
    int visibleCount = 0;
    int hiddenCount = 0;
    
    for (var log in logs) {
      if (shouldShowLog(log)) {
        visibleCount++;
      } else {
        hiddenCount++;
        final message = log['Message']?.toString() ?? 'No message';
        final status = log['Status']?.toString() ?? 'Unknown';
        final type = log['LogType']?.toString() ?? log['Type']?.toString() ?? 'Unknown';
        debugPrint('HIDDEN LOG: "$message" (Type=$type, Status=$status)');
      }
    }
    
    debugPrint('Dev mode ${isDevMode.value ? 'ON' : 'OFF'}: $visibleCount logs visible, $hiddenCount logs hidden');
    
    // Apply filters to existing logs based on current dev mode
    applyFilters();
    
    // If no logs are visible, force a refresh
    if (filteredLogs.isEmpty && logs.isNotEmpty) {
      debugPrint('No logs visible after toggling dev mode, forcing refresh');
      forceRefreshLogs();
    }
  }

  Future<void> fetchLogs() async {
    try {
      debugPrint('Debug screen: Fetching logs from both databases...');
      List<Map<String, dynamic>> isarLogs = [];
      List<Map<String, dynamic>> standaloneLogs = [];
      
      // Try to fetch from IsarDb
      try {
        isarLogs = await isar_db.IsarDb().getLogs();
        debugPrint('Successfully fetched ${isarLogs.length} logs from IsarDb');
      } catch (isarError) {
        debugPrint('Error fetching logs from IsarDb: $isarError');
      }
      
      // Also try the StandaloneLogsProvider (always try both)
      try {
        final standaloneProvider = StandaloneLogsProvider();
        final rawStandaloneLogs = await standaloneProvider.getLogs();
        
        // Process the logs to match the format expected by the UI
        standaloneLogs = rawStandaloneLogs.map((log) => {
          'LogID': log['ID'],
          'LogTime': log['LogTime'],
          'Status': log['Status'],
          'LogType': log['Type'],
          'Message': log['Message'],
          'HasRung': log['HasRung'] ?? 0,
          'AlarmID': log['AlarmID'] ?? '',
          'Source': 'standalone' // Add source for debugging
        }).toList();
        
        debugPrint('Successfully fetched ${standaloneLogs.length} logs from standalone provider');
      } catch (standaloneError) {
        debugPrint('Error fetching logs from standalone provider: $standaloneError');
      }
      
      // Add source marker to IsarDb logs for debugging
      for (var log in isarLogs) {
        log['Source'] = 'isar';
      }
      
      // Merge logs from both sources
      final mergedLogs = [...isarLogs, ...standaloneLogs];
      
      // Sort by log time (newest first)
      mergedLogs.sort((a, b) {
        final timeA = a['LogTime'] as int? ?? 0;
        final timeB = b['LogTime'] as int? ?? 0;
        return timeB.compareTo(timeA); // Descending order (newest first)
      });
      
      // Update the logs and apply filters
      logs.value = mergedLogs;
      applyFilters();
      
      debugPrint('Debug screen: Total logs loaded: ${mergedLogs.length} (${isarLogs.length} from IsarDb, ${standaloneLogs.length} from standalone)');
      
      if (mergedLogs.isEmpty) {
        debugPrint('No logs found in any database. This could indicate a problem with log creation.');
        Get.snackbar(
          'Warning',
          'No logs found. Try creating a test log.',
          backgroundColor: Colors.amber,
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Print a few logs for debugging
        int count = Math.min(5, mergedLogs.length);
        debugPrint('First $count logs:');
        for (int i = 0; i < count; i++) {
          final log = mergedLogs[i];
          final logId = log['LogID'] ?? log['ID'] ?? 'Unknown';
          final logTime = log['LogTime'] ?? DateTime.now().millisecondsSinceEpoch;
          final status = log['Status'] ?? 'Unknown';
          final logType = log['LogType'] ?? log['Type'] ?? 'Unknown';
          final message = log['Message'] ?? 'No message';
          final source = log['Source'] ?? 'unknown';
          
          debugPrint('Log ${i+1}: ID=$logId, Type=$logType, Status=$status, Source=$source, Message=$message');
        }
      }
    } catch (e) {
      debugPrint('Debug screen: Critical error loading logs: $e');
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
      // First check if this log should be shown based on dev mode
      if (!shouldShowLog(log)) {
        return false;
      }
      
      // Get values with safe fallbacks
      final status = log['Status']?.toString().toLowerCase() ?? '';
      final logMsg = log['Message']?.toString() ?? '';
      final logId = log['LogID']?.toString() ?? log['ID']?.toString() ?? '';
      final logTime = log['LogTime'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      final formattedDate = Utils.getFormattedDate(DateTime.fromMillisecondsSinceEpoch(logTime));
      
      // Search matching
      bool matchesSearch = searchController.text.isEmpty ||
          status.contains(searchController.text.toLowerCase()) ||
          logId.contains(searchController.text) ||
          logMsg.toLowerCase().contains(searchController.text.toLowerCase()) ||
          formattedDate.toLowerCase().contains(searchController.text.toLowerCase());
      
      // Log level matching
      bool matchesLevel = selectedLogLevel.value == null;
      if (selectedLogLevel.value != null) {
        // Custom logic to handle different status formats
        if (status.contains('success') || 
            status.contains('scheduled') || 
            status.contains('created') ||
            status.contains('updated') ||
            logMsg.toLowerCase().contains('scheduled') ||
            logMsg.toLowerCase().contains('created') ||
            logMsg.toLowerCase().contains('updated')) {
          matchesLevel = selectedLogLevel.value == LogLevel.info;
        } else if (status.contains('warning')) {
          matchesLevel = selectedLogLevel.value == LogLevel.warning;
        } else if (status.contains('error')) {
          matchesLevel = selectedLogLevel.value == LogLevel.error;
        } else {
          // Default to info for unknown status
          matchesLevel = selectedLogLevel.value == LogLevel.info;
        }
      }
      
      // Date range matching
      bool matchesDateRange = true;
      if (startDate.value != null && endDate.value != null) {
        final logDateTime = DateTime.fromMillisecondsSinceEpoch(logTime);
        final startOfDay = DateTime(startDate.value!.year, startDate.value!.month, startDate.value!.day);
        final endOfDay = DateTime(endDate.value!.year, endDate.value!.month, endDate.value!.day, 23, 59, 59);
        matchesDateRange = logDateTime.isAfter(startOfDay) && logDateTime.isBefore(endOfDay);
      }
      
      return matchesSearch && matchesLevel && matchesDateRange;
    }).toList();
    
    debugPrint('Total logs: ${logs.length}');
    debugPrint('Filtered logs: ${filteredLogs.length}');
    
    // Debug output to help understand what's being filtered
    final devModeStatus = isDevMode.value ? "ON" : "OFF";
    debugPrint('Dev Mode is $devModeStatus - filtered down to ${filteredLogs.length} logs');
    
    if (filteredLogs.isEmpty && logs.isNotEmpty) {
      debugPrint('First few log entries that were filtered out:');
      int count = 0;
      for (var i = 0; i < logs.length && count < 5; i++) {
        final log = logs[i];
        final status = log['Status'] ?? 'Unknown';
        final logType = log['LogType'] ?? log['Type'] ?? 'Unknown';
        final message = log['Message'] ?? 'No message';
        
        // Check if this log would be shown
        final wouldShow = shouldShowLog(log);
        if (!wouldShow) {
          debugPrint('Log ${i}: Status="$status", Type="$logType", Message="$message" - HIDDEN (dev mode: $devModeStatus)');
          count++;
        }
      }
    }
  }

  Future<void> clearLogs() async {
    try {
      debugPrint('Clearing logs from both databases...');
      bool isarSuccess = true;
      bool standaloneSuccess = true;
      
      // Try to clear IsarDb logs
      try {
        await isar_db.IsarDb().clearLogs();
        debugPrint('Successfully cleared IsarDb logs');
      } catch (isarError) {
        debugPrint('Error clearing IsarDb logs: $isarError');
        isarSuccess = false;
      }
      
      // Also clear logs from StandaloneLogsProvider
      try {
        final standaloneProvider = StandaloneLogsProvider();
        await standaloneProvider.clearLogs();
        debugPrint('Successfully cleared standalone logs');
      } catch (standaloneError) {
        debugPrint('Error clearing standalone logs: $standaloneError');
        standaloneSuccess = false;
      }
      
      // Update the UI
      logs.value = [];
      filteredLogs.value = [];
      
      if (isarSuccess || standaloneSuccess) {
      Get.snackbar(
        'Success',
          'Logs cleared successfully' + 
          ((!isarSuccess || !standaloneSuccess) ? ' (with some errors)' : ''),
          backgroundColor: (isarSuccess && standaloneSuccess) ? Colors.green : Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to clear logs from both databases',
          backgroundColor: Colors.red,
        colorText: Colors.white,
          duration: const Duration(seconds: 3),
      );
      }
    } catch (e) {
      debugPrint('Unexpected error while clearing logs: $e');
      Get.snackbar(
        'Error',
        'Error clearing logs: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
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

  // Helper method to determine if a log should be shown based on dev mode
  bool shouldShowLog(Map<String, dynamic> log) {
    if (log == null || log.isEmpty) {
      return false;
    }
    
    // Get log type (handle different field names)
    final logType = (log['LogType']?.toString() ?? 
                     log['Type']?.toString() ?? 'NORMAL').toUpperCase();
    
    // Get log message to check for content
    final logMsg = (log['Message']?.toString() ?? '').toLowerCase();
    
    // SPECIAL CASE #1: If dev mode is on, show all logs except extremely frequent scheduled logs
    if (isDevMode.value) {
      return true;
    }
    
    // SPECIAL CASE #2: DEV logs are only shown in dev mode
    if (logType == 'DEV') {
      return false;
    }
    
    // SPECIAL CASE #3: Always show logs with hasRung=1 (alarm rang)
    final hasRung = log['HasRung'];
    if (hasRung != null && hasRung == 1) {
      return true;
    }
    
    // SPECIAL CASE #4: Filter out scheduled logs in non-dev mode
    final status = (log['Status']?.toString() ?? '').toLowerCase();
    if (!isDevMode.value && 
        (status.contains('scheduled') || logMsg.contains('scheduled'))) {
      return false;
    }
    
    // SIMPLE RULE: Show all logs with these keywords regardless of mode
    if (logMsg.contains('created') || 
        logMsg.contains('updated') || 
        logMsg.contains('edited') || 
        logMsg.contains('deleted') || 
        logMsg.contains('ring') || 
        logMsg.contains('went off') || 
        logMsg.contains('error') || 
        logMsg.contains('warning')) {
      return true;
    }
    
    // If we have an alarmID, it's likely important
    final alarmID = log['AlarmID']?.toString() ?? '';
    if (alarmID.isNotEmpty && alarmID != 'null') {
      return true;
    }
    
    // Show errors and warnings always
    if (status.contains('error') || status.contains('warning')) {
      return true;
    }
    
    // Default to showing everything not filtered yet
    return true;
  }

  Color getLogLevelColor(String status) {
    if (status == null || status.isEmpty) {
      return Colors.blue; // Default color
    }
    
    status = status.toLowerCase();
    
    if (status.contains('error')) {
      return Colors.red;
    }
    
    if (status.contains('warning')) {
      return Colors.orange;
    }
    
    // Success, "Alarm Scheduled", and other normal statuses
    if (status.contains('success') || 
        status.contains('scheduled') ||
        status.contains('created') ||
        status.contains('updated')) {
    return Colors.green;
  }

    // Default to blue for unknown status
    return Colors.blue;
  }

  Future<Widget> getAlarmDetailsWidget(String? alarmID, String? logMsg, String? status, bool hasRung) async {
    // Ensure we have valid values or defaults
    String safeLogMsg = logMsg ?? 'No message available';
    String safeStatus = status ?? 'UNKNOWN';
    
    String? effectiveAlarmID = alarmID;
    if (effectiveAlarmID == null || effectiveAlarmID.isEmpty) {
      // Try to extract ID from message if available
      if (safeLogMsg != 'No message available') {
        final idMatch = RegExp(r'ID: (\d+)|alarmID: (\d+)').firstMatch(safeLogMsg);
      if (idMatch != null) {
        effectiveAlarmID = idMatch.group(1) ?? idMatch.group(2);
      }
    }
    }

    try {
      debugPrint('Fetching alarm details for ID: $effectiveAlarmID');

      // Try to fetch alarm details if we have an ID
      if (effectiveAlarmID != null && effectiveAlarmID.isNotEmpty) {
        final alarm = await isar_db.IsarDb.getAlarmByID(effectiveAlarmID);
        if (alarm != null) {
      debugPrint('Found alarm: ${alarm.alarmID} with time: ${alarm.alarmTime}');
      return AlarmDetailsWidget(
        alarm: alarm,
            logMsg: safeLogMsg,
            status: safeStatus,
        hasRung: hasRung,
      );
        }
      }
      
      // If we reach here, either no alarmID was found or the alarm data was not in the database
      // Create a basic widget with the information we have
      debugPrint('No alarm found for ID: $effectiveAlarmID, creating basic info widget');
      return buildFallbackAlarmInfoWidget(safeLogMsg, safeStatus, hasRung);
      
    } catch (e) {
      debugPrint('Error getting alarm details: $e');
      return buildFallbackAlarmInfoWidget(safeLogMsg, safeStatus, hasRung);
    }
  }
  
  Widget buildFallbackAlarmInfoWidget(String? logMsg, String? status, bool hasRung) {
    // Handle null values with safe defaults
    final message = logMsg ?? 'No message available';
    final statusText = status ?? 'UNKNOWN';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.secondaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alarm Info',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryTextColor.value,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasRung ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasRung ? 'Rang' : 'Missed',
                  style: TextStyle(
                    color: hasRung ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Message:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeController.primaryTextColor.value,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeController.primaryTextColor.value,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: getLogLevelColor(statusText),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Note: Detailed alarm information is not available for this log entry.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: themeController.primaryTextColor.value.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Force refresh logs - useful when logs aren't appearing
  Future<void> forceRefreshLogs() async {
    logs.value = [];
    filteredLogs.value = [];
    Get.snackbar(
      'Refreshing',
      'Refreshing alarm logs...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
    await fetchLogs();
  }

  // Add the deleteLog method here
  Future<void> deleteLog(Map<String, dynamic> log) async {
    try {
      debugPrint('Attempting to delete log entry: ${log['Message']}');
      
      // Extract the log ID - this could be LogID from IsarDb or ID from StandaloneLogsProvider
      final logId = log['LogID'] ?? log['ID'];
      
      if (logId == null) {
        debugPrint('Cannot delete log: No valid LogID found');
        Get.snackbar(
          'Error',
          'Unable to delete log entry: No valid ID found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      
      bool success = false;
      
      // Try to delete from IsarDb first
      try {
        final isarResult = await isar_db.IsarDb().deleteLog(logId);
        if (isarResult) {
          success = true;
          debugPrint('Successfully deleted log from IsarDb');
        }
      } catch (isarError) {
        debugPrint('Error deleting log from IsarDb: $isarError');
      }
      
      // Also try to delete from StandaloneLogsProvider
      try {
        final standaloneProvider = StandaloneLogsProvider();
        final standaloneResult = await standaloneProvider.deleteLog(logId);
        if (standaloneResult) {
          success = true;
          debugPrint('Successfully deleted log from standalone provider');
        }
      } catch (standaloneError) {
        debugPrint('Error deleting log from standalone provider: $standaloneError');
      }
      
      if (success) {
        // Remove the log from our local lists
        logs.removeWhere((item) => 
          (item['LogID'] == logId || item['ID'] == logId));
        filteredLogs.removeWhere((item) => 
          (item['LogID'] == logId || item['ID'] == logId));
        
        Get.snackbar(
          'Success',
          'Log entry deleted',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Warning',
          'Could not delete the log entry',
          backgroundColor: Colors.amber,
          colorText: Colors.black,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Error in deleteLog: $e');
      Get.snackbar(
        'Error',
        'Failed to delete log entry: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> createTestLog() async {
    debugPrint('==== STARTING TEST LOG CREATION WITH STANDALONE PROVIDER ====');
    Get.snackbar(
      'Processing',
      'Creating test logs...',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
    
    try {
      final standaloneProvider = StandaloneLogsProvider();
      final now = DateTime.now();
      final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final testAlarmId = 'test-${now.millisecondsSinceEpoch}';
      
      // Try to directly inject SQL for more reliable log creation
      try {
        final db = await standaloneProvider.database;
        
        // Create important test logs directly with SQL
        final batch = db.batch();
        
        // Created log
        batch.insert('LOGS', {
          'LogTime': DateTime.now().millisecondsSinceEpoch,
          'Status': 'SUCCESS',
          'Type': 'NORMAL',
          'Message': 'IMPORTANT-TEST: Alarm Created at $formattedTime',
          'HasRung': 0,
          'AlarmID': 'direct-create-${now.millisecondsSinceEpoch}',
        });
        
        // Updated log
        batch.insert('LOGS', {
          'LogTime': DateTime.now().millisecondsSinceEpoch,
          'Status': 'SUCCESS',
          'Type': 'NORMAL',
          'Message': 'IMPORTANT-TEST: Alarm Updated at $formattedTime',
          'HasRung': 0,
          'AlarmID': 'direct-update-${now.millisecondsSinceEpoch}',
        });
        
        // Ringing log
        batch.insert('LOGS', {
          'LogTime': DateTime.now().millisecondsSinceEpoch,
          'Status': 'SUCCESS',
          'Type': 'NORMAL',
          'Message': 'IMPORTANT-TEST: Alarm Ringing at $formattedTime',
          'HasRung': 1,
          'AlarmID': 'direct-ringing-${now.millisecondsSinceEpoch}',
        });
        
        // Error log
        batch.insert('LOGS', {
          'LogTime': DateTime.now().millisecondsSinceEpoch,
          'Status': 'ERROR',
          'Type': 'NORMAL',
          'Message': 'IMPORTANT-TEST: Error with alarm at $formattedTime',
          'HasRung': 0,
          'AlarmID': 'direct-error-${now.millisecondsSinceEpoch}',
        });
        
        final batchResults = await batch.commit(noResult: false);
        debugPrint('Direct SQL log insertion results: $batchResults');
      } catch (sqlError) {
        debugPrint('Error with direct SQL log injection: $sqlError');
      }
      
      // Create a series of test logs that simulate real alarm events
      List<Map<String, dynamic>> testLogs = [
        // 1. Alarm created log - should always be visible
        {
          'message': 'TEST: Alarm Created - $formattedTime',
          'status': 'SUCCESS',
          'type': 'NORMAL',
          'hasRung': 0,
          'alarmID': testAlarmId
        },
        
        // 2. Alarm updated log - should always be visible
        {
          'message': 'TEST: Alarm Updated - $formattedTime',
          'status': 'SUCCESS',
          'type': 'NORMAL',
          'hasRung': 0,
          'alarmID': testAlarmId
        },
        
        // 3. Alarm ringing log - should always be visible with hasRung=1
        {
          'message': 'TEST: Alarm Ringing - $formattedTime',
          'status': 'SUCCESS',
          'type': 'NORMAL',
          'hasRung': 1,
          'alarmID': testAlarmId
        },
      ];
      
      // Insert all test logs with a small delay between each
      List<int> results = [];
      
      for (var log in testLogs) {
        await Future.delayed(const Duration(milliseconds: 100));
        final result = await standaloneProvider.insertLog(
          log['message'],
          status: log['status'],
          type: log['type'],
          hasRung: log['hasRung'],
          alarmID: log['alarmID'],
        );
        results.add(result);
        debugPrint('Created log: ${log['message']} with ID: $result');
      }
      
      debugPrint('Created ${results.length} test logs and 4 direct SQL logs');
      
      // Verify logs exist by directly querying the database
      try {
        final db = await standaloneProvider.database;
        final verifyCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM LOGS'));
        
        debugPrint('Total logs in standalone database: $verifyCount');
        
        // Get most recent logs for debugging
        final recentLogs = await db.query(
          'LOGS', 
          orderBy: 'LogTime DESC',
          limit: 10
        );
        
        if (recentLogs.isNotEmpty) {
          debugPrint('Recently created logs:');
          for (var log in recentLogs) {
            debugPrint(' - ${log['Message']} (ID: ${log['ID']})');
          }
        }
      } catch (dbError) {
        debugPrint('Error verifying logs: $dbError');
      }
      
      // Show success message
      Get.snackbar(
        'Success',
        'Created test log entries - check the history now',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      // Force refresh logs
      await Future.delayed(const Duration(milliseconds: 300));
      forceRefreshLogs();  // Remove await to not block UI
      
      // Add another snackbar with instructions
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        'Tip',
        'You should now see alarm created, updated and ringing logs',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error during test log creation: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      
      Get.snackbar(
        'Error',
        'Error creating test logs: ${e.toString().substring(0, Math.min(100, e.toString().length))}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
    
    debugPrint('==== TEST LOG CREATION PROCESS COMPLETE ====');
  }
  
  // New method to fetch logs from the standalone provider
  Future<void> fetchLogsFromStandalone() async {
    try {
      debugPrint('Fetching logs from standalone provider...');
      final standaloneProvider = StandaloneLogsProvider();
      final fetchedLogs = await standaloneProvider.getLogs();
      
      // Process the logs to match the format expected by the UI
      final processedLogs = fetchedLogs.map((log) => {
        'LogID': log['ID'],
        'LogTime': log['LogTime'],
        'Status': log['Status'],
        'LogType': log['Type'],
        'Message': log['Message'],
        'HasRung': log['HasRung'],
        'AlarmID': log['AlarmID'],
      }).toList();
      
      logs.value = processedLogs;
      applyFilters();
      
      debugPrint('Successfully loaded ${fetchedLogs.length} logs from standalone provider');
      
      if (fetchedLogs.isNotEmpty) {
        // Print a few logs for debugging
        int count = Math.min(3, fetchedLogs.length);
        debugPrint('First $count standalone logs:');
        for (int i = 0; i < count; i++) {
          final log = fetchedLogs[i];
          debugPrint('Log ${i+1}: ID=${log['ID']}, Time=${log['LogTime']}, '
              'Status=${log['Status']}, Message=${log['Message']}, AlarmID=${log['AlarmID']}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching standalone logs: $e');
      Get.snackbar(
        'Error',
        'Error fetching logs: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
} 