# Enhanced Snooze Customization

I will implement the enhanced snooze customization feature with a focus on creating an intuitive interface while ensuring robust functionality. The implementation will extend the existing snooze system to support advanced configuration including maximum snooze count limits and gradually decreasing snooze durations.

```json
{
  "snoozeDuration": 5,
  "maxSnoozeCount": 3,
  "smartSnoozeEnabled": true,
  "smartSnoozeDecrement": 1,
  "minSmartSnoozeDuration": 2,
  "currentSnoozeCount": 0,
  "snoozeHistory": [
    {
      "timestamp": "2023-08-15T07:30:00.000Z",
      "duration": 5
    }
  ]
}
```

This model allows for comprehensive control over the snooze behavior while maintaining backward compatibility with existing alarms. Each alarm can have its own independent snooze settings for maximum personalization.

## UI Implementation

I will create a unified snooze settings interface by consolidating the existing snooze duration tile and enhanced snooze tile into a single component:

```dart
class MergedSnoozeTile extends StatelessWidget {
  const MergedSnoozeTile({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () {
          Utils.hapticFeedback();
          _openSnoozeSettingsScreen(context);
        },
        child: ListTile(
          title: Text(
            'Snooze Settings'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          subtitle: Text(
            controller.snoozeDuration.value > 0
              ? 'Duration: ${controller.snoozeDuration.value} min${_getAdditionalSnoozeInfo()}'
              : 'Snooze disabled'.tr,
            style: TextStyle(
              color: themeController.primaryDisabledTextColor.value,
            ),
          ),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Show smart snooze icon if enabled
              if (controller.smartSnoozeEnabled.value)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.trending_down,
                    color: kprimaryColor,
                    size: 20,
                  ),
                ),
              
              // Show max snooze count if set
              if (controller.maxSnoozeCount.value > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${controller.maxSnoozeCount.value}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              Icon(
                Icons.chevron_right,
                color: themeController.primaryDisabledTextColor.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

The settings screen will open as a full-screen interface with section-specific controls for each aspect of snooze customization:

## Basic Snooze Duration

For the basic snooze duration, I'll implement a number picker that allows selection from 0-60 minutes:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Obx(
      () => NumberPicker(
        value: controller.snoozeDuration.value <= 0
            ? 0
            : controller.snoozeDuration.value,
        minValue: 0,
        maxValue: 60,
        onChanged: (value) {
          Utils.hapticFeedback();
          controller.snoozeDuration.value = value;
        },
        textStyle: TextStyle(
          color: themeController.primaryDisabledTextColor.value,
          fontSize: 22,
        ),
        selectedTextStyle: TextStyle(
          color: kprimaryColor,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    const SizedBox(width: 12),
    Obx(
      () => Text(
        controller.snoozeDuration.value > 0
        ? controller.snoozeDuration.value > 1
            ? 'minutes'.tr
            : 'minute'.tr
        : 'Off'.tr,
        style: TextStyle(
          color: themeController.primaryTextColor.value,
          fontSize: 18,
        ),
      ),
    ),
  ],
)
```

## Maximum Snooze Count

For limiting the number of snoozes allowed, I'll add a control with clear visual feedback:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: Icon(Icons.remove_circle_outline, color: kprimaryColor, size: 32),
      onPressed: () {
        Utils.hapticFeedback();
        if (controller.maxSnoozeCount.value > 0) {
          controller.maxSnoozeCount.value--;
        }
      },
    ),
    SizedBox(
      width: 80,
      child: Center(
        child: Obx(() {
          return Text(
            controller.maxSnoozeCount.value == 0
                ? '∞'
                : '${controller.maxSnoozeCount.value}',
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
    ),
    IconButton(
      icon: Icon(Icons.add_circle_outline, color: kprimaryColor, size: 32),
      onPressed: () {
        Utils.hapticFeedback();
        if (controller.maxSnoozeCount.value < 10) {
          controller.maxSnoozeCount.value++;
        }
      },
    ),
  ],
)
```

## Smart Snooze Implementation

The Smart Snooze feature will be implemented with a toggle switch and additional settings:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Snooze',
          style: TextStyle(
            color: themeController.primaryTextColor.value, 
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          'Gradually decrease snooze duration',
          style: TextStyle(
            color: themeController.primaryDisabledTextColor.value, 
            fontSize: 14
          ),
        ),
      ],
    ),
    Obx(() {
      return Switch(
        value: controller.smartSnoozeEnabled.value,
        onChanged: (value) {
          Utils.hapticFeedback();
          controller.smartSnoozeEnabled.value = value;
        },
        activeColor: kprimaryColor,
      );
    }),
  ],
)
```

## Alarm Ring Controller Logic

The alarm ring controller will be enhanced with Smart Snooze calculation logic:

```dart
int calculateNextSnoozeDuration() {
  if (!currentlyRingingAlarm.value.smartSnoozeEnabled) {
    return currentlyRingingAlarm.value.snoozeDuration;
  }
  
  int decrementedDuration = currentlyRingingAlarm.value.snoozeDuration - 
      (currentSnoozeCount.value * currentlyRingingAlarm.value.smartSnoozeDecrement);
  
  return math.max(decrementedDuration, currentlyRingingAlarm.value.minSmartSnoozeDuration);
}
```

And maximum snooze count enforcement:

```dart
void startSnooze() async {
  Vibration.cancel();
  vibrationTimer!.cancel();
  isSnoozing.value = true;
  String ringtoneName = currentlyRingingAlarm.value.ringtoneName;
  AudioUtils.stopAlarm(ringtoneName: ringtoneName);

  if (_currentTimeTimer!.isActive) {
    _currentTimeTimer?.cancel();
  }

  if (currentlyRingingAlarm.value.maxSnoozeCount > 0 && 
      currentSnoozeCount.value >= currentlyRingingAlarm.value.maxSnoozeCount) {
    Get.snackbar(
      'Maximum Snooze Reached',
      'You\'ve reached the maximum number of snoozes for this alarm',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  currentSnoozeCount.value++;
  
  currentlyRingingAlarm.value.currentSnoozeCount = currentSnoozeCount.value;
  
  var snoozeEvent = {
    'timestamp': DateTime.now().toIso8601String(),
    'duration': minutes.value,
  };
  currentlyRingingAlarm.value.snoozeHistory.add(snoozeEvent);
  
  // Update database with current snooze state
  if (!isPreviewMode.value) {
    if (currentlyRingingAlarm.value.isSharedAlarmEnabled) {
      await FirestoreDb.updateAlarm(
        currentlyRingingAlarm.value.ownerId,
        currentlyRingingAlarm.value,
      );
    } else {
      await IsarDb.updateAlarm(currentlyRingingAlarm.value);
    }
  }
  
  // Start snooze countdown timer
  _currentTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (minutes.value == 0 && seconds.value == 0) {
      timer.cancel();
      // Resume alarm after snooze period ends
      vibrationTimer = Timer.periodic(const Duration(milliseconds: 3500), (Timer timer) {
        Vibration.vibrate(pattern: [500, 3000]);
      });

      AudioUtils.playAlarm(alarmRecord: currentlyRingingAlarm.value);
      startTimer();
    } else if (seconds.value == 0) {
      minutes.value--;
      seconds.value = 59;
    } else {
      seconds.value--;
    }
  });
}
```

## Data Persistence Implementation

I'll ensure all snooze properties are properly persisted in the database:

```dart
static Map<String, dynamic> toMap(AlarmModel alarmRecord) {
  final alarmMap = <String, dynamic>{
    // ... existing fields ...
    'snoozeDuration': alarmRecord.snoozeDuration,
    'maxSnoozeCount': alarmRecord.maxSnoozeCount,
    'currentSnoozeCount': alarmRecord.currentSnoozeCount,
    'smartSnoozeEnabled': alarmRecord.smartSnoozeEnabled ? 1 : 0,
    'smartSnoozeDecrement': alarmRecord.smartSnoozeDecrement,
    'minSmartSnoozeDuration': alarmRecord.minSmartSnoozeDuration,
    'snoozeHistory': alarmRecord.snoozeHistory
  };

  return alarmMap;
}
```

## Testing Strategy

I will implement comprehensive testing for the enhanced snooze features:

1. **Unit tests** for the Smart Snooze calculation algorithm
2. **Integration tests** verifying proper persistence of snooze state
3. **UI tests** for the snooze settings interface
4. **End-to-end tests** for complete alarm snooze scenarios

## User Feedback and Analytics

To improve the snooze system over time, I'll implement anonymous usage analytics:

```dart
void logSnoozeEvent(AlarmModel alarm) {
  analyticsService.logEvent('alarm_snoozed', {
    'snooze_count': alarm.currentSnoozeCount,
    'smart_snooze_enabled': alarm.smartSnoozeEnabled,
    'max_snooze_count': alarm.maxSnoozeCount,
    'base_duration': alarm.snoozeDuration,
    'calculated_duration': calculateNextSnoozeDuration(),
  });
}
```

## Visual Indicators in Alarm List

I'll enhance the alarm list to show snooze-related visual indicators:

```dart
// In the alarm list item widget
Row(
  children: [
    // ... existing alarm info ...
    if (alarm.smartSnoozeEnabled)
      Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Icon(
          Icons.trending_down,
          color: kprimaryColor,
          size: 16,
        ),
      ),
    if (alarm.maxSnoozeCount > 0)
      Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.snooze,
              color: kprimaryColor,
              size: 16,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: kprimaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${alarm.maxSnoozeCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
  ],
)
```

This implementation will provide users with advanced snooze customization capabilities while maintaining the application's intuitive interface. The snooze settings are designed to be easily configurable while offering sophisticated control over wake-up behavior. 