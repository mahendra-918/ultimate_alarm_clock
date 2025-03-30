import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../data/providers/isar_provider.dart';
import '../../../modules/settings/controllers/theme_controller.dart';
import '../../../utils/constants.dart';
import '../../../utils/utils.dart';
import '../controllers/debug_controller.dart';
import '../../../data/models/debug_model.dart';
import '../../../data/models/alarm_model.dart';

class DebugView extends GetView<DebugController> {
  DebugView({super.key});

  ThemeController themeController = Get.find<ThemeController>();

  Widget _buildExpandedContent(BuildContext context, String? alarmID, String logMsg, String status, bool hasRung) {
    if (alarmID == null || alarmID.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: FutureBuilder<Widget>(
        future: controller.getAlarmDetailsWidget(alarmID, logMsg, status, hasRung),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading alarm details: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.hasData) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      logMsg,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    snapshot.data!,
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: controller.themeController.secondaryBackgroundColor.value,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Alarm History'.tr,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: controller.themeController.primaryTextColor.value,
                  ),
            ),
            const SizedBox(width: 8),
            Obx(() => controller.isDevMode.value 
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'DEV',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox.shrink()
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Obx(() => Icon(
              Icons.developer_mode,
              color: controller.isDevMode.value ? Colors.orange : null,
            )),
            onPressed: controller.toggleDevMode,
            tooltip: 'Developer Mode'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchLogs,
            tooltip: 'Refresh'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: controller.clearLogs,
            tooltip: 'Clear History'.tr,
          ),
        ],
      ),
      backgroundColor: controller.themeController.primaryBackgroundColor.value,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.forceRefreshLogs(),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text('Force Refresh'.tr, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.createTestLog(),
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    label: Text('Create Test Log'.tr, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  onChanged: (value) {
                    controller.applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by ID (e.g., 1, 2, 3) or message...'.tr,
                    prefixIcon: Icon(
                      Icons.search,
                      color: controller.themeController.primaryTextColor.value.withOpacity(0.75),
                    ),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: controller.themeController.primaryTextColor.value.withOpacity(0.75),
                            ),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: controller.themeController.secondaryBackgroundColor.value,
                    hintStyle: TextStyle(
                      color: controller.themeController.primaryTextColor.value.withOpacity(0.5),
                    ),
                    helperText: 'Search by ID, message, or date (e.g., "1" for LogID 1)'.tr,
                    helperStyle: TextStyle(
                      color: controller.themeController.primaryTextColor.value.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  style: TextStyle(
                    color: controller.themeController.primaryTextColor.value,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<LogLevel>(
                            value: controller.selectedLogLevel.value,
                            decoration: InputDecoration(
                              hintText: 'Filter by log level'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: controller.themeController.secondaryBackgroundColor.value,
                              hintStyle: TextStyle(
                                color: controller.themeController.primaryTextColor.value.withOpacity(0.5),
                              ),
                            ),
                            dropdownColor: controller.themeController.secondaryBackgroundColor.value,
                            style: TextStyle(
                              color: controller.themeController.primaryTextColor.value,
                            ),
                            items: LogLevel.values.map((level) {
                              Color levelColor;
                              String levelText;
                              switch (level) {
                                case LogLevel.error:
                                  levelColor = Colors.red;
                                  levelText = 'Error';
                                  break;
                                case LogLevel.warning:
                                  levelColor = Colors.orange;
                                  levelText = 'Warning';
                                  break;
                                case LogLevel.info:
                                  levelColor = Colors.green;
                                  levelText = 'Info';
                                  break;
                              }
                              return DropdownMenuItem(
                                value: level,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: levelColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(levelText),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedLogLevel.value = value;
                              controller.applyFilters();
                            },
                          )),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: controller.themeController.secondaryBackgroundColor.value,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: controller.themeController.primaryTextColor.value.withOpacity(0.75),
                        ),
                        onPressed: controller.selectDateRange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => controller.filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      'No logs available'.tr,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: controller.themeController.primaryTextColor.value,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = controller.filteredLogs[index];
                      final logTime = DateTime.fromMillisecondsSinceEpoch(log['LogTime'] ?? DateTime.now().millisecondsSinceEpoch);
                      final formattedTime = Utils.getFormattedDate(logTime);
                      final formattedHour = logTime.hour.toString().padLeft(2, '0');
                      final formattedMinute = logTime.minute.toString().padLeft(2, '0');
                      final status = log['Status'] as String? ?? 'UNKNOWN';
                      final logLevelColor = controller.getLogLevelColor(status);
                      final logType = log['LogType'] as String? ?? log['Type'] as String? ?? 'NORMAL';
                      final logMsg = log['Message'] as String? ?? 'No message available';
                      final hasRung = log['HasRung'] == 1;
                      final alarmID = log['AlarmID'] as String?;

                      return Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: ExpansionTile(
                              collapsedBackgroundColor: themeController.secondaryBackgroundColor.value,
                              backgroundColor: themeController.secondaryBackgroundColor.value,
                              textColor: Colors.white,
                              collapsedIconColor: Colors.white,
                              iconColor: Colors.white,
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('$formattedHour:$formattedMinute', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),),
                                              const SizedBox(width: 8),
                                              Text(formattedTime, style: TextStyle(color: themeController.primaryDisabledTextColor.value, fontWeight: FontWeight.w600, fontSize: 12),),
                                            ],
                                          ),
                                          Text(logMsg, style: const TextStyle(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                        ]
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          logMsg.toLowerCase().contains('deleted') 
                                              ? Icons.delete_forever
                                              : logMsg.toLowerCase().contains('created')
                                                  ? Icons.add_circle
                                                  : logMsg.toLowerCase().contains('updated')
                                                      ? Icons.edit
                                                      : logMsg.toLowerCase().contains('ringing') || 
                                                        logMsg.toLowerCase().contains('went off') || 
                                                        logMsg.toLowerCase().contains('rang')
                                                          ? Icons.alarm_on
                                                          : logMsg.toLowerCase().contains('scheduled')
                                                              ? Icons.schedule
                                                              : status.toLowerCase() == 'error'
                                                                  ? Icons.error
                                                                  : status.toLowerCase() == 'warning'
                                                                      ? Icons.warning
                                                                      : Icons.check_circle,
                                          color: logMsg.toLowerCase().contains('deleted')
                                              ? Colors.red
                                              : logMsg.toLowerCase().contains('ringing') || 
                                                logMsg.toLowerCase().contains('went off') || 
                                                logMsg.toLowerCase().contains('rang')
                                                  ? Colors.orange
                                                  : status.toLowerCase() == 'error'
                                                      ? Colors.red
                                                      : status.toLowerCase() == 'warning'
                                                          ? Colors.orange
                                                          : logMsg.toLowerCase().contains('scheduled')
                                                              ? Colors.blue
                                                              : Colors.green,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                          ),
                                          color: Colors.red,
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Delete Log Entry?'),
                                                content: Text('Are you sure you want to delete this log entry?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      controller.deleteLog(log);
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          tooltip: 'Delete log entry',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                                  ),
                                  child: FutureBuilder<Widget>(
                                    future: controller.getAlarmDetailsWidget(
                                      log['AlarmID'],
                                      logMsg,
                                      status,
                                      hasRung,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'Error loading alarm details: ${snapshot.error}',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasData) {
                                        return SingleChildScrollView(
                                          physics: const BouncingScrollPhysics(),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  logMsg,
                                                  style: const TextStyle(fontSize: 14, color: Colors.white),
                                                ),
                                                const SizedBox(height: 10),
                                                snapshot.data!,
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }
}