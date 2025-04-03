import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/smart_home_device_model.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/smart_home/controllers/smart_home_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class SmartHomeView extends StatelessWidget {
  final SmartHomeController controller = Get.find<SmartHomeController>();
  final ThemeController themeController = Get.find<ThemeController>();

  SmartHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Home Devices'.tr,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: themeController.primaryTextColor.value,
                fontWeight: FontWeight.w500,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.adaptive.arrow_back,
            color: themeController.primaryTextColor.value,
          ),
          onPressed: () {
            Utils.hapticFeedback();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: themeController.primaryTextColor.value,
            ),
            onPressed: () {
              Utils.hapticFeedback();
              controller.discoverDevices();
            },
          ),
        ],
      ),
      backgroundColor: themeController.primaryBackgroundColor.value,
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeController.primaryColor.value,
        onPressed: () {
          Utils.hapticFeedback();
          _showAddDeviceDialog(context);
        },
        child: Icon(Icons.add, color: themeController.primaryTextColor.value),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Obx(
        () => controller.isDiscovering.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: themeController.primaryColor.value,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Discovering devices...'.tr,
                      style: TextStyle(
                        color: themeController.primaryTextColor.value,
                      ),
                    ),
                  ],
                ),
              )
            : controller.devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices_other,
                          size: 64,
                          color: themeController.secondaryTextColor.value,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No smart home devices found'.tr,
                          style: TextStyle(
                            color: themeController.primaryTextColor.value,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add a device or refresh to discover'.tr,
                          style: TextStyle(
                            color: themeController.secondaryTextColor.value,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Utils.hapticFeedback();
                            controller.discoverDevices();
                          },
                          icon: Icon(
                            Icons.search,
                            color: themeController.primaryTextColor.value,
                          ),
                          label: Text(
                            'Discover Devices'.tr,
                            style: TextStyle(
                              color: themeController.primaryTextColor.value,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeController.primaryColor.value,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.devices.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final device = controller.devices[index];
                      return _buildDeviceCard(context, device);
                    },
                  ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, SmartHomeDeviceModel device) {
    final deviceTypeIcon = _getDeviceTypeIcon(device.deviceType);
    final platformIcon = _getPlatformIcon(device.platform);

    return GestureDetector(
      onTap: () {
        Utils.hapticFeedback();
        Get.toNamed('/smart-home/device/${device.deviceId}');
      },
      onLongPress: () {
        Utils.hapticFeedback();
        _showDeviceOptionsDialog(context, device);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: themeController.secondaryBackgroundColor.value,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeController.primaryColor.value.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      deviceTypeIcon,
                      color: themeController.primaryColor.value,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.deviceName,
                          style: TextStyle(
                            color: themeController.primaryTextColor.value,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              platformIcon,
                              size: 14,
                              color: themeController.secondaryTextColor.value,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPlatformName(device.platform),
                              style: TextStyle(
                                color: themeController.secondaryTextColor.value,
                                fontSize: 13,
                              ),
                            ),
                            if (device.location != null && device.location!.isNotEmpty) ...[  
                              const SizedBox(width: 12),
                              Icon(
                                Icons.room,
                                size: 14,
                                color: themeController.secondaryTextColor.value,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                device.location!,
                                style: TextStyle(
                                  color: themeController.secondaryTextColor.value,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: device.isConnected 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: device.isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.isConnected ? 'Online'.tr : 'Offline'.tr,
                          style: TextStyle(
                            color: device.isConnected ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: themeController.primaryTextColor.value,
                    onPressed: () {
                      Utils.hapticFeedback();
                      _showDeviceOptionsDialog(context, device);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDeviceTypeIcon(SmartDeviceType type) {
    switch (type) {
      case SmartDeviceType.light:
        return Icons.lightbulb;
      case SmartDeviceType.thermostat:
        return Icons.thermostat;
      case SmartDeviceType.speaker:
        return Icons.speaker;
      case SmartDeviceType.switch_:
        return Icons.toggle_on;
      case SmartDeviceType.outlet:
        return Icons.power;
      case SmartDeviceType.fan:
        return Icons.air;
      case SmartDeviceType.blind:
        return Icons.blinds;
      case SmartDeviceType.other:
        return Icons.devices_other;
    }
  }

  IconData _getPlatformIcon(SmartHomePlatform platform) {
    switch (platform) {
      case SmartHomePlatform.googleHome:
        return Icons.home_filled;
      case SmartHomePlatform.appleHomeKit:
        return Icons.home_filled;
      case SmartHomePlatform.amazonAlexa:
        return Icons.speaker;
      case SmartHomePlatform.smartThings:
        return Icons.devices;
      case SmartHomePlatform.custom:
        return Icons.settings_remote;
    }
  }

  String _getPlatformName(SmartHomePlatform platform) {
    switch (platform) {
      case SmartHomePlatform.googleHome:
        return 'Google Home';
      case SmartHomePlatform.appleHomeKit:
        return 'Apple HomeKit';
      case SmartHomePlatform.amazonAlexa:
        return 'Amazon Alexa';
      case SmartHomePlatform.smartThings:
        return 'SmartThings';
      case SmartHomePlatform.custom:
        return 'Custom Device';
    }
  }

  void _showDeviceOptionsDialog(BuildContext context, SmartHomeDeviceModel device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeController.secondaryBackgroundColor.value,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            device.deviceName,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: themeController.primaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.edit,
                    color: themeController.primaryColor.value,
                  ),
                  title: Text(
                    'Edit Device'.tr,
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                  onTap: () {
                    Utils.hapticFeedback();
                    Navigator.pop(context);
                    _showEditDeviceDialog(context, device);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: themeController.primaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.refresh,
                    color: themeController.primaryColor.value,
                  ),
                  title: Text(
                    'Test Connection'.tr,
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                  onTap: () {
                    Utils.hapticFeedback();
                    Navigator.pop(context);
                    controller.testDeviceConnection(device);
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: themeController.primaryBackgroundColor.value,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Remove Device'.tr,
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                    ),
                  ),
                  onTap: () {
                    Utils.hapticFeedback();
                    Navigator.pop(context);
                    _showDeleteConfirmationDialog(context, device);
                  },
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Utils.hapticFeedback();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeController.primaryColor.value,
                foregroundColor: themeController.primaryTextColor.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Close'.tr),
            ),
          ],
        );
      },
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    final locationController = TextEditingController();
    
    final selectedPlatform = SmartHomePlatform.custom.obs;
    final selectedDeviceType = SmartDeviceType.light.obs;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeController.secondaryBackgroundColor.value,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Device'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: themeController.primaryTextColor.value),
                  decoration: InputDecoration(
                    labelText: 'Device Name'.tr,
                    labelStyle: TextStyle(color: themeController.primaryTextColor.value),
                    hintStyle: TextStyle(color: themeController.primaryTextColor.value.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeController.primaryBackgroundColor.value,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Platform'.tr,
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeController.primaryBackgroundColor.value,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeController.primaryColor.value),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SmartHomePlatform>(
                        dropdownColor: themeController.primaryBackgroundColor.value,
                        value: selectedPlatform.value,
                        isExpanded: true,
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeController.primaryTextColor.value,
                        ),
                        onChanged: (SmartHomePlatform? newValue) {
                          if (newValue != null) {
                            selectedPlatform.value = newValue;
                          }
                        },
                        items: SmartHomePlatform.values.map((platform) {
                          return DropdownMenuItem<SmartHomePlatform>(
                            value: platform,
                            child: Text(
                              _getPlatformName(platform),
                              style: TextStyle(
                                color: themeController.primaryTextColor.value,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Device Type'.tr,
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeController.primaryBackgroundColor.value,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeController.primaryColor.value),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SmartDeviceType>(
                        dropdownColor: themeController.primaryBackgroundColor.value,
                        value: selectedDeviceType.value,
                        isExpanded: true,
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeController.primaryTextColor.value,
                        ),
                        onChanged: (SmartDeviceType? newValue) {
                          if (newValue != null) {
                            selectedDeviceType.value = newValue;
                          }
                        },
                        items: SmartDeviceType.values.map((type) {
                          String typeName = type.toString().split('.').last;
                          if (typeName == 'switch_') typeName = 'switch';
                          return DropdownMenuItem<SmartDeviceType>(
                            value: type,
                            child: Text(
                              typeName.capitalize!,
                              style: TextStyle(
                                color: themeController.primaryTextColor.value,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ipController,
                  style: TextStyle(color: themeController.primaryTextColor.value),
                  decoration: InputDecoration(
                    labelText: 'IP Address (optional)'.tr,
                    labelStyle: TextStyle(color: themeController.primaryTextColor.value),
                    hintStyle: TextStyle(color: themeController.primaryTextColor.value.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeController.primaryBackgroundColor.value,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  style: TextStyle(color: themeController.primaryTextColor.value),
                  decoration: InputDecoration(
                    labelText: 'Location (e.g., Living Room)'.tr,
                    labelStyle: TextStyle(color: themeController.primaryTextColor.value),
                    hintStyle: TextStyle(color: themeController.primaryTextColor.value.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeController.primaryBackgroundColor.value,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Utils.hapticFeedback();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel'.tr,
                style: TextStyle(
                  color: themeController.primaryColor.value,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Utils.hapticFeedback();
                if (nameController.text.isEmpty) {
                  Get.snackbar(
                    'Error'.tr,
                    'Device name is required'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                
                final device = SmartHomeDeviceModel(
                  deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
                  deviceName: nameController.text,
                  platform: selectedPlatform.value,
                  deviceType: selectedDeviceType.value,
                  ipAddress: ipController.text.isNotEmpty ? ipController.text : null,
                  isConnected: true,
                  lastConnected: DateTime.now(),
                  location: locationController.text.isNotEmpty ? locationController.text : null,
                  supportedActions: _getDefaultSupportedActions(selectedDeviceType.value),
                );
                
                controller.saveDevice(device);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeController.primaryColor.value,
                foregroundColor: themeController.primaryTextColor.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add'.tr,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeviceDialog(BuildContext context, SmartHomeDeviceModel device) {
    final nameController = TextEditingController(text: device.deviceName);
    final ipController = TextEditingController(text: device.ipAddress ?? '');
    final locationController = TextEditingController(text: device.location ?? '');
    
    final selectedPlatform = device.platform.obs;
    final selectedDeviceType = device.deviceType.obs;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeController.secondaryBackgroundColor.value,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Device'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: themeController.primaryTextColor.value),
                  decoration: InputDecoration(
                    labelText: 'Device Name'.tr,
                    labelStyle: TextStyle(color: themeController.primaryTextColor.value),
                    hintStyle: TextStyle(color: themeController.primaryTextColor.value.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeController.primaryBackgroundColor.value,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Platform'.tr,
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeController.primaryBackgroundColor.value,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeController.primaryColor.value),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SmartHomePlatform>(
                        dropdownColor: themeController.primaryBackgroundColor.value,
                        value: selectedPlatform.value,
                        isExpanded: true,
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeController.primaryTextColor.value,
                        ),
                        onChanged: (SmartHomePlatform? newValue) {
                          if (newValue != null) {
                            selectedPlatform.value = newValue;
                          }
                        },
                        items: SmartHomePlatform.values.map((platform) {
                          return DropdownMenuItem<SmartHomePlatform>(
                            value: platform,
                            child: Text(
                              _getPlatformName(platform),
                              style: TextStyle(
                                color: themeController.primaryTextColor.value,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Device Type'.tr,
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeController.primaryBackgroundColor.value,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: themeController.primaryColor.value),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SmartDeviceType>(
                        dropdownColor: themeController.primaryBackgroundColor.value,
                        value: selectedDeviceType.value,
                        isExpanded: true,
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeController.primaryTextColor.value,
                        ),
                        onChanged: (SmartDeviceType? newValue) {
                          if (newValue != null) {
                            selectedDeviceType.value = newValue;
                          }
                        },
                        items: SmartDeviceType.values.map((type) {
                          String typeName = type.toString().split('.').last;
                          if (typeName == 'switch_') typeName = 'switch';
                          return DropdownMenuItem<SmartDeviceType>(
                            value: type,
                            child: Text(
                              typeName.capitalize!,
                              style: TextStyle(
                                color: themeController.primaryTextColor.value,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ipController,
                  style: TextStyle(color: themeController.primaryTextColor.value),
                  decoration: InputDecoration(
                    labelText: 'IP Address (optional)'.tr,
                    labelStyle: TextStyle(color: themeController.primaryTextColor.value),
                    hintStyle: TextStyle(color: themeController.primaryTextColor.value.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeController.primaryBackgroundColor.value,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  style: TextStyle(color: themeController.primaryTextColor.value),
                  decoration: InputDecoration(
                    labelText: 'Location (e.g., Living Room)'.tr,
                    labelStyle: TextStyle(color: themeController.primaryTextColor.value),
                    hintStyle: TextStyle(color: themeController.primaryTextColor.value.withOpacity(0.5)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeController.primaryColor.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: themeController.primaryBackgroundColor.value,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Utils.hapticFeedback();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel'.tr,
                style: TextStyle(
                  color: themeController.primaryColor.value,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Utils.hapticFeedback();
                if (nameController.text.isEmpty) {
                  Get.snackbar(
                    'Error'.tr,
                    'Device name is required'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                
                final updatedDevice = SmartHomeDeviceModel(
                  deviceId: device.deviceId,
                  deviceName: nameController.text,
                  platform: selectedPlatform.value,
                  deviceType: selectedDeviceType.value,
                  ipAddress: ipController.text.isNotEmpty ? ipController.text : null,
                  isConnected: device.isConnected,
                  lastConnected: device.lastConnected,
                  location: locationController.text.isNotEmpty ? locationController.text : null,
                  supportedActions: device.supportedActions,
                );
                
                // Preserve the ID
                updatedDevice.id = device.id;
                
                controller.saveDevice(updatedDevice);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeController.primaryColor.value,
                foregroundColor: themeController.primaryTextColor.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save'.tr,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, SmartHomeDeviceModel device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeController.secondaryBackgroundColor.value,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Remove Device'.tr,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeController.primaryBackgroundColor.value,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Are you sure you want to remove ${device.deviceName}? This will also remove any alarm actions associated with this device.'.tr,
              style: TextStyle(
                color: themeController.primaryTextColor.value,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Utils.hapticFeedback();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel'.tr,
                style: TextStyle(
                  color: themeController.primaryColor.value,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Utils.hapticFeedback();
                controller.removeDevice(device.deviceId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Remove'.tr),
            ),
          ],
        );
      },
    );
  }

  List<int> _getDefaultSupportedActions(SmartDeviceType deviceType) {
    final actions = <SmartDeviceAction>[];
    
    // Common actions for all devices
    actions.add(SmartDeviceAction.turnOn);
    actions.add(SmartDeviceAction.turnOff);
    
    // Device-specific actions
    switch (deviceType) {
      case SmartDeviceType.light:
        actions.add(SmartDeviceAction.setBrightness);
        actions.add(SmartDeviceAction.setColor);
        break;
      case SmartDeviceType.thermostat:
        actions.add(SmartDeviceAction.setTemperature);
        break;
      case SmartDeviceType.speaker:
        actions.add(SmartDeviceAction.playSound);
        actions.add(SmartDeviceAction.stopSound);
        actions.add(SmartDeviceAction.setVolume);
        break;
      case SmartDeviceType.blind:
        actions.add(SmartDeviceAction.open);
        actions.add(SmartDeviceAction.close);
        break;
      default:
        break;
    }
    
    return SmartHomeDeviceModel.actionsToIntList(actions);
  }
}
