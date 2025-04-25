import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';

import '../controllers/greeting_screen_controller.dart';

class GreetingScreenView extends GetView<GreetingScreenController> {
  const GreetingScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: controller.animationController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kprimaryColor,
                    themeController.primaryBackgroundColor.value,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Opacity(
                      opacity: controller.fadeInAnimation.value,
                      child: Transform.scale(
                        scale: controller.scaleAnimation.value,
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: _getLottieAnimation(controller.greeting.value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    Opacity(
                      opacity: controller.fadeInAnimation.value,
                      child: Transform.scale(
                        scale: controller.scaleAnimation.value,
                        child: Text(
                          controller.greeting.value,
                          style: TextStyle(
                            color: themeController.secondaryTextColor.value,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Opacity(
                      opacity: controller.fadeInAnimation.value,
                      child: Transform.scale(
                        scale: controller.scaleAnimation.value,
                        child: Text(
                          _getSubtitleText(controller.greeting.value),
                          style: TextStyle(
                            color: themeController.secondaryTextColor.value,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getLottieAnimation(String greeting) {
    if (greeting.contains('Morning')) {
      return Lottie.asset('assets/animations/morning.json');
    } else if (greeting.contains('Afternoon')) {
      return Lottie.asset('assets/animations/afternoon.json');
    } else if (greeting.contains('Evening')) {
      return Lottie.asset('assets/animations/evening.json');
    } else {
      return Lottie.asset('assets/animations/night.json');
    }
  }

  String _getSubtitleText(String greeting) {
    if (greeting.contains('Night')) {
      return 'Have a peaceful night'.tr;
    } else {
      return 'Have a great day'.tr;
    }
  }
} 