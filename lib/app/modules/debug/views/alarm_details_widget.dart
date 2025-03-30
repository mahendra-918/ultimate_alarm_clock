import 'package:flutter/material.dart';
import '../../../data/models/alarm_model.dart';
import '../../../utils/utils.dart';
import '../../../modules/settings/controllers/theme_controller.dart';
import '../../../modules/settings/controllers/settings_controller.dart';
import 'package:get/get.dart';

class AlarmDetailsWidget extends StatelessWidget {
  final AlarmModel alarm;
  final String logMsg;
  final String status;
  final bool hasRung;

  const AlarmDetailsWidget({
    Key? key,
    required this.alarm,
    required this.logMsg,
    required this.status,
    required this.hasRung,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final settingsController = Get.find<SettingsController>();
    
    // Safe values for display
    final safeLogMsg = logMsg.isNotEmpty ? logMsg : 'No message available';
    
    return Card(
      color: themeController.secondaryBackgroundColor.value,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${alarm.alarmTime}',
                  style: TextStyle(
                    fontSize: 24,
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
                    hasRung ? 'Rang'.tr : 'Missed'.tr,
                    style: TextStyle(
                      color: hasRung ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alarm.label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  alarm.label,
                  style: TextStyle(
                    fontSize: 16,
                    color: themeController.primaryTextColor.value,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Message section - always show the log message
            const Divider(),
            Text(
              'Message:'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeController.primaryTextColor.value,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              safeLogMsg,
              style: TextStyle(
                color: themeController.primaryTextColor.value,
              ),
            ),
            const Divider(),
            
            // Alarm details section
            buildDetailRow('Alarm ID'.tr, alarm.alarmID),
            buildDetailRow('Schedule'.tr, _getDaysText()),
            if (alarm.isOneTime) buildDetailRow('One-time alarm'.tr, 'Yes'.tr),
            buildDetailRow('Ringtone'.tr, alarm.ringtoneName),
            buildDetailRow('Profile'.tr, alarm.profile),
            if (alarm.note.isNotEmpty) buildDetailRow('Note'.tr, alarm.note),
            
            // Challenges section
            const Divider(),
            Text(
              'Challenges:'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeController.primaryTextColor.value,
              ),
            ),
            const SizedBox(height: 8),
            buildChallengesList(),
            
            // Developer details section - only shown when in developer mode
            if (settingsController.isDevMode.value) ...[
              const Divider(),
              Text(
                'Developer Details:'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryTextColor.value,
                ),
              ),
              const SizedBox(height: 8),
              buildDetailRow('FirestoreID'.tr, alarm.firestoreId ?? 'N/A'),
              buildDetailRow('OwnerID'.tr, alarm.ownerId),
              buildDetailRow('OwnerName'.tr, alarm.ownerName),
              buildDetailRow('LastEditedBy'.tr, alarm.lastEditedUserId),
              buildDetailRow('IsOneTime'.tr, alarm.isOneTime.toString()),
              buildDetailRow('DeleteAfterGoesOff'.tr, alarm.deleteAfterGoesOff.toString()),
              buildDetailRow('ShowMotivationalQuote'.tr, alarm.showMotivationalQuote.toString()),
              buildDetailRow('Volume Range'.tr, '${alarm.volMin} - ${alarm.volMax}'),
              buildDetailRow('Activity Monitor'.tr, alarm.activityMonitor.toString()),
              buildDetailRow('Activity Interval'.tr, alarm.activityInterval.toString()),
              buildDetailRow('IsShared'.tr, alarm.isSharedAlarmEnabled.toString()),
              if (alarm.sharedUserIds != null && alarm.sharedUserIds!.isNotEmpty)
                buildDetailRow('Shared Users'.tr, alarm.sharedUserIds!.join(", ")),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    final themeController = Get.find<ThemeController>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeController.primaryTextColor.value.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: themeController.primaryTextColor.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChallengesList() {
    final challenges = <Widget>[];
    final themeController = Get.find<ThemeController>();
    
    if (alarm.isMathsEnabled) {
      challenges.add(
        _buildChallenge(
          Icons.calculate,
          'Math Challenge'.tr,
          '${alarm.numMathsQuestions} questions (${_getDifficultyText()})',
        ),
      );
    }
    
    if (alarm.isShakeEnabled) {
      challenges.add(
        _buildChallenge(
          Icons.vibration,
          'Shake Challenge'.tr,
          '${alarm.shakeTimes} shakes',
        ),
      );
    }
    
    if (alarm.isQrEnabled) {
      challenges.add(
        _buildChallenge(
          Icons.qr_code,
          'QR Code Challenge'.tr,
          'Required',
        ),
      );
    }
    
    if (alarm.isPedometerEnabled) {
      challenges.add(
        _buildChallenge(
          Icons.directions_walk,
          'Pedometer Challenge'.tr,
          '${alarm.numberOfSteps} steps',
        ),
      );
    }
    
    if (alarm.isLocationEnabled) {
      challenges.add(
        _buildChallenge(
          Icons.location_on,
          'Location Challenge'.tr,
          alarm.location,
        ),
      );
    }
    
    if (alarm.isWeatherEnabled) {
      challenges.add(
        _buildChallenge(
          Icons.cloud,
          'Weather Challenge'.tr,
          _getWeatherText(),
        ),
      );
    }
    
    if (challenges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'None'.tr,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: themeController.primaryTextColor.value.withOpacity(0.7),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: challenges,
    );
  }

  Widget _buildChallenge(IconData icon, String title, String description) {
    final themeController = Get.find<ThemeController>();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: themeController.primaryTextColor.value.withOpacity(0.7),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: themeController.primaryTextColor.value,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeController.primaryTextColor.value.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText() {
    switch (alarm.mathsDifficulty) {
      case 0:
        return 'Easy'.tr;
      case 1:
        return 'Medium'.tr;
      case 2:
        return 'Hard'.tr;
      default:
        return 'Unknown'.tr;
    }
  }

  String _getDaysText() {
    if (alarm.isOneTime) {
      try {
        return Utils.getFormattedDate(DateTime.parse(alarm.alarmDate));
      } catch (e) {
        return 'One-time'.tr;
      }
    }
    
    final List<String> days = [];
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (int i = 0; i < alarm.days.length; i++) {
      if (alarm.days[i]) {
        days.add(dayNames[i].tr);
      }
    }
    
    if (days.isEmpty) {
      return 'None'.tr;
    } else if (days.length == 7) {
      return 'Everyday'.tr;
    } else if (days.length == 5 && !alarm.days[5] && !alarm.days[6]) {
      return 'Weekdays'.tr;
    } else if (days.length == 2 && alarm.days[5] && alarm.days[6]) {
      return 'Weekends'.tr;
    }
    
    return days.join(', ');
  }

  String _getWeatherText() {
    final weatherOptions = [
      'Clear'.tr,
      'Cloudy'.tr,
      'Rain'.tr,
      'Snow'.tr,
      'Thunderstorm'.tr
    ];
    
    final selectedWeather = <String>[];
    for (int i = 0; i < alarm.weatherTypes.length; i++) {
      final index = alarm.weatherTypes[i];
      if (index >= 0 && index < weatherOptions.length) {
        selectedWeather.add(weatherOptions[index]);
      }
    }
    
    return selectedWeather.isEmpty ? 'Any'.tr : selectedWeather.join(', ');
  }
} 