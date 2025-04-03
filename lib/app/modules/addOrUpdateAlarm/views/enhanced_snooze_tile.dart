import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class EnhancedSnoozeTile extends StatelessWidget {
  const EnhancedSnoozeTile({
    Key? key,
    required this.controller,
    required this.themeController,
  }) : super(key: key);

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Advanced Snooze Settings',
        style: TextStyle(color: themeController.primaryTextColor.value),
      ),
      children: [
        // Maximum snooze count
        ListTile(
          title: Text(
            'Maximum Snooze Count',
            style: TextStyle(color: themeController.primaryTextColor.value),
          ),
          subtitle: Obx(() {
            return Text(
              controller.maxSnoozeCount.value == 0
                  ? 'Unlimited snoozes allowed'
                  : 'Limit to ${controller.maxSnoozeCount.value} snoozes',
              style: TextStyle(color: themeController.primaryDisabledTextColor.value),
            );
          }),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: kprimaryColor),
                onPressed: () {
                  Utils.hapticFeedback();
                  if (controller.maxSnoozeCount.value > 0) {
                    controller.maxSnoozeCount.value--;
                  }
                },
              ),
              Obx(() {
                return Text(
                  controller.maxSnoozeCount.value == 0
                      ? '∞'
                      : '${controller.maxSnoozeCount.value}',
                  style: TextStyle(color: themeController.primaryTextColor.value),
                );
              }),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: kprimaryColor),
                onPressed: () {
                  Utils.hapticFeedback();
                  if (controller.maxSnoozeCount.value < 10) {
                    controller.maxSnoozeCount.value++;
                  }
                },
              ),
            ],
          ),
        ),
        
        // Smart Snooze toggle
        ListTile(
          title: Text(
            'Smart Snooze',
            style: TextStyle(color: themeController.primaryTextColor.value),
          ),
          subtitle: Text(
            'Gradually decrease snooze duration',
            style: TextStyle(color: themeController.primaryDisabledTextColor.value),
          ),
          trailing: Obx(() {
            return Switch(
              value: controller.smartSnoozeEnabled.value,
              onChanged: (value) {
                Utils.hapticFeedback();
                controller.smartSnoozeEnabled.value = value;
              },
              activeColor: kprimaryColor,
            );
          }),
        ),
        
        // Smart Snooze settings (visible only when enabled)
        Obx(() {
          return Visibility(
            visible: controller.smartSnoozeEnabled.value,
            child: Column(
              children: [
                // Decrement amount
                ListTile(
                  title: Text(
                    'Decrement Minutes',
                    style: TextStyle(color: themeController.primaryTextColor.value),
                  ),
                  subtitle: Text(
                    'Reduce snooze by ${controller.smartSnoozeDecrement.value} min each time',
                    style: TextStyle(color: themeController.primaryDisabledTextColor.value),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: kprimaryColor),
                        onPressed: () {
                          Utils.hapticFeedback();
                          if (controller.smartSnoozeDecrement.value > 1) {
                            controller.smartSnoozeDecrement.value--;
                          }
                        },
                      ),
                      Text(
                        '${controller.smartSnoozeDecrement.value}',
                        style: TextStyle(color: themeController.primaryTextColor.value),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: kprimaryColor),
                        onPressed: () {
                          Utils.hapticFeedback();
                          if (controller.smartSnoozeDecrement.value < 5) {
                            controller.smartSnoozeDecrement.value++;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                // Minimum duration
                ListTile(
                  title: Text(
                    'Minimum Snooze Duration',
                    style: TextStyle(color: themeController.primaryTextColor.value),
                  ),
                  subtitle: Text(
                    '${controller.minSmartSnoozeDuration.value} minutes',
                    style: TextStyle(color: themeController.primaryDisabledTextColor.value),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: kprimaryColor),
                        onPressed: () {
                          Utils.hapticFeedback();
                          if (controller.minSmartSnoozeDuration.value > 1) {
                            controller.minSmartSnoozeDuration.value--;
                          }
                        },
                      ),
                      Text(
                        '${controller.minSmartSnoozeDuration.value}',
                        style: TextStyle(color: themeController.primaryTextColor.value),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: kprimaryColor),
                        onPressed: () {
                          Utils.hapticFeedback();
                          if (controller.minSmartSnoozeDuration.value < controller.snoozeDuration.value - 1) {
                            controller.minSmartSnoozeDuration.value++;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
} 