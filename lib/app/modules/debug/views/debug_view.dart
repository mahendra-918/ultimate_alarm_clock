import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/isar_provider.dart';
import '../../../modules/settings/controllers/theme_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/utils.dart';
import '../controllers/debug_controller.dart';
import '../../../data/models/debug_model.dart';
import 'dart:convert';

class DebugView extends GetView<DebugController> {
  DebugView({super.key});

  ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: controller.themeController.secondaryBackgroundColor.value,
        elevation: 0,
        title: Text(
          'Alarm History'.tr,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: controller.themeController.primaryTextColor.value,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          // Insights button
          IconButton(
            icon: Icon(
              Icons.insights,
              color: controller.isShowingInsights.value 
                 ? kprimaryColor
                 : controller.themeController.primaryTextColor.value.withOpacity(0.6),
            ),
            onPressed: () {
              controller.toggleInsights();
            },
            tooltip: 'Insights',
          ),
          Obx(() => Stack(
            alignment: Alignment.center,
            children: [
          IconButton(
                icon: Icon(
                  Icons.developer_mode,
                  color: controller.isDevMode.value ? kprimaryColor : controller.themeController.primaryTextColor.value.withOpacity(0.6),
                ),
                onPressed: () {
                  controller.toggleDevMode();
                  if (controller.isDevMode.value) {
                    Get.snackbar(
                      'Developer Mode Enabled',
                      'Additional technical details will be shown',
                      backgroundColor: Colors.black.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(10),
                    );
                  }
                },
                tooltip: 'Developer Mode',
              ),
              if (controller.isDevMode.value)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          )),
          IconButton(
            icon: Icon(Icons.refresh, color: controller.themeController.primaryTextColor.value.withOpacity(0.8)),
            onPressed: controller.fetchLogs,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: controller.themeController.primaryTextColor.value.withOpacity(0.8)),
            onPressed: () {
              // Show confirmation dialog before deleting
              Get.dialog(
                AlertDialog(
                  backgroundColor: controller.themeController.secondaryBackgroundColor.value,
                  title: Text(
                    'Clear All Logs?',
                    style: TextStyle(color: controller.themeController.primaryTextColor.value),
                  ),
                  content: Text(
                    'This will permanently delete all log entries. This action cannot be undone.',
                    style: TextStyle(color: controller.themeController.primaryTextColor.value.withOpacity(0.8)),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel', style: TextStyle(color: controller.themeController.primaryTextColor.value)),
                      onPressed: () => Get.back(),
                    ),
                    TextButton(
                      child: Text('Clear', style: const TextStyle(color: Colors.red)),
                      onPressed: () {
                        Get.back();
                        controller.clearLogs();
                      },
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      backgroundColor: controller.themeController.primaryBackgroundColor.value,
      body: Column(
        children: [
          // Search and Filter Section with material card styling
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: controller.themeController.secondaryBackgroundColor.value,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Search bar with better styling
                TextField(
                  controller: controller.searchController,
                  onChanged: (value) {
                    controller.applyFilters();
                  },
                  decoration: InputDecoration(
                      hintText: 'Search alarm history...'.tr,
                    prefixIcon: Icon(
                      Icons.search,
                        color: controller.themeController.primaryTextColor.value.withOpacity(0.5),
                        size: 20,
                    ),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                                color: controller.themeController.primaryTextColor.value.withOpacity(0.5),
                                size: 20,
                            ),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: controller.themeController.primaryTextColor.value.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: controller.themeController.primaryTextColor.value.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: kprimaryColor.withOpacity(0.6),
                          width: 1.5,
                        ),
                              ),
                              filled: true,
                      fillColor: controller.themeController.primaryBackgroundColor.value,
                              hintStyle: TextStyle(
                        color: controller.themeController.primaryTextColor.value.withOpacity(0.4),
                        fontSize: 14,
                              ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: TextStyle(
                              color: controller.themeController.primaryTextColor.value,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Filtered logs counter and clear search button in one row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                Obx(() => Text(
                  controller.filteredLogs.isEmpty
                      ? 'No logs available'.tr
                      : '${'Showing'.tr} ${controller.filteredLogs.length} ${'logs'.tr}',
                  style: TextStyle(
                    color: controller.themeController.primaryTextColor.value.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                if (controller.searchController.text.isNotEmpty)
                  TextButton.icon(
                    icon: Icon(Icons.filter_list_off, size: 16, color: kprimaryColor),
                    label: Text('Clear Search'.tr, style: TextStyle(color: kprimaryColor, fontSize: 13)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                              controller.applyFilters();
                            },
                  ),
              ],
            ),
          ),
          
          // Category tabs
                    Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
              color: controller.themeController.primaryBackgroundColor.value,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: controller.themeController.secondaryBackgroundColor.value.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Obx(() => Row(
                children: [
                  _buildTab(0, 'All', null),
                  _buildTab(1, 'Triggered', null),
                  _buildTab(2, 'Skipped', null),
                  _buildTab(3, 'Condition', null),
                ],
              )),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Insights panel - show when insights toggle is on
          Obx(() => controller.isShowingInsights.value
            ? Container(
                height: 200, // Fixed height to prevent overflow
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: _buildInsightsPanel(context)
                )
              )
            : const SizedBox.shrink()
          ),
          
          // Log entries list
          Expanded(
            child: Obx(() => controller.filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 60,
                          color: controller.themeController.primaryTextColor.value.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No alarm history found'.tr,
                          style: TextStyle(
                            color: controller.themeController.primaryTextColor.value.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Alarm events will appear here'.tr,
                          style: TextStyle(
                            color: controller.themeController.primaryTextColor.value.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = controller.filteredLogs[index];
                      final logTime = DateTime.fromMillisecondsSinceEpoch(log['LogTime']);
                      final formattedDate = Utils.getFormattedDate(logTime);
                      final formattedHour = logTime.hour.toString().padLeft(2, '0');
                      final formattedMinute = logTime.minute.toString().padLeft(2, '0');
                      final status = log['Status'];
                      final logType = log['LogType'];
                      final logMsg = log['Message'];
                      final hasRung = log['HasRung'];
                      final alarmID = log['AlarmID'];

                      // Skip dev logs when not in dev mode
                      if(!controller.isDevMode.value && logType == 'DEV') {
                        return const SizedBox.shrink();
                      }

                      // Get status information
                      final statusColor = _getStatusColor(status);
                      final statusIcon = _getStatusIcon(status);
                      final isToday = logTime.day == DateTime.now().day && 
                                     logTime.month == DateTime.now().month && 
                                     logTime.year == DateTime.now().year;

                      // For visual grouping by date
                      final bool showDateDivider = index == 0 || 
                          !_isSameDay(logTime, DateTime.fromMillisecondsSinceEpoch(controller.filteredLogs[index - 1]['LogTime']));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date divider
                          if (showDateDivider)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: controller.themeController.secondaryBackgroundColor.value,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isToday ? 'Today'.tr : formattedDate,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: controller.themeController.primaryTextColor.value.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Divider(
                                        color: controller.themeController.primaryTextColor.value.withOpacity(0.1),
                                        thickness: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Log entry card
                          Card(
                            elevation: 0,
                            color: controller.themeController.secondaryBackgroundColor.value,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: controller.themeController.primaryTextColor.value.withOpacity(0.05),
                                width: 1,
                              ),
                            ),
                            child: ExpansionTile(
                              // Style the expansion tile
                              collapsedBackgroundColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              textColor: controller.themeController.primaryTextColor.value,
                              collapsedIconColor: controller.themeController.primaryTextColor.value.withOpacity(0.7),
                              iconColor: kprimaryColor,
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              expandedCrossAxisAlignment: CrossAxisAlignment.start,
                              maintainState: true,
                              
                              // Custom title layout
                            title: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                    // Status indicator
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(statusIcon, color: statusColor, size: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Log info
                                    Expanded(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                              // Log time
                                              Text(
                                                '$formattedHour:$formattedMinute',
                                                style: TextStyle(
                                                  color: controller.themeController.primaryTextColor.value,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              
                                              // Log type badge (only for DEV logs)
                                              if (logType == 'DEV')
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: kprimaryColor.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'DEV',
                                                    style: TextStyle(
                                                      color: kprimaryColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              
                                              const Spacer(),
                                              
                                              // Success/warning/error badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status == 'SUCCESS' ? 'Success'.tr : 
                                                  status == 'WARNING' ? 'Warning'.tr : 'Error'.tr,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 4),
                                          
                                          // Log message preview
                                          Text(
                                            logMsg,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: controller.themeController.primaryTextColor.value.withOpacity(0.8),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                ],
                              ),
                            ),
                                  ],
                                ),
                              ),
                              
                              // Expanded content
                            children: [
                                // Full log message
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 4, bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: controller.themeController.primaryBackgroundColor.value,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                child: Text(
                                  logMsg,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: controller.themeController.primaryTextColor.value,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                
                                // Developer details (only shown in dev mode)
                                if (controller.isDevMode.value)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Developer section header
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.code, size: 14, color: kprimaryColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Developer Details'.tr,
                                                style: TextStyle(
                                                  color: kprimaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                                        ),
                                        
                                        // Log details in code-like format
                                        Text(
                                          'LogID: ${log['LogID']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        Text(
                                          'Time: ${DateTime.fromMillisecondsSinceEpoch(log['LogTime']).toString()}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        Text(
                                          'Type: ${log['LogType']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        Text(
                                          'Status: ${log['Status']}',
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        if (alarmID != null && alarmID.isNotEmpty)
                                          Text(
                                            'AlarmID: $alarmID',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        if (hasRung != null)
                                          Text(
                                            'HasRung: $hasRung',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                
                                // Alarm details if available
                                _buildAlarmDetails(context, alarmID, logMsg, hasRung),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }

  // Helper functions for status indicators
  Color _getStatusColor(String status) {
    switch (status) {
      case 'SUCCESS':
        return Colors.green;
      case 'WARNING':
        return Colors.orange;
      default: // ERROR
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'SUCCESS':
        return Icons.check_circle_outline;
      case 'WARNING':
        return Icons.info_outline;
      default: // ERROR
        return Icons.error_outline;
    }
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label + ':',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: controller.themeController.primaryTextColor.value.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: controller.themeController.primaryTextColor.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kprimaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: kprimaryColor,
        ),
      ),
    );
  }
  
  // Helper method to build alarm details
  Widget _buildAlarmDetails(BuildContext context, String? alarmID, String logMsg, int? hasRung) {
    // Convert to lowercase for case-insensitive comparison
    final lowerMsg = logMsg.toLowerCase();
    
    // Check if this is an alarm-related log
    final isAlarmLog = lowerMsg.contains('alarm created') || 
                        lowerMsg.contains('alarm updated') || 
                        lowerMsg.contains('alarm triggered') || 
                        lowerMsg.contains('alarm snoozed') ||
                        lowerMsg.contains('alarm didn\'t ring') ||
                        lowerMsg.contains('alarm scheduled') ||
                        lowerMsg.contains('alarm deleted') ||
                        lowerMsg.contains('alarm ring') ||
                        lowerMsg.contains('alarm is ringing') ||
                        lowerMsg.contains('alarm ringing') ||
                        lowerMsg.contains('alarm stopped') ||
                        lowerMsg.contains('triggered alarm') ||
                        lowerMsg.contains('deleted alarm') ||
                        hasRung == 1;
    
    if (!isAlarmLog) {
      return const SizedBox.shrink();
    }
    
    // Extract alarm ID from the message if the alarmID field is empty
    String? effectiveAlarmID = alarmID;
    String? alarmTime;
    
    // Try to extract time from the message
    alarmTime = extractTimeFromMessage(logMsg);
    if (alarmTime != null) {
      debugPrint('Extracted alarm time from message: $alarmTime');
    }
    
    // Try to extract alarm ID from the message for various log types
    if (effectiveAlarmID?.isEmpty ?? true) {
      // For alarm scheduled messages
      if (lowerMsg.contains('alarm scheduled')) {
        final scheduledMatch = RegExp(r'alarmID:\s*([a-zA-Z0-9-]+)').firstMatch(lowerMsg);
        if (scheduledMatch != null && scheduledMatch.groupCount >= 1) {
          effectiveAlarmID = scheduledMatch.group(1);
          debugPrint('Extracted alarm ID from scheduled message: $effectiveAlarmID');
        }
      }
      
      // For alarm deleted messages
      if (lowerMsg.contains('alarm deleted') || lowerMsg.contains('deleted alarm')) {
        // If this is a deleted alarm log, prioritize using time-based lookup
        alarmTime = alarmTime ?? extractTimeFromMessage(logMsg);
        debugPrint('Prioritizing time-based lookup for deleted alarm: $alarmTime');
      }
      
      // For ringing/triggered alarms
      if (lowerMsg.contains('ring') || lowerMsg.contains('triggered')) {
        // If this log is about an alarm ringing or being triggered, look for alarm ID patterns
        final ringMatch = RegExp(r'alarm(?:\s+with)?\s+id[:\s]+([a-zA-Z0-9-]+)', caseSensitive: false).firstMatch(logMsg);
        if (ringMatch != null && ringMatch.groupCount >= 1) {
          effectiveAlarmID = ringMatch.group(1);
          debugPrint('Extracted alarm ID from ring/trigger message: $effectiveAlarmID');
        }
      }
      
      // Try to extract alarm ID from generic patterns
      if (effectiveAlarmID?.isEmpty ?? true) {
        // Look for patterns like "alarmID: 12345" or "alarm ID: 12345"
        final idMatch = RegExp(r'alarm\s?ID:?\s*([a-zA-Z0-9-]+)', caseSensitive: false).firstMatch(logMsg);
        if (idMatch != null && idMatch.groupCount >= 1) {
          effectiveAlarmID = idMatch.group(1);
          debugPrint('Extracted alarm ID from generic pattern: $effectiveAlarmID');
        }
      }
    }
    
    // Decide which method to use to get the alarm details
    if ((effectiveAlarmID?.isNotEmpty ?? false)) {
      debugPrint('Using alarm ID: $effectiveAlarmID for log: $logMsg');
      return _buildAlarmDetailsByID(context, effectiveAlarmID!);
    } else if (lowerMsg.contains('alarm deleted') && alarmTime != null) {
      // For deleted alarms, time-based lookup is more reliable
      debugPrint('Using time-based lookup for deleted alarm with time: $alarmTime');
      return _buildAlarmDetailsByTime(context, alarmTime);
    } else if (lowerMsg.contains('alarm created')) {
      // For created alarms, use the most recent alarm
      debugPrint('Using fallback method for newly created alarm');
      return _buildMostRecentAlarm(context);
    } else if (alarmTime != null) {
      // For other logs, try time-based lookup
      debugPrint('Using alarm time: $alarmTime for log: $logMsg');
      return _buildAlarmDetailsByTime(context, alarmTime);
    } else if (lowerMsg.contains('ring') || lowerMsg.contains('triggered')) {
      // For ringing/triggered logs without other identifiers, try getting the most recent alarm
      debugPrint('Using fallback method for ringing/triggered alarm without ID');
      return _buildMostRecentAlarm(context);
    } else {
      // Last resort: try to get any enabled alarm
      debugPrint('Using enabled alarms fallback for log: $logMsg');
      return _buildEnabledAlarm(context);
    }
  }
  
  // Build alarm details using alarm ID
  Widget _buildAlarmDetailsByID(BuildContext context, String alarmID) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getAlarmDetails(alarmID),
      builder: (context, snapshot) => _buildAlarmDetailsFromSnapshot(context, snapshot),
    );
  }
  
  // Build alarm details using alarm time
  Widget _buildAlarmDetailsByTime(BuildContext context, String alarmTime) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getAlarmDetailsByTime(alarmTime),
      builder: (context, snapshot) => _buildAlarmDetailsFromSnapshot(context, snapshot),
    );
  }
  
  // Build most recent alarm details as fallback
  Widget _buildMostRecentAlarm(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getMostRecentAlarm(),
      builder: (context, snapshot) => _buildAlarmDetailsFromSnapshot(context, snapshot),
    );
  }
  
  // Build enabled alarm details as final fallback
  Widget _buildEnabledAlarm(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: controller.getEnabledAlarms(),
      builder: (context, snapshot) => _buildAlarmDetailsFromSnapshot(context, snapshot),
    );
  }
  
  // Build alarm details from snapshot
  Widget _buildAlarmDetailsFromSnapshot(BuildContext context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!snapshot.hasData || snapshot.data == null) {
      return const SizedBox.shrink();
    }
    
    final alarmData = snapshot.data!;
    List<bool> days = [];
    try {
      if (alarmData['days'] != null) {
        // Convert string representation of days to boolean list
        final daysString = alarmData['days'];
        // Rotate the string to start with Monday
        final rotatedString = daysString.substring(1) + daysString[0];
        // Convert the rotated string to a list of boolean values
        days = rotatedString.split('').map((c) => c == '1').toList();
      }
    } catch (e) {
      debugPrint('Error parsing days: $e');
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeController.primaryBackgroundColor.value.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeController.primaryTextColor.value.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeController.primaryTextColor.value,
            ),
          ),
          const SizedBox(height: 8),
          if (alarmData['label'] != null && alarmData['label'].toString().isNotEmpty)
            _buildDetailRow(context, 'Label', alarmData['label']),
          _buildDetailRow(context, 'Set For', alarmData['alarmTime'] ?? 'Unknown'),
          if (days.isNotEmpty)
            _buildDetailRow(context, 'Days', controller.getDaysText(days)),
          if (alarmData['ringtoneName'] != null)
            _buildDetailRow(context, 'Ringtone', alarmData['ringtoneName']),
          
          // Weather details
          Builder(
            builder: (context) {
              if (alarmData['isWeatherEnabled'] == 1 && alarmData['weatherTypes'] != null) {
                try {
                  final weatherTypesString = alarmData['weatherTypes'];
                  final weatherTypesList = List<int>.from(jsonDecode(weatherTypesString));
                  final weatherTypes = Utils.getWeatherTypesFromInt(weatherTypesList);
                  final formattedTypes = Utils.getFormattedWeatherTypes(weatherTypes);
                  return _buildDetailRow(context, 'Weather', formattedTypes);
                } catch (e) {
                  debugPrint('Error parsing weather types: $e');
                }
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Add math problems details
          Builder(
            builder: (context) {
              if (alarmData['isMathsEnabled'] == 1) {
                final difficultyLevel = alarmData['mathsDifficulty'] ?? 'Medium';
                final questions = alarmData['numMathsQuestions']?.toString() ?? '3';
                return _buildDetailRow(context, 'Math', '$questions questions (${difficultyLevel})');
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Add shake details
          Builder(
            builder: (context) {
              if (alarmData['isShakeEnabled'] == 1 && alarmData['shakeTimes'] != null) {
                return _buildDetailRow(context, 'Shake', '${alarmData['shakeTimes']} times');
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Add QR code details
          Builder(
            builder: (context) {
              if (alarmData['isQrEnabled'] == 1) {
                return _buildDetailRow(context, 'QR Code', 'Enabled');
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Add pedometer details
          Builder(
            builder: (context) {
              if (alarmData['isPedometerEnabled'] == 1 && alarmData['numberOfSteps'] != null) {
                return _buildDetailRow(context, 'Pedometer', '${alarmData['numberOfSteps']} steps');
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Add activity details
          Builder(
            builder: (context) {
              if (alarmData['isActivityEnabled'] == 1 && alarmData['activityInterval'] != null) {
                return _buildDetailRow(context, 'Activity', '${alarmData['activityInterval']} seconds');
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Add location details
          Builder(
            builder: (context) {
              if (alarmData['isLocationEnabled'] == 1 && alarmData['location'] != null) {
                return _buildDetailRow(context, 'Location', alarmData['location']);
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 8),
          
          // Features section
          if (_hasFeatures(alarmData)) ...[
            Text(
              'Features',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: themeController.primaryTextColor.value,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (alarmData['isWeatherEnabled'] == 1)
                  _buildFeatureChip('Weather'),
                if (alarmData['isLocationEnabled'] == 1)
                  _buildFeatureChip('Location'),
                if (alarmData['isMathsEnabled'] == 1)
                  _buildFeatureChip('Math Problems'),
                if (alarmData['isShakeEnabled'] == 1)
                  _buildFeatureChip('Shake'),
                if (alarmData['isQrEnabled'] == 1)
                  _buildFeatureChip('QR Code'),
                if (alarmData['isPedometerEnabled'] == 1)
                  _buildFeatureChip('Pedometer'),
                if (alarmData['isActivityEnabled'] == 1)
                  _buildFeatureChip('Activity'),
                if (alarmData['isSharedAlarmEnabled'] == 1)
                  _buildFeatureChip('Shared Alarm'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper function to extract time from various message formats
  String? extractTimeFromMessage(String message) {
    // Match HH:MM AM/PM format
    final timeRegex1 = RegExp(r'(\d{1,2}:\d{2}\s?[AP]M)', caseSensitive: false);
    final match1 = timeRegex1.firstMatch(message);
    if (match1 != null && match1.groupCount >= 1) {
      return match1.group(1);
    }
    
    // Match HH:MM 24-hour format
    final timeRegex2 = RegExp(r'(\d{1,2}:\d{2})(?!\s?[AP]M)');
    final match2 = timeRegex2.firstMatch(message);
    if (match2 != null && match2.groupCount >= 1) {
      return match2.group(1);
    }
    
    return null;
  }

  bool _hasFeatures(Map<String, dynamic> alarmData) {
    return alarmData['isWeatherEnabled'] == 1 ||
        alarmData['isLocationEnabled'] == 1 ||
        alarmData['isMathsEnabled'] == 1 ||
        alarmData['isShakeEnabled'] == 1 ||
        alarmData['isQrEnabled'] == 1 ||
        alarmData['isPedometerEnabled'] == 1 ||
        alarmData['isActivityEnabled'] == 1 ||
        alarmData['isSharedAlarmEnabled'] == 1;
  }

  // Helper function to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // Helper method to build a tab
  Widget _buildTab(int index, String label, IconData? icon) {
    final isSelected = controller.tabIndex.value == index;
    final backgroundColor = isSelected ? kprimaryColor : Colors.transparent;
    final textColor = isSelected ? Colors.black : controller.themeController.primaryTextColor.value.withOpacity(0.7);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              label.tr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this method to build the insights panel
  Widget _buildInsightsPanel(BuildContext context) {
    return Obx(() => controller.isInsightsLoading.value
      ? const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: CircularProgressIndicator(),
        ))
      : Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: controller.themeController.secondaryBackgroundColor.value,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: kprimaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alarm Insights',
                      style: TextStyle(
                        color: controller.themeController.primaryTextColor.value,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Overview stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildStatGrid(context),
              ),
              
              // Wakeup time distribution
              _buildWakeupTimeDistribution(context),
              
              // Most common day to wake up
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInsightCard(
                        context,
                        'Most Common Day',
                        controller.getMostCommonWakeupDay(),
                        Icons.calendar_today,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInsightCard(
                        context,
                        'Most Used Feature',
                        controller.getMostUsedFeature(),
                        Icons.star,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Wakeup success rate
              _buildWakeupSuccessRate(context),
              
              const SizedBox(height: 8),
            ],
          ),
        )
    );
  }
  
  Widget _buildStatGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Alarms Created',
                controller.totalAlarmsCreated.toString(),
                Icons.add_alarm,
                kprimaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Alarms Triggered',
                controller.totalAlarmsTriggered.toString(),
                Icons.alarm_on,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Alarms Skipped',
                controller.totalAlarmsSkipped.toString(),
                Icons.alarm_off,
                Colors.red,
              ),
            ),
          ],
        ),
        if (controller.averageSnoozeTime.value > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Snooze Time',
                    '${controller.averageSnoozeTime.value} min',
                    Icons.snooze,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: controller.themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: controller.themeController.primaryTextColor.value,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: controller.themeController.primaryTextColor.value.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWakeupTimeDistribution(BuildContext context) {
    final total = controller.earlyMorningWakeups.value + 
                 controller.lateMorningWakeups.value + 
                 controller.afternoonWakeups.value;
    
    if (total == 0) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: controller.themeController.primaryBackgroundColor.value,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Not enough data to show wake-up patterns',
            style: TextStyle(
              color: controller.themeController.primaryTextColor.value.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    final earlyPercentage = total > 0 ? (controller.earlyMorningWakeups.value / total) : 0.0;
    final latePercentage = total > 0 ? (controller.lateMorningWakeups.value / total) : 0.0;
    final afternoonPercentage = total > 0 ? (controller.afternoonWakeups.value / total) : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wake-up Time Distribution',
            style: TextStyle(
              color: controller.themeController.primaryTextColor.value,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Early morning
          _buildDistributionBar(
            'Early Morning (before 7 AM)',
            earlyPercentage,
            controller.earlyMorningWakeups.value,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          
          // Late morning
          _buildDistributionBar(
            'Morning (7 AM - 11 AM)',
            latePercentage,
            controller.lateMorningWakeups.value,
            Colors.amber,
          ),
          const SizedBox(height: 8),
          
          // Afternoon
          _buildDistributionBar(
            'Afternoon/Evening (after 11 AM)',
            afternoonPercentage,
            controller.afternoonWakeups.value,
            Colors.purple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDistributionBar(String label, double percentage, int count, Color color) {
    // Safeguard to prevent division by zero or invalid percentages
    percentage = percentage.isNaN || percentage.isInfinite ? 0.0 : percentage;
    percentage = percentage.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: controller.themeController.primaryTextColor.value.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                color: controller.themeController.primaryTextColor.value,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: controller.themeController.secondaryBackgroundColor.value,
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * percentage;
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 8,
                      width: width.isFinite && width > 0 ? width : 0,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ],
    );
  }
  
  Widget _buildInsightCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: controller.themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.themeController.primaryTextColor.value.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: controller.themeController.primaryTextColor.value,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWakeupSuccessRate(BuildContext context) {
    final successRate = controller.getWakeupSuccessRate();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wake-up Success Rate',
            style: TextStyle(
              color: controller.themeController.primaryTextColor.value,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.themeController.secondaryBackgroundColor.value,
                  border: Border.all(
                    color: successRate > 75 ? Colors.green : 
                          successRate > 50 ? Colors.amber : Colors.red,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${successRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: controller.themeController.primaryTextColor.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      successRate > 75 ? 'Excellent!' : 
                      successRate > 50 ? 'Good' : 'Needs Improvement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: successRate > 75 ? Colors.green : 
                              successRate > 50 ? Colors.amber : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      successRate > 75 ? 'You rarely miss your alarms!' : 
                      successRate > 50 ? 'You wake up to most of your alarms' : 
                      'You miss alarms frequently. Try different alarm settings.',
                      style: TextStyle(
                        fontSize: 13,
                        color: controller.themeController.primaryTextColor.value.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}