import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/views/google_assistant_demo.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class EnableGoogleAssistant extends StatelessWidget {
  // Helper method to show the Google Assistant info dialog
  void _showGoogleAssistantInfoDialog(BuildContext context, ThemeController themeController) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          // Using a darker background for better contrast with text
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  'How to Use Google Assistant'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Voice commands section title
                Text(
                  'Voice Commands:'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Command examples
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Set alarm example
                        _buildCommandItem(
                          'Set an alarm:'.tr,
                          '"Hey Google, set an alarm for 7:30 AM tomorrow in Ultimate Alarm Clock"'.tr,
                          themeController,
                        ),
                        
                        // Set daily alarm example
                        _buildCommandItem(
                          'Set a daily alarm:'.tr,
                          '"Hey Google, set a daily alarm for 6:00 AM labeled \'Work\' in Ultimate Alarm Clock"'.tr,
                          themeController,
                        ),
                        
                        // Cancel alarm example
                        _buildCommandItem(
                          'Cancel an alarm:'.tr,
                          '"Hey Google, cancel my \'Work\' alarm in Ultimate Alarm Clock"'.tr,
                          themeController,
                        ),
                        
                        // Enable/disable alarm example
                        _buildCommandItem(
                          'Enable/disable an alarm:'.tr,
                          '"Hey Google, disable my \'Weekend\' alarm in Ultimate Alarm Clock"'.tr,
                          themeController,
                        ),
                        
                        // Integration note
                        const SizedBox(height: 16),
                        Text(
                          'Note: Created alarms will use your Negative Condition and Sunrise Alarm settings.'.tr,
                          style: TextStyle(
                            // Using a bright green color for the note to make it stand out
                            color: Colors.green[400],
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Utils.hapticFeedback();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close'.tr,
                      style: TextStyle(
                        color: themeController.primaryColor.value,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Helper method to build a command item in the dialog
  Widget _buildCommandItem(String title, String command, ThemeController themeController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            command,
            style: TextStyle(
              // Using a brighter color for better visibility on dark backgrounds
              color: themeController.primaryColor.value.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  final SettingsController controller;
  final ThemeController themeController;
  final double height;
  final double width;

  const EnableGoogleAssistant({
    Key? key,
    required this.controller,
    required this.themeController,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * 0.08,
      width: width * 0.9,
      decoration: BoxDecoration(
        color: themeController.secondaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        'Google Assistant'.tr,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: themeController.primaryTextColor.value,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        'Control alarms with voice'.tr,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              // Using a brighter color for better visibility
                              color: themeController.primaryColor.value.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Demo button
                    Obx(
                      () => controller.isGoogleAssistantEnabled.value
                          ? IconButton(
                              icon: Icon(
                                Icons.smart_toy,
                                color: themeController.primaryColor.value,
                                size: 20,
                              ),
                              onPressed: () {
                                Utils.hapticFeedback();
                                Get.to(() => GoogleAssistantDemo());
                              },
                              tooltip: 'View Demo'.tr,
                            )
                          : const SizedBox.shrink(),
                    ),
                    // Info button
                    IconButton(
                      icon: Obx(
                        () => Icon(
                          Icons.info_outline,
                          color: themeController.primaryColor.value,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        Utils.hapticFeedback();
                        _showGoogleAssistantInfoDialog(context, themeController);
                      },
                    ),
                  ],
                ),
              ],
            ),
            Obx(
              () => Switch(
                activeColor: themeController.primaryColor.value,
                value: controller.isGoogleAssistantEnabled.value,
                onChanged: (bool value) {
                  Utils.hapticFeedback();
                  controller.toggleGoogleAssistant(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
