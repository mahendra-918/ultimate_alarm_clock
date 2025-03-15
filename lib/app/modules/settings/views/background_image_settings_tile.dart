import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class BackgroundImageSettingsTile extends StatelessWidget {
  const BackgroundImageSettingsTile({
    Key? key,
    required this.controller,
    required this.themeController,
    required this.height,
    required this.width,
  }) : super(key: key);

  final SettingsController controller;
  final ThemeController themeController;
  final double height;
  final double width;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      debugPrint('Starting image picker...');
      
      // Show a dialog to choose the image source with themed UI
      final source = await Get.dialog<ImageSource>(
        AlertDialog(
          backgroundColor: themeController.secondaryBackgroundColor.value,
          title: Text(
            'Choose Image Source',
            style: TextStyle(
              color: themeController.primaryTextColor.value,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: themeController.primaryTextColor.value,
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                  ),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
                tileColor: themeController.secondaryBackgroundColor.value,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.file_copy,
                  color: themeController.primaryTextColor.value,
                ),
                title: Text(
                  'File',
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                  ),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
                tileColor: themeController.secondaryBackgroundColor.value,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
      
      if (source == null) {
        debugPrint('No source selected');
        return;
      }
      
      final XFile? image = await picker.pickImage(
        source: source,
      );
      
      if (image != null) {
        debugPrint('Image picked successfully: ${image.path}');
        try {
          // First verify the source file exists and is readable
          final File sourceFile = File(image.path);
          if (!await sourceFile.exists()) {
            throw Exception('Source file does not exist: ${image.path}');
          }
          
          // Get the app's local storage directory
          final Directory appDir = await getApplicationDocumentsDirectory();
          debugPrint('App directory: ${appDir.path}');
          
          // Create a backgrounds directory if it doesn't exist
          final String bgDir = '${appDir.path}/backgrounds';
          await Directory(bgDir).create(recursive: true);
          
          final String fileName = 'alarm_bg_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String filePath = '$bgDir/$fileName';
          debugPrint('New file path: $filePath');
          
          // Create a copy of the image file
          final File newImage = await sourceFile.copy(filePath);
          debugPrint('Image copied successfully to: ${newImage.path}');
          
          // Delete the old image if it exists
          if (controller.defaultBackgroundImage.value.isNotEmpty) {
            try {
              final File oldFile = File(controller.defaultBackgroundImage.value);
              if (await oldFile.exists()) {
                await oldFile.delete();
                debugPrint('Old image deleted successfully');
              } else {
                debugPrint('Old image file not found: ${controller.defaultBackgroundImage.value}');
              }
            } catch (e) {
              debugPrint('Error deleting old image: $e');
            }
          }
          
          // Verify the new file exists and is readable
          if (await newImage.exists()) {
            try {
              // Try to read the file to verify it's valid
              await newImage.readAsBytes();
              
              debugPrint('New image file verified at: ${newImage.path}');
              // Update the controller with the new image path
              controller.defaultBackgroundImage.value = newImage.path;
              debugPrint('Controller background image updated to: ${controller.defaultBackgroundImage.value}');
              
              // Save the path to persistent storage
              controller.storage.writeDefaultBackgroundImage(newImage.path);
              
              // Show success message
              Get.snackbar(
                'Success',
                'Default background image updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: themeController.secondaryBackgroundColor.value,
                colorText: themeController.primaryTextColor.value,
                margin: const EdgeInsets.all(15),
                duration: const Duration(seconds: 2),
              );
            } catch (e) {
              throw Exception('File exists but is not readable: $e');
            }
          } else {
            throw Exception('New image file not found after copying');
          }
        } catch (e) {
          debugPrint('Error saving image: $e');
          Get.snackbar(
            'Error',
            'Failed to save image. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: themeController.secondaryBackgroundColor.value,
            colorText: themeController.primaryTextColor.value,
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 2),
          );
        }
      } else {
        debugPrint('No image selected');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: themeController.secondaryBackgroundColor.value,
        colorText: themeController.primaryTextColor.value,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 0.9,
      decoration: BoxDecoration(
        color: themeController.secondaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                'Default Background Image'.tr,
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                ),
              ),
            ),
            Row(
              children: [
                Obx(() => controller.defaultBackgroundImage.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: themeController.primaryTextColor.value,
                      ),
                      onPressed: () {
                        controller.defaultBackgroundImage.value = '';
                        controller.storage.writeDefaultBackgroundImage('');
                      },
                    )
                  : const SizedBox()),
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: themeController.primaryTextColor.value,
                  ),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ],
        ),
        subtitle: Obx(() => controller.defaultBackgroundImage.value.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(controller.defaultBackgroundImage.value),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            )
          : const SizedBox()),
      ),
    );
  }
} 