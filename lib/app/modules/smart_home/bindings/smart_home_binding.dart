import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/smart_home/controllers/smart_home_controller.dart';
import 'package:ultimate_alarm_clock/app/services/smart_home_service.dart';

class SmartHomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register the smart home service if it's not already registered
    if (!Get.isRegistered<SmartHomeService>()) {
      Get.put(SmartHomeService(), permanent: true);
    }
    
    // Register the controller
    Get.lazyPut<SmartHomeController>(
      () => SmartHomeController(),
    );
  }
}
