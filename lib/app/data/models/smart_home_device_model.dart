import 'package:isar/isar.dart';

part 'smart_home_device_model.g.dart';

/// Supported smart home platforms
enum SmartHomePlatform {
  googleHome,
  appleHomeKit,
  amazonAlexa,
  smartThings,
  custom
}

/// Device types that can be controlled
enum SmartDeviceType {
  light,
  thermostat,
  speaker,
  switch_,
  outlet,
  fan,
  blind,
  other
}

/// Actions that can be performed on devices
enum SmartDeviceAction {
  turnOn,
  turnOff,
  setBrightness,
  setColor,
  setTemperature,
  playSound,
  stopSound,
  setVolume,
  open,
  close
}

@collection
class SmartHomeDeviceModel {
  Id id = Isar.autoIncrement;

  /// Unique identifier for the device
  late String deviceId;

  /// User-friendly name for the device
  late String deviceName;

  /// Platform the device belongs to
  @enumerated
  late SmartHomePlatform platform;

  /// Type of device
  @enumerated
  late SmartDeviceType deviceType;

  /// IP address or URL for local devices
  String? ipAddress;

  /// Authentication token if required
  String? authToken;

  /// Additional configuration data stored as JSON
  String? configData;

  /// Whether the device is currently connected
  late bool isConnected;

  /// Last time the device was successfully connected
  late DateTime lastConnected;

  /// Room or location where the device is located
  String? location;
  
  /// List of supported actions for this device
  List<int>? supportedActions;

  SmartHomeDeviceModel({
    this.id = Isar.autoIncrement,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.deviceType,
    this.ipAddress,
    this.authToken,
    this.configData,
    required this.isConnected,
    required this.lastConnected,
    this.location,
    this.supportedActions,
  });

  /// Convert a list of SmartDeviceAction enums to a list of integers
  static List<int> actionsToIntList(List<SmartDeviceAction> actions) {
    return actions.map((action) => action.index).toList();
  }

  /// Convert a list of integers to a list of SmartDeviceAction enums
  static List<SmartDeviceAction> intListToActions(List<int> indices) {
    return indices.map((index) => SmartDeviceAction.values[index]).toList();
  }

  /// Get supported actions as enum values
  List<SmartDeviceAction> getSupportedActions() {
    if (supportedActions == null || supportedActions!.isEmpty) {
      return [];
    }
    return intListToActions(supportedActions!);
  }

  /// Set supported actions from enum values
  void setSupportedActions(List<SmartDeviceAction> actions) {
    supportedActions = actionsToIntList(actions);
  }

  /// Check if a specific action is supported by this device
  bool supportsAction(SmartDeviceAction action) {
    return supportedActions?.contains(action.index) ?? false;
  }

  /// Create a map representation of the device
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform.index,
      'deviceType': deviceType.index,
      'ipAddress': ipAddress,
      'authToken': authToken,
      'configData': configData,
      'isConnected': isConnected,
      'lastConnected': lastConnected.toIso8601String(),
      'location': location,
      'supportedActions': supportedActions,
    };
  }

  /// Create a device from a map
  factory SmartHomeDeviceModel.fromMap(Map<String, dynamic> map) {
    return SmartHomeDeviceModel(
      deviceId: map['deviceId'],
      deviceName: map['deviceName'],
      platform: SmartHomePlatform.values[map['platform']],
      deviceType: SmartDeviceType.values[map['deviceType']],
      ipAddress: map['ipAddress'],
      authToken: map['authToken'],
      configData: map['configData'],
      isConnected: map['isConnected'],
      lastConnected: DateTime.parse(map['lastConnected']),
      location: map['location'],
      supportedActions: List<int>.from(map['supportedActions'] ?? []),
    );
  }
}
