import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/views/timezone_indicator.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class TimezoneAlarmExampleScreen extends StatelessWidget {
  const TimezoneAlarmExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Scaffold(
      backgroundColor: themeController.primaryBackgroundColor.value,
      appBar: AppBar(
        backgroundColor: themeController.primaryBackgroundColor.value,
        title: Text(
          'Timezone Alarms',
          style: TextStyle(color: themeController.primaryTextColor.value),
        ),
        iconTheme: IconThemeData(color: themeController.primaryTextColor.value),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAlarmListItem(
              themeController,
              '06:30',
              'Morning Meeting',
              'Using New York Time (ET)',
              'Every weekday',
              'Eastern Time (ET)',
              const TimeOfDay(hour: 11, minute: 30),
            ),
            _buildAlarmListItem(
              themeController,
              '16:00',
              'Team Standup',
              'Using Tokyo Time (JST)',
              'Mon, Wed, Fri',
              'Japan Standard Time (JST)',
              const TimeOfDay(hour: 2, minute: 0),
            ),
            _buildAlarmListItem(
              themeController,
              '19:45',
              'Weekly Call with London',
              'Using London Time (GMT)',
              'Every Tuesday',
              'Greenwich Mean Time (GMT)',
              const TimeOfDay(hour: 14, minute: 45),
            ),
            _buildAlarmListItem(
              themeController,
              '08:15',
              'Sydney Client Meeting',
              'Using Sydney Time (AET)',
              'Tomorrow only',
              'Australian Eastern Time (AET)',
              const TimeOfDay(hour: 23, minute: 15),
              isOneTime: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kprimaryColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  Widget _buildAlarmListItem(
    ThemeController themeController,
    String time,
    String label,
    String subtitle,
    String repeatDays,
    String timezoneName,
    TimeOfDay localEquivalent, {
    bool isOneTime = false,
  }) {
    return Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeController.primaryDisabledTextColor.value,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Local time: ${localEquivalent.hour.toString().padLeft(2, '0')}:${localEquivalent.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kprimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TimezoneIndicator(timezoneName: timezoneName),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: kprimaryColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeController.primaryTextColor.value,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      repeatDays,
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
                  if (isOneTime)
                    _buildFeatureIndicator(Icons.calendar_today, "One-time"),
                  _buildFeatureIndicator(Icons.public, "Timezone"),
                ],
              ),
            ],
          ),
        ],
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
} 