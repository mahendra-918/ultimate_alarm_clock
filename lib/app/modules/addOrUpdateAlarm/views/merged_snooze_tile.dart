import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class MergedSnoozeTile extends StatelessWidget {
  const MergedSnoozeTile({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () {
          Utils.hapticFeedback();
          _openSnoozeSettingsScreen(context);
        },
        child: ListTile(
          title: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              'Snooze Settings'.tr,
              style: TextStyle(
                color: themeController.primaryTextColor.value,
              ),
            ),
          ),
          subtitle: Text(
            controller.snoozeDuration.value > 0
                ? 'Duration: ${controller.snoozeDuration.value} min${_getAdditionalSnoozeInfo()}'
                : 'Snooze disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Show smart snooze icon if enabled
              if (controller.smartSnoozeEnabled.value)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.trending_down,
                    color: kprimaryColor,
                    size: 20,
                  ),
                ),
              
              // Show max snooze count if set
              if (controller.maxSnoozeCount.value > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.maxSnoozeCount.value}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              Icon(
                Icons.chevron_right,
                color: themeController.primaryDisabledTextColor.value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAdditionalSnoozeInfo() {
    List<String> info = [];
    
    if (controller.maxSnoozeCount.value > 0) {
      info.add(', Max: ${controller.maxSnoozeCount.value}');
    }
    
    if (controller.smartSnoozeEnabled.value) {
      info.add(', Smart');
    }
    
    return info.join('');
  }

  void _openSnoozeSettingsScreen(BuildContext context) {
    // Store initial values in case user cancels
    int initialDuration = controller.snoozeDuration.value;
    int initialMaxCount = controller.maxSnoozeCount.value;
    bool initialSmartSnooze = controller.smartSnoozeEnabled.value;
    int initialDecrement = controller.smartSnoozeDecrement.value;
    int initialMinDuration = controller.minSmartSnoozeDuration.value;

    // Navigate to full screen settings page
    Get.to(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            'Snooze Settings'.tr,
            style: TextStyle(color: themeController.primaryTextColor.value),
          ),
          backgroundColor: themeController.primaryBackgroundColor.value,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeController.primaryTextColor.value,
            ),
            onPressed: () {
              // Restore initial values if back button pressed
              controller.snoozeDuration.value = initialDuration;
              controller.maxSnoozeCount.value = initialMaxCount;
              controller.smartSnoozeEnabled.value = initialSmartSnooze;
              controller.smartSnoozeDecrement.value = initialDecrement;
              controller.minSmartSnoozeDuration.value = initialMinDuration;
              Get.back();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Utils.hapticFeedback();
                Get.back();
              },
              child: Text(
                'Done'.tr,
                style: TextStyle(
                  color: kprimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: themeController.primaryBackgroundColor.value,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Snooze Duration Picker
              Container(
                color: themeController.secondaryBackgroundColor.value,
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Text(
                      'Duration'.tr,
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(
                          () => NumberPicker(
                            value: controller.snoozeDuration.value <= 0
                                ? 0
                                : controller.snoozeDuration.value,
                            minValue: 0,
                            maxValue: 60,
                            onChanged: (value) {
                              Utils.hapticFeedback();
                              controller.snoozeDuration.value = value;
                            },
                            textStyle: TextStyle(
                              color: themeController.primaryDisabledTextColor.value,
                              fontSize: 22,
                            ),
                            selectedTextStyle: TextStyle(
                              color: kprimaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Obx(
                          () => Text(
                            controller.snoozeDuration.value > 0
                            ? controller.snoozeDuration.value > 1
                                ? 'minutes'.tr
                                : 'minute'.tr
                            : 'Off'.tr,
                            style: TextStyle(
                              color: themeController.primaryTextColor.value,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        controller.snoozeDuration.value == 0
                            ? 'Snooze will be disabled'
                            : 'Snooze button will appear when alarm rings',
                        style: TextStyle(
                          color: themeController.primaryDisabledTextColor.value,
                          fontSize: 14,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              
              // Maximum Snooze Count
              Container(
                color: themeController.secondaryBackgroundColor.value,
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Maximum Snooze Count',
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Obx(() => Text(
                      controller.maxSnoozeCount.value == 0
                          ? 'Unlimited snoozes allowed'
                          : 'Limit to ${controller.maxSnoozeCount.value} snoozes',
                      style: TextStyle(
                        color: themeController.primaryDisabledTextColor.value,
                        fontSize: 14,
                      ),
                    )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: kprimaryColor, size: 32),
                          onPressed: () {
                            Utils.hapticFeedback();
                            if (controller.maxSnoozeCount.value > 0) {
                              controller.maxSnoozeCount.value--;
                            }
                          },
                        ),
                        SizedBox(
                          width: 80,
                          child: Center(
                            child: Obx(() {
                              return Text(
                                controller.maxSnoozeCount.value == 0
                                    ? '∞'
                                    : '${controller.maxSnoozeCount.value}',
                                style: TextStyle(
                                  color: themeController.primaryTextColor.value,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: kprimaryColor, size: 32),
                          onPressed: () {
                            Utils.hapticFeedback();
                            if (controller.maxSnoozeCount.value < 10) {
                              controller.maxSnoozeCount.value++;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Smart Snooze Switch
              Container(
                color: themeController.secondaryBackgroundColor.value,
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(16.0),
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
                              'Smart Snooze',
                              style: TextStyle(
                                color: themeController.primaryTextColor.value, 
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Gradually decrease snooze duration',
                              style: TextStyle(
                                color: themeController.primaryDisabledTextColor.value, 
                                fontSize: 14
                              ),
                            ),
                          ],
                        ),
                        Obx(() {
                          return Switch(
                            value: controller.smartSnoozeEnabled.value,
                            onChanged: (value) {
                              Utils.hapticFeedback();
                              controller.smartSnoozeEnabled.value = value;
                            },
                            activeColor: kprimaryColor,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Smart Snooze Settings
              Obx(() {
                return Visibility(
                  visible: controller.smartSnoozeEnabled.value,
                  child: Column(
                    children: [
                      // Decrement amount
                      Container(
                        color: themeController.secondaryBackgroundColor.value,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Decrement Minutes',
                                style: TextStyle(
                                  color: themeController.primaryTextColor.value, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Obx(() => Text(
                              'Reduce snooze by ${controller.smartSnoozeDecrement.value} min each time',
                              style: TextStyle(
                                color: themeController.primaryDisabledTextColor.value, 
                                fontSize: 14
                              ),
                            )),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: kprimaryColor, size: 32),
                                  onPressed: () {
                                    Utils.hapticFeedback();
                                    if (controller.smartSnoozeDecrement.value > 1) {
                                      controller.smartSnoozeDecrement.value--;
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Obx(() => Text(
                                      '${controller.smartSnoozeDecrement.value}',
                                      style: TextStyle(
                                        color: themeController.primaryTextColor.value,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline, color: kprimaryColor, size: 32),
                                  onPressed: () {
                                    Utils.hapticFeedback();
                                    if (controller.smartSnoozeDecrement.value < 5) {
                                      controller.smartSnoozeDecrement.value++;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Minimum duration
                      Container(
                        color: themeController.secondaryBackgroundColor.value,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Minimum Snooze Duration',
                                style: TextStyle(
                                  color: themeController.primaryTextColor.value, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Obx(() => Text(
                              '${controller.minSmartSnoozeDuration.value} minutes',
                              style: TextStyle(
                                color: themeController.primaryDisabledTextColor.value, 
                                fontSize: 14
                              ),
                            )),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: kprimaryColor, size: 32),
                                  onPressed: () {
                                    Utils.hapticFeedback();
                                    if (controller.minSmartSnoozeDuration.value > 1) {
                                      controller.minSmartSnoozeDuration.value--;
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Center(
                                    child: Obx(() => Text(
                                      '${controller.minSmartSnoozeDuration.value}',
                                      style: TextStyle(
                                        color: themeController.primaryTextColor.value,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline, color: kprimaryColor, size: 32),
                                  onPressed: () {
                                    Utils.hapticFeedback();
                                    if (controller.minSmartSnoozeDuration.value < controller.snoozeDuration.value - 1) {
                                      controller.minSmartSnoozeDuration.value++;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              // Information section
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                color: themeController.secondaryBackgroundColor.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Smart Snooze',
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Snooze gradually decreases the duration of each successive snooze to help you wake up gently. ' +
                      'Each time you snooze, the duration will be reduced by the decrement amount until it reaches the minimum duration.',
                      style: TextStyle(
                        color: themeController.primaryDisabledTextColor.value,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 