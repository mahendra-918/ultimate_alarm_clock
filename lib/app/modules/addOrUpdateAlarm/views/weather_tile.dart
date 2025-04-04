import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/views/condition_explanation_widget.dart';

class WeatherTile extends StatelessWidget {
  const WeatherTile({
    Key? key,
    required this.controller,
    required this.themeController,
  }) : super(key: key);

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Obx(
      () => Column(
        children: [
          // Main weather tile with toggle
          ListTile(
            title: Row(
              children: [
                FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Weather Condition'.tr,
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                      fontWeight: FontWeight.w500,
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
                      title: 'Weather based alarm',
                      description: 'This feature uses current weather conditions to determine whether to ring the alarm or not. You can set it to ring only when specific weather types are present or when they are NOT present.',
                      iconData: Icons.cloudy_snowing,
                      isLightMode: themeController.currentTheme.value == ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
            trailing: Switch(
              value: controller.isWeatherEnabled.value || controller.isNegativeWeatherEnabled.value,
              onChanged: (value) async {
                Utils.hapticFeedback();
                await controller.checkAndRequestPermission();
                if (value) {
                  // Default to positive weather condition when turning on
                  controller.isWeatherEnabled.value = true;
                  controller.isNegativeWeatherEnabled.value = false;
                } else {
                  // Turn off both weather conditions
                  controller.isWeatherEnabled.value = false;
                  controller.isNegativeWeatherEnabled.value = false;
                }
              },
              activeColor: kprimaryColor,
            ),
          ),
          
          // Additional settings that show only when weather is enabled
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: (controller.isWeatherEnabled.value || controller.isNegativeWeatherEnabled.value)
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
                          title: "Weather Condition Types",
                          positiveExplanation: 
                              "When 'Ring WHEN weather matches' is selected, the alarm will ONLY ring if the current weather matches one of your selected weather types.",
                          negativeExplanation: 
                              "When 'Ring when weather does NOT match' is selected, the alarm will ONLY ring if the current weather does NOT match any of your selected weather types.",
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
                                'Condition Type:',
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
                                  controller.isWeatherEnabled.value = true;
                                  controller.isNegativeWeatherEnabled.value = false;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: controller.isWeatherEnabled.value 
                                        ? kprimaryColor.withOpacity(0.15) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: controller.isWeatherEnabled.value 
                                          ? kprimaryColor 
                                          : themeController.primaryTextColor.value.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        controller.isWeatherEnabled.value 
                                            ? Icons.radio_button_checked 
                                            : Icons.radio_button_unchecked,
                                        color: controller.isWeatherEnabled.value 
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
                                              'Ring WHEN weather matches',
                                              style: TextStyle(
                                                color: themeController.primaryTextColor.value,
                                                fontWeight: controller.isWeatherEnabled.value 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Alarm will only sound during selected weather conditions',
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
                                  controller.isWeatherEnabled.value = false;
                                  controller.isNegativeWeatherEnabled.value = true;
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: controller.isNegativeWeatherEnabled.value 
                                        ? Colors.redAccent.withOpacity(0.1) 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: controller.isNegativeWeatherEnabled.value 
                                          ? Colors.redAccent 
                                          : themeController.primaryTextColor.value.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        controller.isNegativeWeatherEnabled.value 
                                            ? Icons.radio_button_checked 
                                            : Icons.radio_button_unchecked,
                                        color: controller.isNegativeWeatherEnabled.value 
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
                                              'Ring when weather does NOT match',
                                              style: TextStyle(
                                                color: themeController.primaryTextColor.value,
                                                fontWeight: controller.isNegativeWeatherEnabled.value 
                                                    ? FontWeight.bold 
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Alarm will only sound when current weather differs from selection',
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
                  
                  // Weather types section with enhanced visuals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Weather Types:',
                          style: TextStyle(
                            color: themeController.primaryTextColor.value,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        WeatherOption(
                          type: WeatherTypes.sunny,
                          label: 'Sunny',
                          controller: controller,
                          themeController: themeController,
                        ),
                        WeatherOption(
                          type: WeatherTypes.cloudy,
                          label: 'Cloudy',
                          controller: controller,
                          themeController: themeController,
                        ),
                        WeatherOption(
                          type: WeatherTypes.rainy,
                          label: 'Rainy',
                          controller: controller,
                          themeController: themeController,
                        ),
                        WeatherOption(
                          type: WeatherTypes.windy,
                          label: 'Windy',
                          controller: controller,
                          themeController: themeController,
                        ),
                        WeatherOption(
                          type: WeatherTypes.stormy,
                          label: 'Stormy',
                          controller: controller,
                          themeController: themeController,
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

class WeatherOption extends StatelessWidget {
  final WeatherTypes type;
  final String label;
  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  const WeatherOption({
    Key? key,
    required this.type,
    required this.label,
    required this.controller,
    required this.themeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Utils.hapticFeedback();
        if (controller.selectedWeather.contains(type)) {
          controller.selectedWeather.remove(type);
        } else {
          controller.selectedWeather.add(type);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Row(
          children: [
            Obx(
              () => Checkbox.adaptive(
                side: BorderSide(
                  width: width * 0.0015,
                  color:
                      themeController.primaryTextColor.value.withOpacity(0.5),
                ),
                value: controller.selectedWeather.contains(type),
                activeColor: kprimaryColor.withOpacity(0.8),
                onChanged: (value) {
                  Utils.hapticFeedback();
                  if (controller.selectedWeather.contains(type)) {
                    controller.selectedWeather.remove(type);
                  } else {
                    controller.selectedWeather.add(type);
                  }
                },
              ),
            ),
            Text(
              label.tr,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 15,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
