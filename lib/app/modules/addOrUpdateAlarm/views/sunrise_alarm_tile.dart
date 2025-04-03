import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class SunriseAlarmTile extends StatelessWidget {
  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  const SunriseAlarmTile({
    Key? key,
    required this.controller,
    required this.themeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Sunrise Alarm',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            'Turn your screen into a sunrise',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Obx(
            () => Switch(
              activeColor: kprimaryColor,
              value: controller.isSunriseEnabled.value,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                controller.isSunriseEnabled.value = value;
              },
            ),
          ),
        ),
        Obx(
          () => controller.isSunriseEnabled.value
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Duration before alarm',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  controller.decrementSunriseDuration();
                                },
                              ),
                              Obx(
                                () => Text(
                                  '${controller.sunriseDuration.value} min',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  controller.incrementSunriseDuration();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Ambient sound',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                            () => controller.ambientSoundType.value != 'None'
                                ? IconButton(
                                    icon: const Icon(Icons.play_circle_outline),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      controller.previewAmbientSound();
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Obx(
                            () => Text(
                              controller.ambientSoundType.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _showSoundOptions(context);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        print("Tapped on ambient sound row");
                        HapticFeedback.lightImpact();
                        _showSoundOptions(context);
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showSoundOptions(BuildContext context) {
    print("Opening sound options modal...");
    // Print available sound types to debug
    print("Available sound types: ${controller.getAmbientSoundTypes()}");
    
    try {
      // Use Get.context if available, otherwise fall back to provided context
      final effectiveContext = Get.context ?? context;
      
      showModalBottomSheet(
        context: effectiveContext,
        backgroundColor: themeController.secondaryBackgroundColor.value ?? Colors.grey[200],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Select Ambient Sound',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.getAmbientSoundTypes().length,
                        itemBuilder: (context, index) {
                          final soundType = controller.getAmbientSoundTypes()[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            title: Text(
                              soundType,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            trailing: Obx(
                              () => controller.ambientSoundType.value == soundType
                                  ? const Icon(
                                      Icons.check,
                                      color: kprimaryColor,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            onTap: () {
                              print("Selected sound type: $soundType");
                              HapticFeedback.lightImpact();
                              controller.ambientSoundType.value = soundType;
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ).then((value) {
        print("Modal sheet closed with value: $value");
      }).catchError((error) {
        print("Error showing modal: $error");
      });
    } catch (e) {
      print("Exception when showing modal: $e");
      // Fallback approach using Get.bottomSheet if the standard approach fails
      Get.bottomSheet(
        Container(
          height: Get.height * 0.5,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: themeController.secondaryBackgroundColor.value ?? Colors.grey[200],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Ambient Sound',
                  style: Get.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.getAmbientSoundTypes().length,
                  itemBuilder: (context, index) {
                    final soundType = controller.getAmbientSoundTypes()[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      title: Text(
                        soundType,
                        style: Get.textTheme.bodyLarge,
                      ),
                      trailing: Obx(
                        () => controller.ambientSoundType.value == soundType
                            ? const Icon(
                                Icons.check,
                                color: kprimaryColor,
                              )
                            : const SizedBox.shrink(),
                      ),
                      onTap: () {
                        print("Selected sound type: $soundType");
                        HapticFeedback.lightImpact();
                        controller.ambientSoundType.value = soundType;
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
      );
    }
  }
} 