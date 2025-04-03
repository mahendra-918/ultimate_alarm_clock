import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class TimezoneTile extends StatelessWidget {
  final AddOrUpdateAlarmController controller;
  TimezoneTile({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ThemeController themeController = Get.find<ThemeController>();

  void _showTimezoneSelector() {
    Get.dialog(
      Dialog(
        backgroundColor: themeController.secondaryBackgroundColor.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Timezone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryTextColor.value,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: ListView(
                  children: [
                    _buildTimezoneOption('America/New_York', 'Eastern Time (ET)'),
                    _buildTimezoneOption('America/Chicago', 'Central Time (CT)'),
                    _buildTimezoneOption('America/Denver', 'Mountain Time (MT)'),
                    _buildTimezoneOption('America/Los_Angeles', 'Pacific Time (PT)'),
                    _buildTimezoneOption('Europe/London', 'Greenwich Mean Time (GMT)'),
                    _buildTimezoneOption('Europe/Paris', 'Central European Time (CET)'),
                    _buildTimezoneOption('Asia/Tokyo', 'Japan Standard Time (JST)'),
                    _buildTimezoneOption('Asia/Shanghai', 'China Standard Time (CST)'),
                    _buildTimezoneOption('Asia/Kolkata', 'Indian Standard Time (IST)'),
                    _buildTimezoneOption('Australia/Sydney', 'Australian Eastern Time (AET)'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Utils.hapticFeedback();
                      Get.back();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: themeController.primaryTextColor.value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimezoneOption(String timezoneId, String timezoneName) {
    return InkWell(
      onTap: () {
        Utils.hapticFeedback();
        controller.timezoneId.value = timezoneId;
        controller.timezoneName.value = timezoneName;
        Get.back();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeController.primaryTextColor.value.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timezoneName,
              style: TextStyle(color: themeController.primaryTextColor.value),
            ),
            Obx(() {
              return controller.timezoneId.value == timezoneId
                  ? Icon(
                      Icons.check_circle,
                      color: kprimaryColor,
                      size: 20,
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Timezone Setting',
            style: TextStyle(color: themeController.primaryTextColor.value),
          ),
          subtitle: Obx(() {
            return Text(
              controller.useLocalTimezone.value
                  ? 'Using device local time'
                  : 'Using ${controller.timezoneName.value} time',
              style: TextStyle(color: themeController.primaryDisabledTextColor.value),
            );
          }),
          trailing: Obx(() {
            return Switch(
              value: !controller.useLocalTimezone.value,
              onChanged: (value) {
                Utils.hapticFeedback();
                controller.useLocalTimezone.value = !value;
                if (controller.useLocalTimezone.value) {
                  controller.timezoneId.value = 'device_local';
                  controller.timezoneName.value = 'Device Local';
                } else if (controller.timezoneId.value == 'device_local') {
                  _showTimezoneSelector();
                }
              },
              activeColor: kprimaryColor,
            );
          }),
        ),
        Obx(() {
          return controller.useLocalTimezone.value == false
              ? ListTile(
                  title: Text(
                    'Select Timezone',
                    style: TextStyle(color: themeController.primaryTextColor.value),
                  ),
                  subtitle: Obx(() {
                    return Text(
                      controller.timezoneName.value,
                      style: TextStyle(color: themeController.primaryDisabledTextColor.value),
                    );
                  }),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Utils.hapticFeedback();
                    _showTimezoneSelector();
                  },
                )
              : const SizedBox.shrink();
        }),
        Obx(() {
          return controller.useLocalTimezone.value == false
              ? ListTile(
                  title: Text(
                    'Show Dual Time',
                    style: TextStyle(color: themeController.primaryTextColor.value),
                  ),
                  subtitle: Text(
                    'Display both local and timezone time',
                    style: TextStyle(color: themeController.primaryDisabledTextColor.value),
                  ),
                  trailing: Obx(() {
                    return Switch(
                      value: controller.showDualTime.value,
                      onChanged: (value) {
                        Utils.hapticFeedback();
                        controller.showDualTime.value = value;
                      },
                      activeColor: kprimaryColor,
                    );
                  }),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }
} 