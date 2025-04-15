import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import '../controllers/settings_controller.dart';
import '../controllers/theme_controller.dart';

class EnablePhysicalButtons extends StatelessWidget {
  final SettingsController controller;
  final ThemeController themeController;
  final double width;
  final double height;

  const EnablePhysicalButtons({
    required this.controller,
    required this.themeController,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: width * 0.91,
        height: height * 0.09,
        decoration: Utils.getCustomTileBoxDecoration(
          isLightMode: themeController.currentTheme.value == ThemeMode.light,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListTile(
              tileColor: themeController.secondaryBackgroundColor.value,
              title: Text(
                'Physical Buttons'.tr,
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                  fontSize: 15,
                ),
              ),
              trailing: DropdownButton<String>(
                value: controller.physicalButtonAction.value,
                dropdownColor: themeController.secondaryBackgroundColor.value,
                underline: Container(),
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                  fontSize: 13,
                ),
                onChanged: (String? newValue) {
                  Utils.hapticFeedback();
                  if (newValue != null) {
                    controller.updatePhysicalButtonAction(newValue);
                  }
                },
                items: <String>['Do Nothing', 'Snooze', 'Dismiss']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.tr),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 