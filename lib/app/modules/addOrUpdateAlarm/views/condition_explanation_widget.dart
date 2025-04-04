import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class ConditionExplanationWidget extends StatelessWidget {
  const ConditionExplanationWidget({
    Key? key,
    required this.themeController,
    required this.title,
    required this.positiveExplanation,
    required this.negativeExplanation,
  }) : super(key: key);

  final ThemeController themeController;
  final String title;
  final String positiveExplanation;
  final String negativeExplanation;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.bottomSheet(
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeController.secondaryBackgroundColor.value,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: themeController.primaryTextColor.value.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: themeController.primaryTextColor.value,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Positive condition explanation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeController.primaryBackgroundColor.value,
                    border: Border.all(color: kprimaryColor, width: 1),
                    borderRadius: BorderRadius.circular(10),
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
                            "Positive Condition",
                            style: TextStyle(
                              color: themeController.primaryTextColor.value,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        positiveExplanation,
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Negative condition explanation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeController.primaryBackgroundColor.value,
                    border: Border.all(color: Colors.redAccent, width: 1),
                    borderRadius: BorderRadius.circular(10),
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
                            "Negative Condition",
                            style: TextStyle(
                              color: themeController.primaryTextColor.value,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        negativeExplanation,
                        style: TextStyle(
                          color: themeController.primaryTextColor.value,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Got it",
                      style: TextStyle(
                        color: themeController.secondaryTextColor.value,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isScrollControlled: true,
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            size: 18,
            color: themeController.primaryTextColor.value.withOpacity(0.6),
          ),
          const SizedBox(width: 5),
          Text(
            "How it works",
            style: TextStyle(
              color: themeController.primaryTextColor.value.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 