import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/home/controllers/home_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'dart:math' as math;

import '../../../routes/app_pages.dart';

Widget notificationIcon(HomeController controller) {
  ThemeController themeController = Get.find<ThemeController>();
  return Padding(
    padding: EdgeInsets.all(12.0 * controller.scalingFactor.value),
    child: Obx(
      () => controller.isUserSignedIn.value
          ? StreamBuilder(
              stream: FirestoreDb.getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List notif = snapshot.data!['receivedItems'];
                  controller.notifications = notif;
                  return notif.isEmpty
                      ? InkWell(
                          onTap: () {
                            Get.snackbar('Notifications', 'No Notifications');
                          },
                          child: Icon(
                            Icons.notifications,
                            size: math.max(30 * controller.scalingFactor.value, 27),
                            color: themeController.primaryTextColor.value.withOpacity(0.75),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            Get.toNamed(
                              Routes.NOTIFICATIONS,
                            );
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0 * controller.scalingFactor.value),
                                child: Icon(
                                  Icons.notifications,
                                  size: math.max(30 * controller.scalingFactor.value, 27),
                                  color: themeController.primaryTextColor.value.withOpacity(0.75),
                                ),
                              ),
                              Positioned(
                                left: 28 * controller.scalingFactor.value,
                                top: -3 * controller.scalingFactor.value,
                                child: Text(
                                  '${notif.length}',
                                  style: TextStyle(
                                    color: kprimaryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: math.max(14 * controller.scalingFactor.value, 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                }
                return Icon(
                  Icons.notifications_none,
                  size: math.max(30 * controller.scalingFactor.value, 27),
                  color: kprimaryDisabledTextColor,
                );
              },
            )
          : Icon(
              Icons.notifications_none,
              size: math.max(30 * controller.scalingFactor.value, 27),
              color: kprimaryDisabledTextColor,
            ),
    ),
  );
}
