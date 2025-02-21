
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class SnoozeDurationTile extends StatelessWidget {
  const SnoozeDurationTile({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(() => InkWell(
          onTap: () {
            Utils.hapticFeedback();
            // Store temporary values in case the changes are canceled.
            final int tempDuration = controller.snoozeDuration.value;
            final int tempMaxSnoozes = controller.maxSnoozes.value;

            Get.defaultDialog(
              onWillPop: () async {
                // Restore original values on back press.
                controller.snoozeDuration.value = tempDuration;
                controller.maxSnoozes.value = tempMaxSnoozes;
                return true;
              },
              titlePadding: const EdgeInsets.only(top: 20),
              backgroundColor: themeController.secondaryBackgroundColor.value,
              title: 'Select Snooze Settings'.tr,
              titleStyle: Theme.of(context).textTheme.displaySmall,
              content: Container(
                // Use a container with a fixed max height r to guarantee the button row is visible.
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Expanded scrollable section with pickers.
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(
                          () => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Snooze Duration Section
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Snooze Duration".tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${controller.snoozeDuration.value} ${controller.snoozeDuration.value > 1 ? 'minutes'.tr : 'minute'.tr}",
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    NumberPicker(
                                      value: controller.snoozeDuration.value <= 0
                                          ? 1
                                          : controller.snoozeDuration.value,
                                      minValue: 1,
                                      maxValue: 1440,
                                      onChanged: (value) {
                                        Utils.hapticFeedback();
                                        controller.snoozeDuration.value = value;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              // Max Snoozes Section
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Max Snoozes".tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      controller.maxSnoozes.value == 11
                                          ? "∞"
                                          : "${controller.maxSnoozes.value} ${controller.maxSnoozes.value > 1 ? 'times'.tr : 'time'.tr}",
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    NumberPicker(
                                      value: controller.maxSnoozes.value <= 0
                                          ? 1
                                          : controller.maxSnoozes.value,
                                      minValue: 1,
                                      maxValue: 11, // 11 means infinity.
                                      textMapper: (value) {
                                        return value == "11" ? '∞' : value;
                                      },
                                      onChanged: (value) {
                                        Utils.hapticFeedback();
                                        controller.maxSnoozes.value = value;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Static button row for Save and Cancel
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Utils.hapticFeedback();
                              // The values are already updated; just dismiss the dialog.
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kprimaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Save'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                    color: themeController.secondaryTextColor.value,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Utils.hapticFeedback();
                              // Revert to original values
                              controller.snoozeDuration.value = tempDuration;
                              controller.maxSnoozes.value = tempMaxSnoozes;
                              Get.back();
                            },
                            child: Text(
                              'Cancel'.tr,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: ListTile(
            title: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                'Snooze Duration'.tr,
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                ),
              ),
            ),
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Obx(
                  () {
                    final String maxSnoozeText =
                        controller.maxSnoozes.value == 11 ? '∞' : '${controller.maxSnoozes.value}';
                    return Text(
                      controller.snoozeDuration.value > 0
                          ? '${controller.snoozeDuration.value} min, $maxSnoozeText max'
                          : 'Off'.tr,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: controller.snoozeDuration.value <= 0
                                ? themeController.primaryDisabledTextColor.value
                                : themeController.primaryTextColor.value,
                          ),
                    );
                  },
                ),
                Icon(
                  Icons.chevron_right,
                  color: themeController.primaryDisabledTextColor.value,
                ),
              ],
            ),
          ),
        ));
  }
}
