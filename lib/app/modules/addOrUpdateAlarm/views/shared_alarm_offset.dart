import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class SharedAlarmOffset extends StatelessWidget {
  const SharedAlarmOffset({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => (controller.isSharedAlarmEnabled.value)
          ? Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your Alarm Offset',
                          style: TextStyle(
                            color: themeController.primaryTextColor.value,
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
                          _showOffsetInfoBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Utils.hapticFeedback();
                    _showOffsetSelector(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: themeController.primaryBackgroundColor.value,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: themeController.primaryColor.value.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Obx(() => 
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          controller.isOffsetBefore.value 
                                            ? Icons.arrow_back : Icons.arrow_forward,
                                          color: ksecondaryColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            '${controller.offsetDuration.value} min ${controller.isOffsetBefore.value ? 'before' : 'after'} main time',
                                            style: TextStyle(
                                              color: themeController.primaryTextColor.value,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Your time: ${_getOffsetTime()}',
                                  style: TextStyle(
                                    color: themeController.primaryTextColor.value,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: themeController.primaryTextColor.value.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }

  String _getOffsetTime() {
    if (controller.offsetDuration.value == 0) {
      return controller.alarmRecord.value.alarmTime;
    }
    
    // Parse main alarm time
    final mainTimeStr = controller.alarmRecord.value.alarmTime;
    final timeParts = mainTimeStr.split(':');
    if (timeParts.length < 2) return mainTimeStr;
    
    int hours = int.tryParse(timeParts[0]) ?? 0;
    int minutes = int.tryParse(timeParts[1].split(' ')[0]) ?? 0;
    final isPM = mainTimeStr.toLowerCase().contains('pm');
    
    if (isPM && hours < 12) hours += 12;
    if (!isPM && hours == 12) hours = 0;
    
    // Calculate total minutes
    int totalMinutes = hours * 60 + minutes;
    
    // Apply offset
    if (controller.isOffsetBefore.value) {
      totalMinutes -= controller.offsetDuration.value;
    } else {
      totalMinutes += controller.offsetDuration.value;
    }
    
    // Convert back to hours and minutes
    totalMinutes = totalMinutes % (24 * 60); // Handle wrap around
    if (totalMinutes < 0) totalMinutes += 24 * 60;
    
    hours = totalMinutes ~/ 60;
    minutes = totalMinutes % 60;
    
    // Format time
    final newIsPM = hours >= 12;
    hours = hours % 12;
    if (hours == 0) hours = 12;
    
    return '${hours}:${minutes.toString().padLeft(2, '0')} ${newIsPM ? 'PM' : 'AM'}';
  }

  void _showOffsetSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeController.secondaryBackgroundColor.value,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Minutes',
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => 
                Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbColor: ksecondaryColor,
                        activeTrackColor: ksecondaryColor,
                        inactiveTrackColor: themeController.primaryTextColor.value.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      ),
                      child: Slider(
                        value: controller.offsetDuration.value.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 12,
                        onChanged: (value) {
                          controller.offsetDuration.value = value.toInt();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0', style: TextStyle(color: themeController.primaryTextColor.value)),
                        Text('15', style: TextStyle(color: themeController.primaryTextColor.value)),
                        Text('30', style: TextStyle(color: themeController.primaryTextColor.value)),
                        Text('45', style: TextStyle(color: themeController.primaryTextColor.value)),
                        Text('60', style: TextStyle(color: themeController.primaryTextColor.value)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '${controller.offsetDuration.value} min',
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeController.primaryTextColor.value.withOpacity(0.1),
                              foregroundColor: themeController.primaryTextColor.value,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Utils.hapticFeedback();
                              controller.isOffsetBefore.value = true;
                              Get.back();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: controller.isOffsetBefore.value ? ksecondaryColor : themeController.primaryTextColor.value,
                                ),
                                const SizedBox(width: 8),
                                Text('Before', style: TextStyle(
                                  color: controller.isOffsetBefore.value ? ksecondaryColor : themeController.primaryTextColor.value,
                                )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ksecondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Utils.hapticFeedback();
                              controller.isOffsetBefore.value = false;
                              Get.back();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('After'),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOffsetInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeController.secondaryBackgroundColor.value,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How your offset works:',
                style: TextStyle(
                  color: themeController.primaryDisabledTextColor.value,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeController.primaryColor.value.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm,
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Main alarm: ${controller.alarmRecord.value.alarmTime}',
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ksecondaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm,
                      color: ksecondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => 
                    Text(
                      'Your alarm: ${_getOffsetTime()} ${controller.offsetDuration.value > 0 ? "(${controller.offsetDuration.value} min ${controller.isOffsetBefore.value ? 'before' : 'after'})" : ""}',
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
} 