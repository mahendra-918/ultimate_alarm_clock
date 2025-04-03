import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/views/timezone_indicator.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class AlarmListItem extends StatelessWidget {
  final AlarmModel alarm;
  final ThemeController themeController;
  final Function(bool) onToggle;
  final VoidCallback onTap;

  const AlarmListItem({
    Key? key,
    required this.alarm,
    required this.themeController,
    required this.onToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeController.secondaryBackgroundColor.value,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  alarm.alarmTime,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeController.primaryTextColor.value,
                  ),
                ),
                Switch(
                  value: alarm.isEnabled,
                  onChanged: onToggle,
                  activeColor: kprimaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.label.isEmpty ? 'Alarm' : alarm.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: themeController.primaryTextColor.value,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRepeatText(alarm.days),
                        style: TextStyle(
                          fontSize: 14,
                          color: themeController.primaryDisabledTextColor.value,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    if (!alarm.useLocalTimezone)
                      TimezoneIndicator(timezoneName: alarm.timezoneName),
                    
                    // Display other alarm feature indicators here
                    if (alarm.isMathsEnabled)
                      _buildFeatureIndicator(Icons.calculate, "Math"),
                    if (alarm.isWeatherEnabled)
                      _buildFeatureIndicator(Icons.cloud, "Weather"),
                    if (alarm.isShakeEnabled)
                      _buildFeatureIndicator(Icons.vibration, "Shake"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIndicator(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: kprimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kprimaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: kprimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getRepeatText(List<bool> days) {
    if (days.every((day) => day == false)) {
      return 'One-time alarm';
    }
    
    if (days.every((day) => day == true)) {
      return 'Every day';
    }
    
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = <String>[];
    
    for (int i = 0; i < days.length; i++) {
      if (days[i]) {
        selectedDays.add(dayNames[i]);
      }
    }
    
    // Check if weekdays
    final weekdays = days.sublist(0, 5).every((day) => day == true) && 
                     days.sublist(5, 7).every((day) => day == false);
    if (weekdays) {
      return 'Weekdays';
    }
    
    // Check if weekends
    final weekends = days.sublist(0, 5).every((day) => day == false) && 
                     days.sublist(5, 7).every((day) => day == true);
    if (weekends) {
      return 'Weekends';
    }
    
    return selectedDays.join(', ');
  }
} 