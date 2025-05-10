import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/data/models/user_model.dart';
import 'package:ultimate_alarm_clock/app/data/providers/firestore_provider.dart';
import 'package:ultimate_alarm_clock/app/data/providers/isar_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/addOrUpdateAlarm/controllers/add_or_update_alarm_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class SharedAlarmUsers extends StatelessWidget {
  const SharedAlarmUsers({
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
                          'Shared With',
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
                          _showSharedUserInfoBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeController.primaryBackgroundColor.value,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Utils.hapticFeedback();
                          controller.showSharedUsersList.value = !controller.showSharedUsersList.value;
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: themeController.primaryColor.value.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: ksecondaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Obx(() => Text(
                                      '${controller.alarmRecord.value.sharedUserIds?.length ?? 0 + 1} users',
                                      style: TextStyle(
                                        color: themeController.primaryTextColor.value,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Obx(() => Icon(
                                controller.showSharedUsersList.value 
                                  ? Icons.keyboard_arrow_up 
                                  : Icons.keyboard_arrow_down,
                                color: themeController.primaryTextColor.value.withOpacity(0.7),
                              )),
                            ],
                          ),
                        ),
                      ),
                      Obx(() => controller.showSharedUsersList.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: themeController.primaryDisabledTextColor.value.withOpacity(0.3),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                                child: Text(
                                  'Alarm Members',
                                  style: TextStyle(
                                    color: themeController.primaryTextColor.value.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _getSharedUsersList(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  
                                  if (!snapshot.hasData || snapshot.data!.isEmpty || (snapshot.data!.length <= 1 && snapshot.data!.first['isOwner'])) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No shared users yet',
                                            style: TextStyle(
                                              color: themeController.primaryDisabledTextColor.value,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Use "Share Alarm" option above to add users',
                                            style: TextStyle(
                                              color: themeController.primaryDisabledTextColor.value,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final usersList = snapshot.data!;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: usersList.length,
                                    itemBuilder: (context, index) {
                                      final userData = usersList[index];
                                      return _buildUserListItem(context, userData);
                                    },
                                  );
                                },
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _buildUserListItem(BuildContext context, Map<String, dynamic> userData) {
    final String name = userData['name'] ?? 'User';
    final String email = userData['email'] ?? '';
    final String time = userData['time'] ?? controller.alarmRecord.value.alarmTime;
    final int offsetMinutes = userData['offsetMinutes'] ?? 0;
    final bool isOwner = userData['isOwner'] ?? false;
    final String initials = Utils.getInitials(name);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: themeController.primaryColor.value.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: ksecondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: themeController.primaryTextColor.value,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        email,
        style: TextStyle(
          color: themeController.primaryDisabledTextColor.value,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextStyle(
              color: themeController.primaryTextColor.value,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          if (offsetMinutes != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ksecondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                offsetMinutes < 0 
                  ? '- ${offsetMinutes.abs()} min' 
                  : '+ $offsetMinutes min',
                style: TextStyle(
                  color: ksecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: themeController.primaryColor.value.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Owner',
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (!isOwner)
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red.withOpacity(0.7),
                size: 18,
              ),
              onPressed: () {
                Utils.hapticFeedback();
                _removeSharedUser(userData['id']);
              },
            ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getSharedUsersList() async {
    // Initialize the user list
    final List<Map<String, dynamic>> users = [];
    
    try {
      // Add owner
      users.add({
        'id': controller.alarmRecord.value.ownerId,
        'name': controller.alarmRecord.value.ownerName,
        'email': controller.userModel.value?.email ?? 'owner@example.com',
        'time': controller.alarmRecord.value.alarmTime,
        'offsetMinutes': 0,
        'isOwner': true,
      });
      
      // Add shared users
      if (controller.alarmRecord.value.sharedUserIds != null && 
          controller.alarmRecord.value.sharedUserIds!.isNotEmpty) {
            
        // Fetch user details for each shared user ID
        for (String userId in controller.alarmRecord.value.sharedUserIds!) {
          try {
            // Try to get user data from Firestore
            final UserModel? userData = await FirestoreDb.fetchUserDetails(userId);
            
            if (userData != null) {
              // Get offset details for this user if available
              int offsetMinutes = 0;
              String userTime = controller.alarmRecord.value.alarmTime;
              
              if (controller.alarmRecord.value.offsetDetails != null) {
                final userOffset = controller.alarmRecord.value.offsetDetails!
                    .where((entry) => entry['userId'] == userId)
                    .toList();
                    
                if (userOffset.isNotEmpty) {
                  final data = userOffset.first;
                  offsetMinutes = data['offsetDuration'] ?? 0;
                  if (data['isOffsetBefore'] == true) {
                    offsetMinutes = -offsetMinutes;
                  }
                  userTime = data['offsettedTime'] ?? controller.alarmRecord.value.alarmTime;
                }
              }
              
              // Add user to the list
              users.add({
                'id': userId,
                'name': userData.fullName,
                'email': userData.email,
                'time': userTime,
                'offsetMinutes': offsetMinutes,
                'isOwner': false,
              });
            } else {
              // If user data can't be found, add a placeholder
              users.add({
                'id': userId,
                'name': 'Unknown User',
                'email': 'unknown@example.com',
                'time': controller.alarmRecord.value.alarmTime,
                'offsetMinutes': 0,
                'isOwner': false,
              });
            }
          } catch (e) {
            print('Error fetching user data: $e');
          }
        }
      }
    } catch (e) {
      print('Error in _getSharedUsersList: $e');
    }
    
    return users;
  }

  void _removeSharedUser(String userId) {
    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Remove User',
      content: const Text('Are you sure you want to remove this user?'),
      textConfirm: 'Remove',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      cancelTextColor: themeController.primaryTextColor.value,
      buttonColor: Colors.red,
      onConfirm: () async {
        // Close the dialog
        Get.back();
        
        try {
          // Remove the user from the sharedUserIds list
          if (controller.alarmRecord.value.sharedUserIds != null) {
            controller.alarmRecord.value.sharedUserIds!.remove(userId);
            controller.sharedUserIds.remove(userId);
            
            // If this is a Firestore alarm, update it
            if (controller.alarmRecord.value.firestoreId != null) {
              // Update the alarm in Firestore
              await FirestoreDb.updateAlarm(
                controller.alarmRecord.value.ownerId,
                controller.alarmRecord.value,
              );
            }
            
            // Show success message
            Get.snackbar(
              'User Removed',
              'User has been removed from shared alarm',
              snackPosition: SnackPosition.BOTTOM,
            );
            
            // Refresh the UI
            controller.showSharedUsersList.value = false;
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.showSharedUsersList.value = true;
            });
          }
        } catch (e) {
          print('Error removing user: $e');
          Get.snackbar(
            'Error',
            'Failed to remove user: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void _showSharedUserInfoBottomSheet(BuildContext context) {
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
              Icon(
                Icons.people,
                color: themeController.primaryTextColor.value,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Shared Alarms',
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share alarms with others. Each shared user can choose to have their alarm ring before or after the set time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeController.primaryTextColor.value,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ksecondaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Utils.hapticFeedback();
                  Get.back();
                },
                child: const Text('Understood'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInviteUserBottomSheet(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeController.secondaryBackgroundColor.value,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invite New User',
                    style: TextStyle(
                      color: themeController.primaryTextColor.value,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Utils.hapticFeedback();
                      Get.back();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email address',
                  hintText: 'Enter email address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: themeController.primaryBackgroundColor.value,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ksecondaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Utils.hapticFeedback();
                  if (emailController.text.isNotEmpty && 
                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text)) {
                    
                    // First save the email to the local database for future use
                    await IsarDb.addEmail(emailController.text);
                    
                    // Get user ID from email
                    List<String> userIds = await FirestoreDb.getUserIdsByEmails([emailController.text]);
                    
                    if (userIds.isNotEmpty) {
                      final String userId = userIds.first;
                      
                      // Check if user is already in the shared list
                      if (controller.alarmRecord.value.sharedUserIds != null &&
                          controller.alarmRecord.value.sharedUserIds!.contains(userId)) {
                        Get.back();
                        Get.snackbar(
                          'Already Shared',
                          'This user is already in the shared list',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      
                      // Add to sharedUserIds if not empty
                      if (controller.alarmRecord.value.sharedUserIds == null) {
                        controller.alarmRecord.value.sharedUserIds = [];
                      }
                      
                      // Add the user ID to the shared list
                      controller.alarmRecord.value.sharedUserIds!.add(userId);
                      controller.sharedUserIds.add(userId);
                      
                      // Update the alarm in Firestore
                      if (controller.alarmRecord.value.firestoreId != null) {
                        await FirestoreDb.updateAlarm(
                          controller.alarmRecord.value.ownerId,
                          controller.alarmRecord.value,
                        );
                        
                        // Send a notification
                        await FirestoreDb.shareAlarm(
                          [emailController.text],
                          controller.alarmRecord.value,
                        );
                      }
                      
                      // Close the modal
                      Get.back();
                      
                      // Show success message
                      Get.snackbar(
                        'Invitation Sent',
                        'User has been added to the shared alarm',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      
                      // Refresh the UI
                      controller.showSharedUsersList.value = false;
                      Future.delayed(const Duration(milliseconds: 100), () {
                        controller.showSharedUsersList.value = true;
                      });
                    } else {
                      Get.snackbar(
                        'User Not Found',
                        'No user found with this email address',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.7),
                        colorText: Colors.white,
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Invalid Email',
                      'Please enter a valid email address',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.7),
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text('Send Invitation'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
} 