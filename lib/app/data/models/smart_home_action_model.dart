import 'package:isar/isar.dart';
import 'package:ultimate_alarm_clock/app/data/models/smart_home_device_model.dart';

part 'smart_home_action_model.g.dart';

/// Trigger points for smart home actions
enum ActionTrigger {
  beforeAlarm, // Execute before alarm rings
  duringAlarm, // Execute when alarm starts ringing
  afterAlarmDismiss, // Execute after alarm is dismissed
  afterAlarmSnooze, // Execute after alarm is snoozed
}

@collection
class SmartHomeActionModel {
  Id id = Isar.autoIncrement;

  /// Associated alarm ID
  late String alarmId;

  /// Device ID this action controls
  late String deviceId;

  /// Action to perform
  @enumerated
  late SmartDeviceAction action;

  /// When to trigger this action
  @enumerated
  late ActionTrigger trigger;

  /// Minutes before/after alarm to trigger (for beforeAlarm and afterAlarmDismiss)
  int? offsetMinutes;

  /// Action parameters stored as JSON (brightness level, color, temperature, etc.)
  String? actionParameters;

  /// Whether this action is enabled
  late bool isEnabled;

  SmartHomeActionModel({
    this.id = Isar.autoIncrement,
    required this.alarmId,
    required this.deviceId,
    required this.action,
    required this.trigger,
    this.offsetMinutes,
    this.actionParameters,
    required this.isEnabled,
  });

  /// Create a map representation of the action
  Map<String, dynamic> toMap() {
    return {
      'alarmId': alarmId,
      'deviceId': deviceId,
      'action': action.index,
      'trigger': trigger.index,
      'offsetMinutes': offsetMinutes,
      'actionParameters': actionParameters,
      'isEnabled': isEnabled,
    };
  }

  /// Create an action from a map
  factory SmartHomeActionModel.fromMap(Map<String, dynamic> map) {
    return SmartHomeActionModel(
      alarmId: map['alarmId'],
      deviceId: map['deviceId'],
      action: SmartDeviceAction.values[map['action']],
      trigger: ActionTrigger.values[map['trigger']],
      offsetMinutes: map['offsetMinutes'],
      actionParameters: map['actionParameters'],
      isEnabled: map['isEnabled'],
    );
  }
}
