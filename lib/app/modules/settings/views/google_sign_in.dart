import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import '../../../data/providers/google_cloud_api_provider.dart';

class GoogleSignIn extends StatelessWidget {
  const GoogleSignIn({
    super.key,
    required this.controller,
    required this.width,
    required this.height,
    required this.themeController,
  });

  final SettingsController controller;
  final ThemeController themeController;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      onTap: () async {
        Utils.hapticFeedback();
        if (controller.isUserLoggedIn.value == false) {
          var isSuccessfulLogin = await GoogleCloudProvider.getInstance();

          if (isSuccessfulLogin != null) {
            Get.defaultDialog(
              titlePadding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: themeController.secondaryBackgroundColor.value,
              title: 'Success!'.tr,
              titleStyle: Theme.of(context).textTheme.displaySmall,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.done,
                      size: 50,
                      color: Colors.green,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Your account is now linked!'.tr,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(kprimaryColor),
                      ),
                      child: Obx(
                        () => Text(
                          'Okay'.tr,
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                color: themeController.secondaryTextColor.value,
                              ),
                        ),
                      ),
                      onPressed: () {
                        Utils.hapticFeedback();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            Get.snackbar('Error', 'Sign-In attempt failed!');
          }
        } else {
          Get.defaultDialog(
            contentPadding: const EdgeInsets.all(10.0),
            titlePadding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: themeController.secondaryBackgroundColor.value,
            title: 'Are you sure?'.tr,
            titleStyle: Theme.of(context).textTheme.displaySmall,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('unlinkAccount'.tr),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(kprimaryColor),
                          ),
                          child: Obx(
                            () => Text(
                              'Unlink'.tr,
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                    color: themeController.secondaryTextColor.value,
                                  ),
                            ),
                          ),
                          onPressed: () async {
                            Utils.hapticFeedback();
                            await controller.logoutGoogle();
                            Get.back();
                          },
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              kprimaryTextColor.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            'Cancel'.tr,
                            style: Theme.of(context).textTheme.displaySmall!,
                          ),
                          onPressed: () {
                            Utils.hapticFeedback();
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        width: width * 0.91,
        height: height * 0.1,
        decoration: Utils.getCustomTileBoxDecoration(
          isLightMode: themeController.currentTheme.value == ThemeMode.light,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Expanded(
                  child: Text(
                    controller.isUserLoggedIn.value
                        ? 'Unlink @usermail'.trParams({
                            'usermail': controller.userModel.value!.email,
                          })
                        : 'Sign-In with Google'.tr,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ),
              Obx(
                () => IconButton(
                  onPressed: () => {
                    Utils.hapticFeedback(),
                    showBottomSheet(
                      context: context,
                      backgroundColor: themeController.secondaryBackgroundColor.value,
                      builder: (context) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  'Why do I have to sign in with Google?'.tr,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displayMedium,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Sign-inDescription'.tr,
                                      textAlign: TextAlign.justify,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Shared Alarm'.tr,
                                      style: Theme.of(context).textTheme.displaySmall,
                                    ),
                                    Text(
                                      'CollabDescription'.tr,
                                      textAlign: TextAlign.justify,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Syncing Across Devices'.tr,
                                      style: Theme.of(context).textTheme.displaySmall,
                                    ),
                                    Text(
                                      'AccessMultiple'.tr,
                                      textAlign: TextAlign.justify,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Your privacy'.tr,
                                      style: Theme.of(context).textTheme.displaySmall,
                                    ),
                                    Text(
                                      'NoAccessInfo'.tr,
                                      textAlign: TextAlign.justify,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'LimitedAccess'.tr,
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: width,
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(kprimaryColor),
                                    ),
                                    onPressed: () {
                                      Utils.hapticFeedback();
                                      Get.back();
                                    },
                                    child: Text(
                                      'Understood'.tr,
                                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                            color: themeController.secondaryTextColor.value,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  },
                  icon: Icon(
                    Icons.info_sharp,
                    size: 21,
                    color: themeController.primaryTextColor.value.withOpacity(0.3),
                  ),
                ),
              ),
              Obx(
                () => Icon(
                  controller.isUserLoggedIn.value
                      ? Icons.close
                      : Icons.arrow_forward_ios_sharp,
                  color: themeController.primaryTextColor.value.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}