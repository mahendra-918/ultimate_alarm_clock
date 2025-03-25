import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/providers/google_cloud_api_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/share_dialog.dart';
import 'dart:math' as math;

import '../../../utils/constants.dart';

class SettingSelector extends StatelessWidget {
  SettingSelector({super.key});
  AddOrUpdateAlarmController controller =
      Get.find<AddOrUpdateAlarmController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: controller.homeController.scalingFactor.value * 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Option(0, Icons.alarm, 'Alarm'),
          ),
          Expanded(
            child: Option(1, Icons.auto_awesome, 'Smart-Controls'),
          ),
          Expanded(
            child: Option(2, Icons.checklist_rounded, 'Challenges'),
          ),
          Expanded(
            child: Option(3, Icons.share, 'Share'),
          ),
        ],
      ),
    );
  }

  Widget Option(int val, IconData icon, String name) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48 * controller.homeController.scalingFactor.value,
            height: 48 * controller.homeController.scalingFactor.value,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                if (name == 'Share') {
                  final isLoggedIn = await GoogleCloudProvider.isUserLoggedin();
                  if(isLoggedIn) {
                    Get.dialog(ShareDialog(
                      homeController: controller.homeController,
                      controller: controller,
                      themeController: controller.themeController,
                    ));
                  } else {
                    await GoogleCloudProvider.getInstance();
                  }
                } else {
                  controller.alarmSettingType.value = val;
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: controller.alarmSettingType.value == val
                      ? kprimaryColor
                      : controller.themeController.secondaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: math.max(24 * controller.homeController.scalingFactor.value, 20),
                  color: controller.alarmSettingType.value == val
                      ? kLightPrimaryTextColor
                      : controller.themeController.primaryDisabledTextColor.value,
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * controller.homeController.scalingFactor.value),
          Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: math.max(12 * controller.homeController.scalingFactor.value, 10),
              color: controller.alarmSettingType.value == val
                  ? kprimaryColor
                  : controller.themeController.primaryDisabledTextColor.value,
            ),
          ),
        ],
      ),
    );
  }
}
