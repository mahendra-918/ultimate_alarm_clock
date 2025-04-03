import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/secure_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/home/controllers/home_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/time_of_day_extension.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

/// Service to handle Google Assistant commands for the Ultimate Alarm Clock app.
class GoogleAssistantService extends GetxService {
  // This must match the CHANNEL_GOOGLE_ASSISTANT constant in MainActivity.kt
  static const platform = MethodChannel('google_assistant');
  
  @override
  void onInit() {
    super.onInit();
    _setupMethodChannel();
  }
  
  /// Sets up the method channel to receive commands from Google Assistant.
  void _setupMethodChannel() {
    platform.setMethodCallHandler(_handleMethodCall);
  }
  
  /// Handles method calls from the native platform.
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'handleGoogleAssistant') {
      // Check if Google Assistant integration is enabled in settings
      final bool isEnabled = await _isGoogleAssistantEnabled();
      if (!isEnabled) {
        print('Google Assistant integration is disabled in settings');
        return false;
      }
      return _handleGoogleAssistantCommand(call.arguments);
    }
    return null;
  }
  
  /// Checks if Google Assistant integration is enabled in settings
  Future<bool> _isGoogleAssistantEnabled() async {
    try {
      // Try to find the settings controller
      SettingsController? settingsController;
      try {
        settingsController = Get.find<SettingsController>();
        return settingsController.isGoogleAssistantEnabled.value;
      } catch (e) {
        // If settings controller is not available, check secure storage directly
        final secureStorage = SecureStorageProvider();
        return await secureStorage.readHapticFeedbackValue(key: 'google_assistant');
      }
    } catch (e) {
      // Default to enabled if there's an error
      print('Error checking Google Assistant preference: $e');
      return true;
    }
  }
  
  /// Handles Google Assistant commands.
  Future<dynamic> _handleGoogleAssistantCommand(dynamic arguments) async {
    try {
      final Map<dynamic, dynamic> args = arguments;
      final String command = args['command'];
      
      switch (command) {
        case 'create_alarm':
          return _handleCreateAlarm(args);
        case 'cancel_alarm':
          return _handleCancelAlarm(args);
        case 'enable_alarm':
          return _handleEnableAlarm(args);
        case 'disable_alarm':
          return _handleDisableAlarm(args);
        default:
          return false;
      }
    } catch (e) {
      print('Error handling Google Assistant command: $e');
      return false;
    }
  }
  
  /// Handles the create alarm command.
  Future<bool> _handleCreateAlarm(Map<dynamic, dynamic> args) async {
    try {
      final String time = args['time'];
      final String label = args['label'];
      final List<dynamic> daysData = args['days'];
      
      // Convert days to List<bool>
      final List<bool> days = List<bool>.from(daysData);
      
      // Create a new alarm
      final timeOfDay = Utils.stringToTimeOfDay(time);
      final minutesSinceMidnight = Utils.timeOfDayToInt(timeOfDay);
      
      // Generate a unique alarm ID
      final alarmID = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create the alarm model
      final AlarmModel alarmModel = AlarmModel(
        alarmTime: time,
        alarmID: alarmID,
        ownerId: '', // Set to empty as this is a local alarm
        ownerName: '', // Set to empty as this is a local alarm
        lastEditedUserId: '', // Set to empty as this is a local alarm
        mutexLock: false,
        days: days,
        intervalToAlarm: 30, // Default value
        isActivityEnabled: false,
        minutesSinceMidnight: minutesSinceMidnight,
        isLocationEnabled: false,
        isSharedAlarmEnabled: false,
        isWeatherEnabled: false,
        location: '',
        weatherTypes: [0, 1, 2], // Default weather types
        isMathsEnabled: false,
        mathsDifficulty: 1,
        numMathsQuestions: 3,
        isShakeEnabled: false,
        shakeTimes: 10,
        isQrEnabled: false,
        qrValue: '',
        isPedometerEnabled: false,
        numberOfSteps: 100,
        activityInterval: 30,
        mainAlarmTime: time,
        label: label,
        isOneTime: false,
        snoozeDuration: 5,
        gradient: 0,
        ringtoneName: 'Default',
        note: '',
        deleteAfterGoesOff: false,
        showMotivationalQuote: false,
        volMax: 1.0,
        volMin: 0.5,
        activityMonitor: 0,
        ringOn: true,
        alarmDate: DateTime.now().toString(),
        profile: 'Default',
        isGuardian: false,
        guardianTimer: 0,
        guardian: '',
        isCall: false,
      );
      
      // Save the alarm
      await IsarDb.addAlarm(alarmModel);
      
      // Schedule the alarm using the HomeController
      final homeController = Get.find<HomeController>();
      final intervalToAlarm = Utils.getMillisecondsToAlarm(
        DateTime.now(),
        Utils.stringToTimeOfDay(time).toDateTime(),
      );
      
      await homeController.alarmChannel.invokeMethod('scheduleAlarm', {
        'interval': intervalToAlarm,
        'isActivity': alarmModel.isActivityEnabled ? 1 : 0,
        'isLocation': alarmModel.isLocationEnabled ? 1 : 0,
        'location': alarmModel.location,
        'isWeather': alarmModel.isWeatherEnabled ? 1 : 0,
        'weatherTypes': alarmModel.weatherTypes.toString(),
      });
      
      return true;
    } catch (e) {
      print('Error creating alarm: $e');
      return false;
    }
  }
  
  /// Handles the cancel alarm command.
  Future<bool> _handleCancelAlarm(Map<dynamic, dynamic> args) async {
    try {
      final String label = args['label'];
      
      // Find alarms with the given label
      final alarmsMap = await IsarDb.getProfileAlarms();
      final List<AlarmModel> allAlarms = [];
      
      // Convert the map to a list of AlarmModel objects
      alarmsMap.forEach((key, value) {
        if (value is List<AlarmModel>) {
          allAlarms.addAll(value);
        }
      });
      
      final alarmsWithLabel = allAlarms.where((alarm) => 
        alarm.label.toLowerCase() == label.toLowerCase()
      ).toList();
      
      if (alarmsWithLabel.isEmpty) {
        return false;
      }
      
      // Delete all alarms with the given label
      for (final alarm in alarmsWithLabel) {
        await IsarDb.deleteAlarm(alarm.isarId);
      }
      
      return true;
    } catch (e) {
      print('Error canceling alarm: $e');
      return false;
    }
  }
  
  /// Handles the enable alarm command.
  Future<bool> _handleEnableAlarm(Map<dynamic, dynamic> args) async {
    try {
      final String label = args['label'];
      
      // Find alarms with the given label
      final alarmsMap = await IsarDb.getProfileAlarms();
      final List<AlarmModel> allAlarms = [];
      
      // Convert the map to a list of AlarmModel objects
      alarmsMap.forEach((key, value) {
        if (value is List<AlarmModel>) {
          allAlarms.addAll(value);
        }
      });
      
      final alarmsWithLabel = allAlarms.where((alarm) => 
        alarm.label.toLowerCase() == label.toLowerCase()
      ).toList();
      
      if (alarmsWithLabel.isEmpty) {
        return false;
      }
      
      // Enable all alarms with the given label
      for (final alarm in alarmsWithLabel) {
        alarm.isEnabled = true;
        await IsarDb.updateAlarm(alarm);
        
        // Reschedule the alarm using the HomeController
        final homeController = Get.find<HomeController>();
        final intervalToAlarm = Utils.getMillisecondsToAlarm(
          DateTime.now(),
          Utils.stringToTimeOfDay(alarm.alarmTime).toDateTime(),
        );
        
        await homeController.alarmChannel.invokeMethod('scheduleAlarm', {
          'interval': intervalToAlarm,
          'isActivity': alarm.isActivityEnabled ? 1 : 0,
          'isLocation': alarm.isLocationEnabled ? 1 : 0,
          'location': alarm.location,
          'isWeather': alarm.isWeatherEnabled ? 1 : 0,
          'weatherTypes': alarm.weatherTypes.toString(),
        });
      }
      
      return true;
    } catch (e) {
      print('Error enabling alarm: $e');
      return false;
    }
  }
  
  /// Handles the disable alarm command.
  Future<bool> _handleDisableAlarm(Map<dynamic, dynamic> args) async {
    try {
      final String label = args['label'];
      
      // Find alarms with the given label
      final alarmsMap = await IsarDb.getProfileAlarms();
      final List<AlarmModel> allAlarms = [];
      
      // Convert the map to a list of AlarmModel objects
      alarmsMap.forEach((key, value) {
        if (value is List<AlarmModel>) {
          allAlarms.addAll(value);
        }
      });
      
      final alarmsWithLabel = allAlarms.where((alarm) => 
        alarm.label.toLowerCase() == label.toLowerCase()
      ).toList();
      
      if (alarmsWithLabel.isEmpty) {
        return false;
      }
      
      // Disable all alarms with the given label
      for (final alarm in alarmsWithLabel) {
        alarm.isEnabled = false;
        await IsarDb.updateAlarm(alarm);
      }
      
      return true;
    } catch (e) {
      print('Error disabling alarm: $e');
      return false;
    }
  }
}
