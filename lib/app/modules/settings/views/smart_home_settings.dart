import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/routes/app_pages.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class SmartHomeSettings extends StatelessWidget {
  final SettingsController controller;
  final double height;
  final double width;
  final ThemeController themeController;

  const SmartHomeSettings({
    Key? key,
    required this.controller,
    required this.height,
    required this.width,
    required this.themeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.1,
      width: width * 0.9,
      decoration: BoxDecoration(
        color: themeController.secondaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: () {
          Utils.hapticFeedback();
          Get.toNamed(Routes.SMART_HOME);
        },
        leading: Icon(
          Icons.home_outlined,
          color: themeController.primaryColor.value,
          size: 28,
        ),
        title: Text(
          'Smart Home Devices'.tr,
          style: TextStyle(
            color: themeController.primaryTextColor.value,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Manage smart home devices and integrations'.tr,
          style: TextStyle(
            color: themeController.secondaryTextColor.value,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: themeController.secondaryTextColor.value,
          size: 16,
        ),
      ),
    );
  }
}

class SmartHomeActionModel {
  String alarmId;
  String deviceId;
  SmartDeviceAction action;
  ActionTrigger trigger;
  int? offsetMinutes;
  String? actionParameters;
  bool isEnabled;
  
  SmartHomeActionModel({
    required this.alarmId,
    required this.deviceId,
    required this.action,
    required this.trigger,
    this.offsetMinutes,
    this.actionParameters,
    required this.isEnabled,
  });
}

enum ActionTrigger {
  BEFORE_ALARM,
  DURING_ALARM,
  AFTER_DISMISS,
  AFTER_SNOOZE
}

enum SmartDeviceAction {
  TURN_ON,
  TURN_OFF,
  SET_BRIGHTNESS,
  SET_COLOR,
  SET_TEMPERATURE,
  PLAY_SOUND,
  STOP_SOUND
}
