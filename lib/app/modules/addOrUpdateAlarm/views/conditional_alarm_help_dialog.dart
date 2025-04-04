import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class ConditionalAlarmHelpDialog extends StatefulWidget {
  const ConditionalAlarmHelpDialog({
    Key? key,
    required this.themeController,
  }) : super(key: key);

  final ThemeController themeController;

  static void show({required ThemeController themeController}) {
    Get.dialog(
      ConditionalAlarmHelpDialog(themeController: themeController),
      barrierDismissible: true,
    );
  }

  @override
  State<ConditionalAlarmHelpDialog> createState() => _ConditionalAlarmHelpDialogState();
}

class _ConditionalAlarmHelpDialogState extends State<ConditionalAlarmHelpDialog> {
  final _pageController = PageController();
  int _currentPage = 0;
  
  final int _totalPages = 4;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: widget.themeController.secondaryBackgroundColor.value,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: kprimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.new_releases, color: Colors.black),
                  const SizedBox(width: 8),
                  Text(
                    "New Feature: Condition Types",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Page content
            Flexible(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  HapticFeedback.lightImpact();
                },
                children: [
                  // Introduction page
                  _buildPage(
                    title: "Smart Alarm Conditions",
                    content: Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.compare_arrows,
                          title: "Two Ways to Set Conditions",
                          details: "Ultimate Alarm Clock now offers POSITIVE and NEGATIVE conditions for your alarms. These give you more control over when your alarms will ring.",
                        ),
                        _buildInfoCard(
                          icon: Icons.touch_app,
                          title: "Tap to Continue",
                          details: "Swipe through this guide to learn how these conditions work and see examples for location, weather, and screen activity.",
                        ),
                      ],
                    ),
                  ),
                  
                  // Location conditions page
                  _buildPage(
                    title: "Location Conditions",
                    content: Column(
                      children: [
                        _buildConditionComparison(
                          title: "Location",
                          icon: Icons.location_on,
                          positiveName: "Ring WHEN at location",
                          positiveExample: "Your alarm will only ring if you ARE within about 500m of your set location.",
                          positiveUseCase: "Great for only ringing your alarm when you arrive at work, school, or another specific place.",
                          negativeName: "Ring when NOT at location",
                          negativeExample: "Your alarm will only ring if you are NOT within about 500m of your set location.",
                          negativeUseCase: "Perfect for ensuring your alarm only rings when you're away from home.",
                        ),
                      ],
                    ),
                  ),
                  
                  // Weather conditions page
                  _buildPage(
                    title: "Weather Conditions",
                    content: Column(
                      children: [
                        _buildConditionComparison(
                          title: "Weather",
                          icon: Icons.cloud,
                          positiveName: "Ring WHEN weather matches",
                          positiveExample: "Your alarm will only ring if the current weather matches your selected types.",
                          positiveUseCase: "Great for only waking up early when it's sunny for a morning run, or when it's rainy for gardening.",
                          negativeName: "Ring when weather does NOT match",
                          negativeExample: "Your alarm will only ring if the current weather does NOT match your selected types.",
                          negativeUseCase: "Perfect for ensuring your alarm rings when conditions aren't what you selected, like avoiding outdoor activities in bad weather.",
                        ),
                      ],
                    ),
                  ),
                  
                  // Screen activity page
                  _buildPage(
                    title: "Screen Activity Conditions",
                    content: Column(
                      children: [
                        _buildConditionComparison(
                          title: "Screen Activity",
                          icon: Icons.screen_lock_portrait,
                          positiveName: "Ring if ACTIVE in time period",
                          positiveExample: "Your alarm will only ring if your phone has been used recently.",
                          positiveUseCase: "Great for ensuring you're already awake before the alarm rings, reducing disruption.",
                          negativeName: "Ring if INACTIVE in time period",
                          negativeExample: "Your alarm will only ring if your phone has NOT been used recently.",
                          negativeUseCase: "Perfect for ensuring you're still asleep when the alarm rings, maximizing effectiveness.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation dots and buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? kprimaryColor
                              : widget.themeController.primaryTextColor.value.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (hidden on first page)
                      _currentPage > 0
                          ? TextButton.icon(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                HapticFeedback.lightImpact();
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text("Previous"),
                              style: TextButton.styleFrom(
                                foregroundColor: widget.themeController.primaryTextColor.value,
                              ),
                            )
                          : const SizedBox(width: 100),
                      
                      // Next/Finish button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _totalPages - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Get.back();
                          }
                          HapticFeedback.mediumImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kprimaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentPage < _totalPages - 1 ? "Next" : "Got it!",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage({required String title, required Widget content}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.themeController.primaryTextColor.value,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon, 
    required String title, 
    required String details,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeController.primaryBackgroundColor.value,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeController.primaryTextColor.value.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: kprimaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: widget.themeController.primaryTextColor.value,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            details,
            style: TextStyle(
              color: widget.themeController.primaryTextColor.value.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConditionComparison({
    required String title,
    required IconData icon,
    required String positiveName,
    required String positiveExample,
    required String positiveUseCase,
    required String negativeName,
    required String negativeExample,
    required String negativeUseCase,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: kprimaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: widget.themeController.primaryTextColor.value,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Positive condition card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.themeController.primaryBackgroundColor.value,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kprimaryColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: kprimaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    positiveName,
                    style: TextStyle(
                      color: widget.themeController.primaryTextColor.value,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildConditionDetail(
                icon: Icons.info_outline,
                text: positiveExample,
                themeController: widget.themeController,
              ),
              const SizedBox(height: 8),
              _buildConditionDetail(
                icon: Icons.lightbulb_outline,
                text: positiveUseCase,
                themeController: widget.themeController,
              ),
            ],
          ),
        ),
        
        // Negative condition card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.themeController.primaryBackgroundColor.value,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.remove_circle,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    negativeName,
                    style: TextStyle(
                      color: widget.themeController.primaryTextColor.value,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildConditionDetail(
                icon: Icons.info_outline,
                text: negativeExample,
                themeController: widget.themeController,
              ),
              const SizedBox(height: 8),
              _buildConditionDetail(
                icon: Icons.lightbulb_outline,
                text: negativeUseCase,
                themeController: widget.themeController,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildConditionDetail({
    required IconData icon,
    required String text,
    required ThemeController themeController,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: themeController.primaryTextColor.value.withOpacity(0.7),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: themeController.primaryTextColor.value.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
} 