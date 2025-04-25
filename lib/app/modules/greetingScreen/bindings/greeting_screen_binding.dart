import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';

import '../controllers/greeting_screen_controller.dart';

class GreetingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GreetingScreenController>(
      () => GreetingScreenController(),
    );
    Get.lazyPut<ThemeController>(
      () => ThemeController(),
    );
  }
} 