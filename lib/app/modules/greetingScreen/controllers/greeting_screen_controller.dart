import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class GreetingScreenController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeInAnimation;
  late Animation<double> scaleAnimation;
  
  final greeting = Utils.getGreeting().obs;
  final isAnimationComplete = false.obs;

  Timer? _navigationTimer;

  @override
  void onInit() {
    super.onInit();
    
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    
    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    
    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    
    animationController.forward();
    
    
    
    _navigationTimer = Timer(const Duration(milliseconds: 3000), () {
      isAnimationComplete.value = true;
      Get.offAllNamed('/bottom-navigation-bar');
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    _navigationTimer?.cancel();
    super.onClose();
  }
} 