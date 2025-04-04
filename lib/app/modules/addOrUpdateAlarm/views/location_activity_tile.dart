import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/views/condition_explanation_widget.dart';

class LocationTile extends StatelessWidget {
  const LocationTile({
    super.key,
    required this.controller,
    required this.height,
    required this.width,
    required this.themeController,
  });

  final AddOrUpdateAlarmController controller;
  final ThemeController themeController;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // Main location tile with toggle
          ListTile(
            title: Row(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Location Based'.tr,
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
                    Utils.showModal(
                      context: context,
                      title: 'Location based alarm',
                      description: 'This feature uses your phone\'s location to determine whether to ring the alarm or not. You can set it to ring when you\'re at a specific location or when you\'re NOT at a specific location.',
                      iconData: Icons.location_on,
                      isLightMode: themeController.currentTheme.value == ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
            trailing: Switch(
              value: controller.isLocationEnabled.value || controller.isNegativeLocationEnabled.value,
              onChanged: (value) {
                Utils.hapticFeedback();
                if (value) {
                  // Default to positive location condition when turning on
                  controller.isLocationEnabled.value = true;
                  controller.isNegativeLocationEnabled.value = false;
                  // Remove the automatic dialog opening
                  // if (controller.selectedPoint.value.latitude == 0 && 
                  //     controller.selectedPoint.value.longitude == 0) {
                  //   openLocationDialog();
                  // }
                } else {
                  // Turn off both location conditions
                  controller.isLocationEnabled.value = false;
                  controller.isNegativeLocationEnabled.value = false;
                }
              },
              activeColor: kprimaryColor,
            ),
          ),
          
          // Additional settings that show only when location is enabled
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: controller.isLocationEnabled.value || controller.isNegativeLocationEnabled.value 
              ? Column(
                  children: [
                    // Add explanation helper widget
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Expanded(child: Container()),
                          ConditionExplanationWidget(
                            themeController: themeController,
                            title: "Location Condition Types",
                            positiveExplanation: 
                                "When you select 'When at location', the alarm will ONLY ring if you are within approximately 500 meters of your selected location.",
                            negativeExplanation: 
                                "When you select 'When NOT at location', the alarm will ONLY ring if you are NOT within approximately 500 meters of your selected location.",
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // Condition type selector with improved design
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
                                // Positive condition option with improved visuals
                                InkWell(
                                  onTap: () {
                                    Utils.hapticFeedback();
                                    controller.isLocationEnabled.value = true;
                                    controller.isNegativeLocationEnabled.value = false;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: controller.isLocationEnabled.value 
                                          ? kprimaryColor.withOpacity(0.15) 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: controller.isLocationEnabled.value 
                                            ? kprimaryColor 
                                            : themeController.primaryTextColor.value.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          controller.isLocationEnabled.value 
                                              ? Icons.radio_button_checked 
                                              : Icons.radio_button_unchecked,
                                          color: controller.isLocationEnabled.value 
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
                                                'Ring when at location',
                                                style: TextStyle(
                                                  color: themeController.primaryTextColor.value,
                                                  fontWeight: controller.isLocationEnabled.value 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Alarm will only sound if you are near the set location',
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
                                
                                // Negative condition option with improved visuals
                                InkWell(
                                  onTap: () {
                                    Utils.hapticFeedback();
                                    controller.isLocationEnabled.value = false;
                                    controller.isNegativeLocationEnabled.value = true;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: controller.isNegativeLocationEnabled.value 
                                          ? Colors.redAccent.withOpacity(0.1) 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: controller.isNegativeLocationEnabled.value 
                                            ? Colors.redAccent 
                                            : themeController.primaryTextColor.value.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          controller.isNegativeLocationEnabled.value 
                                              ? Icons.radio_button_checked 
                                              : Icons.radio_button_unchecked,
                                          color: controller.isNegativeLocationEnabled.value 
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
                                                'Ring when NOT at location',
                                                style: TextStyle(
                                                  color: themeController.primaryTextColor.value,
                                                  fontWeight: controller.isNegativeLocationEnabled.value 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Alarm will only sound if you are away from the set location',
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
                    
                    // Choose location button with enhanced design
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Utils.hapticFeedback();
                          openLocationDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kprimaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.location_on),
                        label: const Text('Choose Location', style: TextStyle(fontWeight: FontWeight.bold)),
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
  
  Future<void> openLocationDialog() async {
    // Create a loading state for the map
    final RxBool isMapLoading = true.obs;
    
    // Check if we need to fetch the user's location
    bool needLocationFetch = controller.selectedPoint.value.latitude == 0 && 
                             controller.selectedPoint.value.longitude == 0;
    
    // If we have no location set, set a temporary default to prevent map loading errors
    if (needLocationFetch) {
      // Set a temporary default location (e.g., New York City)
      controller.selectedPoint.value = LatLng(40.7128, -74.0060);
      controller.updateMapMarker();
    }
    
    await showModalBottomSheet(
      context: Get.context!,
      backgroundColor: themeController.secondaryBackgroundColor.value,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // If we need to fetch location, do it immediately when the sheet is shown
        if (needLocationFetch) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            bool success = await controller.getLocation();
            if (success && controller.selectedPoint.value.latitude != 0) {
              controller.mapController.move(controller.selectedPoint.value, 15);
            }
            isMapLoading.value = false;
          });
        }
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Set location for alarm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: themeController.primaryTextColor.value,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: themeController.primaryTextColor.value,
                    ),
                    onPressed: () {
                      Utils.hapticFeedback();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          onTap: (tapPosition, point) {
                            controller.setMapLocation(point);
                          },
                          center: controller.selectedPoint.value,
                          zoom: 15,
                          onMapReady: () {
                            // Map is ready to be interacted with
                            // Only turn off loading if we're not fetching location
                            if (!needLocationFetch) {
                              isMapLoading.value = false;
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.ultimate_alarm_clock',
                            // Show loading when tiles are loading
                          ),
                          Obx(() => MarkerLayer(
                                markers:
                                    List<Marker>.from(controller.markersList))),
                        ],
                      ),
                    ),
                    
                    // Zoom control buttons (positioned in the bottom right corner)
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        children: [
                          // Zoom in button
                          FloatingActionButton(
                            heroTag: "zoomIn",
                            mini: true,
                            backgroundColor: kprimaryColor,
                            elevation: 4,
                            child: const Icon(Icons.add, color: Colors.black),
                            onPressed: () {
                              Utils.hapticFeedback();
                              final currentZoom = controller.mapController.zoom;
                              controller.mapController.move(
                                controller.mapController.center, 
                                currentZoom + 1.0
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          // Zoom out button
                          FloatingActionButton(
                            heroTag: "zoomOut",
                            mini: true,
                            backgroundColor: kprimaryColor,
                            elevation: 4,
                            child: const Icon(Icons.remove, color: Colors.black),
                            onPressed: () {
                              Utils.hapticFeedback();
                              final currentZoom = controller.mapController.zoom;
                              controller.mapController.move(
                                controller.mapController.center, 
                                currentZoom - 1.0
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Show loading indicator while the map is loading
                    Obx(() => isMapLoading.value 
                      ? Container(
                          decoration: BoxDecoration(
                            color: themeController.primaryBackgroundColor.value.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: kprimaryColor,
                                ),
                                const SizedBox(height: 16),
                                Obx(() => Text(
                                  needLocationFetch 
                                      ? 'Finding your location...' 
                                      : 'Loading map...',
                                  style: TextStyle(
                                    color: themeController.primaryTextColor.value,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink()
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Get Current Location button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: needLocationFetch ? Colors.red : kprimaryColor,
                          width: needLocationFetch ? 2.0 : 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: needLocationFetch 
                            ? Colors.red.withOpacity(0.1) 
                            : Colors.transparent,
                      ),
                      icon: Icon(
                        Icons.my_location,
                        color: needLocationFetch ? Colors.red : kprimaryColor,
                      ),
                      label: Text(
                        needLocationFetch 
                            ? 'Get Your Location' 
                            : 'Update Location',
                        style: TextStyle(
                          color: needLocationFetch ? Colors.red : kprimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        Utils.hapticFeedback();
                        isMapLoading.value = true;
                        bool success = await controller.getLocation();
                        if (success && controller.selectedPoint.value.latitude != 0) {
                          controller.mapController.move(controller.selectedPoint.value, 15);
                        }
                        isMapLoading.value = false;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: kprimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save Location',
                    style: TextStyle(
                      color: themeController.secondaryTextColor.value,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Utils.hapticFeedback();
                    Navigator.pop(context);
                    if (!controller.isLocationEnabled.value && !controller.isNegativeLocationEnabled.value) {
                      controller.isLocationEnabled.value = true;
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    // Make sure location is enabled after dialog
    if (!controller.isLocationEnabled.value && !controller.isNegativeLocationEnabled.value) {
      // Auto enable positive location condition if no condition is selected
      controller.isLocationEnabled.value = true;
    }
  }
}
