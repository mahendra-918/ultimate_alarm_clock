import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/views/condition_explanation_widget.dart';

class ScreenActivityTile extends StatelessWidget {
  const ScreenActivityTile({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // Main screen activity tile with toggle
          ListTile(
            title: Row(
              children: [
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Screen Activity'.tr,
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_sharp,
                    size: 21,
                    color: themeController.primaryTextColor.value.withOpacity(0.3),
                  ),
                  onPressed: () {
                    Utils.hapticFeedback();
                    Utils.showModal(
                      context: context,
                      title: 'Screen Activity Based Alarm',
                      description: 'This feature uses your phone\'s screen '
                          'activity to determine whether to ring the alarm or not. '
                          'You can set the alarm to ring when your phone has been active '
                          'or inactive during a specified time period.',
                      iconData: Icons.screen_lock_portrait,
                      isLightMode: themeController.currentTheme.value == ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
            trailing: Switch(
              value: controller.useScreenActivity.value,
              onChanged: (value) {
                Utils.hapticFeedback();
                controller.useScreenActivity.value = value;
                if (value) {
                  // Default to active condition when enabling
                  controller.isActivityenabled.value = true;
                  controller.isNegativeActivityEnabled.value = false;
                  controller.isActivityMonitorenabled.value = 1;
                  if (controller.activityInterval.value == 0) {
                    controller.activityInterval.value = 5; // Default to 5 minutes
                  }
                } else {
                  controller.isActivityenabled.value = false;
                  controller.isNegativeActivityEnabled.value = false;
                  controller.isActivityMonitorenabled.value = 0;
                }
              },
              activeColor: kprimaryColor,
            ),
          ),
          
          // Additional settings that show only when screen activity is enabled
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: controller.useScreenActivity.value
              ? Column(
                children: [
                  // Add explanation helper
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(child: Container()),
                        ConditionExplanationWidget(
                          themeController: themeController,
                          title: "Screen Activity Condition Types",
                          positiveExplanation: 
                              "When 'Ring if ACTIVE' is selected, the alarm will ONLY ring if your phone's screen has been active during the time period you specify.",
                          negativeExplanation: 
                              "When 'Ring if INACTIVE' is selected, the alarm will ONLY ring if your phone's screen has been inactive during the time period you specify.",
                        ),
                      ],
                    ),
                  ),
                  
                  // Condition type section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: themeController.primaryBackgroundColor.value,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeController.primaryTextColor.value.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity Mode:',
                                style: TextStyle(
                                  color: themeController.primaryTextColor.value,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Positive condition with improved visuals
                              InkWell(
                                onTap: () {
                                  Utils.hapticFeedback();
                                  controller.isActivityenabled.value = true;
                                  controller.isNegativeActivityEnabled.value = false;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: controller.isActivityenabled.value 
                                        ? kprimaryColor.withOpacity(0.15) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: controller.isActivityenabled.value 
                                          ? kprimaryColor 
                                          : themeController.primaryTextColor.value.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        controller.isActivityenabled.value 
                                            ? Icons.radio_button_checked 
                                            : Icons.radio_button_unchecked,
                                        color: controller.isActivityenabled.value 
                                            ? kprimaryColor 
                                            : themeController.primaryTextColor.value,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ring if ACTIVE in past time period',
                                              style: TextStyle(
                                                color: themeController.primaryTextColor.value,
                                                fontWeight: controller.isActivityenabled.value 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Alarm will only sound if your phone has been used recently',
                                              style: TextStyle(
                                                color: themeController.primaryTextColor.value.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Negative condition with improved visuals
                              InkWell(
                                onTap: () {
                                  Utils.hapticFeedback();
                                  controller.isActivityenabled.value = false;
                                  controller.isNegativeActivityEnabled.value = true;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: controller.isNegativeActivityEnabled.value 
                                        ? Colors.redAccent.withOpacity(0.1) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: controller.isNegativeActivityEnabled.value 
                                          ? Colors.redAccent 
                                          : themeController.primaryTextColor.value.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        controller.isNegativeActivityEnabled.value 
                                            ? Icons.radio_button_checked 
                                            : Icons.radio_button_unchecked,
                                        color: controller.isNegativeActivityEnabled.value 
                                            ? Colors.redAccent 
                                            : themeController.primaryTextColor.value,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ring if INACTIVE in past time period',
                                              style: TextStyle(
                                                color: themeController.primaryTextColor.value,
                                                fontWeight: controller.isNegativeActivityEnabled.value 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Alarm will only sound if your phone has not been used recently',
                                              style: TextStyle(
                                                color: themeController.primaryTextColor.value.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Time period section with enhanced visuals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Checking Period:',
                          style: TextStyle(
                            color: themeController.primaryTextColor.value,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: themeController.primaryBackgroundColor.value,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeController.primaryTextColor.value.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Check past',
                                style: TextStyle(
                                  color: themeController.primaryTextColor.value,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: kprimaryColor.withOpacity(0.5)),
                                  color: kprimaryColor.withOpacity(0.1),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: NumberPicker(
                                  value: controller.activityInterval.value,
                                  minValue: 1,
                                  maxValue: 1440,
                                  onChanged: (value) {
                                    Utils.hapticFeedback();
                                    controller.activityInterval.value = value;
                                  },
                                  textStyle: TextStyle(
                                    color: themeController.primaryTextColor.value.withOpacity(0.5),
                                  ),
                                  selectedTextStyle: TextStyle(
                                    color: themeController.primaryTextColor.value,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                controller.activityInterval.value > 1
                                  ? 'minutes'
                                  : 'minute',
                                style: TextStyle(
                                  color: themeController.primaryTextColor.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              )
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
