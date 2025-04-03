import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/smart_home_action_model.dart';
import 'package:ultimate_alarm_clock/app/data/models/smart_home_device_model.dart';
import 'package:ultimate_alarm_clock/app/services/smart_home_service.dart';

class SmartHomeController extends GetxController {
  final SmartHomeService _smartHomeService = Get.find<SmartHomeService>();
  
  final RxList<SmartHomeDeviceModel> devices = <SmartHomeDeviceModel>[].obs;
  final RxBool isDiscovering = false.obs;
  final RxBool isInitialized = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  Future<void> _initializeController() async {
    try {
      // Load devices from the service
      await loadDevices();
      isInitialized.value = true;
    } catch (e) {
      debugPrint('Error initializing SmartHomeController: $e');
    }
  }
  
  Future<void> loadDevices() async {
    try {
      final devicesList = await _smartHomeService.loadDevices();
      devices.assignAll(_smartHomeService.devices);
    } catch (e) {
      debugPrint('Error loading devices: $e');
    }
  }
  
  Future<void> discoverDevices() async {
    try {
      isDiscovering.value = true;
      final discoveredDevices = await _smartHomeService.discoverDevices();
      
      // Show a dialog to add discovered devices
      if (discoveredDevices.isNotEmpty) {
        Get.dialog(
          _buildDiscoveredDevicesDialog(discoveredDevices),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'No Devices Found',
          'No new devices were discovered on your network.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      
      isDiscovering.value = false;
    } catch (e) {
      debugPrint('Error discovering devices: $e');
      isDiscovering.value = false;
      Get.snackbar(
        'Error',
        'Failed to discover devices. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Widget _buildDiscoveredDevicesDialog(List<SmartHomeDeviceModel> discoveredDevices) {
    final selectedDevices = <String, bool>{};
    
    // Initialize all devices as selected
    for (final device in discoveredDevices) {
      // Only select devices that aren't already added
      final alreadyExists = devices.any((d) => d.deviceId == device.deviceId);
      selectedDevices[device.deviceId] = !alreadyExists;
    }
    
    return AlertDialog(
      title: const Text('Discovered Devices'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: discoveredDevices.length,
          itemBuilder: (context, index) {
            final device = discoveredDevices[index];
            final alreadyExists = devices.any((d) => d.deviceId == device.deviceId);
            
            return StatefulBuilder(
              builder: (context, setState) {
                return CheckboxListTile(
                  title: Text(device.deviceName),
                  subtitle: Text(
                    alreadyExists 
                        ? 'Already added' 
                        : '${device.deviceType.toString().split('.').last} (${device.platform.toString().split('.').last})',
                  ),
                  value: selectedDevices[device.deviceId],
                  onChanged: alreadyExists 
                      ? null 
                      : (value) {
                          setState(() {
                            selectedDevices[device.deviceId] = value!;
                          });
                        },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Add selected devices
            for (final device in discoveredDevices) {
              if (selectedDevices[device.deviceId] == true) {
                await saveDevice(device);
              }
            }
            
            Get.back();
            
            Get.snackbar(
              'Devices Added',
              'Successfully added the selected devices.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          child: const Text('Add Selected'),
        ),
      ],
    );
  }
  
  Future<void> saveDevice(SmartHomeDeviceModel device) async {
    try {
      await _smartHomeService.saveDevice(device);
      await loadDevices(); // Refresh the list
    } catch (e) {
      debugPrint('Error saving device: $e');
      Get.snackbar(
        'Error',
        'Failed to save device. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> removeDevice(String deviceId) async {
    try {
      await _smartHomeService.removeDevice(deviceId);
      devices.removeWhere((device) => device.deviceId == deviceId);
      
      Get.snackbar(
        'Device Removed',
        'Successfully removed the device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error removing device: $e');
      Get.snackbar(
        'Error',
        'Failed to remove device. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> testDeviceConnection(SmartHomeDeviceModel device) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final isConnected = await _smartHomeService.testDeviceConnection(device);
      
      Get.back(); // Close the loading dialog
      
      if (isConnected) {
        // Update the device's connection status
        final updatedDevice = SmartHomeDeviceModel(
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          platform: device.platform,
          deviceType: device.deviceType,
          ipAddress: device.ipAddress,
          authToken: device.authToken,
          configData: device.configData,
          isConnected: true,
          lastConnected: DateTime.now(),
          location: device.location,
          supportedActions: device.supportedActions,
        );
        
        // Preserve the ID if it exists
        updatedDevice.id = device.id;
        
        await saveDevice(updatedDevice);
        
        Get.snackbar(
          'Connection Successful',
          'Successfully connected to ${device.deviceName}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Update the device's connection status
        final updatedDevice = SmartHomeDeviceModel(
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          platform: device.platform,
          deviceType: device.deviceType,
          ipAddress: device.ipAddress,
          authToken: device.authToken,
          configData: device.configData,
          isConnected: false,
          lastConnected: device.lastConnected,
          location: device.location,
          supportedActions: device.supportedActions,
        );
        
        // Preserve the ID if it exists
        updatedDevice.id = device.id;
        
        await saveDevice(updatedDevice);
        
        Get.snackbar(
          'Connection Failed',
          'Failed to connect to ${device.deviceName}. Please check the device and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error testing device connection: $e');
      Get.back(); // Close the loading dialog
      
      Get.snackbar(
        'Error',
        'Failed to test connection. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Methods for alarm actions
  Future<List<SmartHomeActionModel>> getActionsForAlarm(String alarmId) async {
    try {
      return await _smartHomeService.getActionsForAlarm(alarmId);
    } catch (e) {
      debugPrint('Error getting actions for alarm: $e');
      return [];
    }
  }
  
  Future<void> saveAction(SmartHomeActionModel action) async {
    try {
      await _smartHomeService.saveAction(action);
    } catch (e) {
      debugPrint('Error saving action: $e');
      Get.snackbar(
        'Error',
        'Failed to save action. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> removeAction(int actionId) async {
    try {
      await _smartHomeService.removeAction(actionId);
    } catch (e) {
      debugPrint('Error removing action: $e');
      Get.snackbar(
        'Error',
        'Failed to remove action. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Execute an action manually (for testing)
  Future<void> executeAction(SmartHomeActionModel action) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      final success = await _smartHomeService.executeAction(action);
      
      Get.back(); // Close the loading dialog
      
      if (success) {
        Get.snackbar(
          'Action Executed',
          'Successfully executed the action.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Action Failed',
          'Failed to execute the action. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error executing action: $e');
      Get.back(); // Close the loading dialog
      
      Get.snackbar(
        'Error',
        'Failed to execute action. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
