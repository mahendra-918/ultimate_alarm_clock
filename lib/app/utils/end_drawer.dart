import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/routes/app_pages.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

Widget buildEndDrawer(BuildContext context) {
  ThemeController themeController = Get.find<ThemeController>();
  return Obx(
    () => Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      backgroundColor: themeController.secondaryBackgroundColor.value,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kLightSecondaryColor),
            child: Center(
              child: Row(
                children: [
                  const Flexible(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        'assets/images/ic_launcher-playstore.png',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SizedBox(
                            width: Get.width * 0.5,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                'Ultimate Alarm Clock'.tr,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                      color: themeController
                                          .primaryBackgroundColor.value,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            width: Get.width * 0.5,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                'v0.2.1'.tr,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: themeController.primaryTextColor.value,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  onTap: () {
                    Utils.hapticFeedback();
                    Get.back();
                    Get.toNamed(Routes.ALARM_HISTORY);
                  },
                  contentPadding: const EdgeInsets.only(left: 20, right: 44),
                  title: Text(
                    'Alarm History'.tr,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: themeController.primaryTextColor.value
                              .withOpacity(0.8),
                        ),
                  ),
                  leading: Icon(
                    Icons.history,
                    size: 26,
                    color: themeController.primaryTextColor.value
                        .withOpacity(0.8),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Utils.hapticFeedback();
                    Get.back();
                    Get.toNamed('/settings');
                  },
                  contentPadding: const EdgeInsets.only(left: 20, right: 44),
                  title: Text(
                    'Settings'.tr,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: themeController.primaryTextColor.value
                              .withOpacity(0.8),
                        ),
                  ),
                  leading: Icon(
                    Icons.settings,
                    size: 26,
                    color: themeController.primaryTextColor.value
                        .withOpacity(0.8),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Utils.hapticFeedback();
                    Get.back();
                    Get.toNamed(Routes.ABOUT);
                  },
                  contentPadding: const EdgeInsets.only(left: 20, right: 44),
                  title: Text(
                    'About'.tr,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: themeController.primaryTextColor.value
                              .withOpacity(0.8),
                        ),
                  ),
                  leading: Icon(
                    Icons.info_outline,
                    size: 26,
                    color: themeController.primaryTextColor.value
                        .withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
