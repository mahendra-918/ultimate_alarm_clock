import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ultimate_alarm_clock/app/data/models/alarm_model.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/audio_utils.dart';

class SunriseAlarmService {
  // Singleton pattern implementation
  static final SunriseAlarmService _instance = SunriseAlarmService._internal();
  static SunriseAlarmService get instance => _instance;
  
  // Private constructor
  SunriseAlarmService._internal();

  // Reactive properties
  final RxDouble brightness = 0.0.obs;
  final RxBool isActive = false.obs;

  // Audio player
  AudioPlayer? _audioPlayer;
  Timer? _brightnessTimer;
  bool _overlayShown = false;

  // Start the sunrise alarm
  Future<void> startSunrise({
    required int durationMinutes,
    required String ambientSoundType,
  }) async {
    if (isActive.value) return;
    
    isActive.value = true;
    brightness.value = 0.0;
    
    // Calculate brightness steps
    final int totalSteps = durationMinutes * 60; // Convert to seconds
    final double stepIncrease = 1.0 / totalSteps;
    
    // Show overlay window
    await _showSunriseOverlay();
    
    // Start increasing brightness
    _brightnessTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (brightness.value >= 1.0) {
        timer.cancel();
        return;
      }
      brightness.value += stepIncrease;
      
      // Send brightness updates to the overlay
      if (_overlayShown) {
        try {
          FlutterOverlayWindow.shareData({
            'brightness': brightness.value,
          });
        } catch (e) {
          debugPrint('Error sending brightness update: $e');
        }
      }
    });
    
    // Play ambient sound if enabled
    if (ambientSoundType != 'None') {
      await _playAmbientSound(ambientSoundType);
    }
  }
  
  // Display an overlay window with increasing brightness
  Future<void> _showSunriseOverlay() async {
    try {
      // Request permission if not already granted
      final hasPermission = await FlutterOverlayWindow.requestPermission();
      if (hasPermission != true) {
        debugPrint('Overlay permission denied');
        return;
      }
      
      // Show the overlay
      await FlutterOverlayWindow.showOverlay(
        enableDrag: false,
        flag: OverlayFlag.defaultFlag,
        alignment: OverlayAlignment.center,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: WindowSize.fullCover,
        width: WindowSize.fullCover,
      );
      
      _overlayShown = true;
    } catch (e) {
      debugPrint('Error showing overlay: $e');
    }
  }
  
  // Play the selected ambient sound
  Future<void> _playAmbientSound(String soundType) async {
    _audioPlayer = AudioPlayer();
    
    String soundPath = 'assets/sounds/';
    switch (soundType) {
      case 'Forest':
        soundPath += 'forest.mp3';
        break;
      case 'Ocean':
        soundPath += 'ocean.mp3';
        break;
      case 'Rain':
        soundPath += 'rain.mp3';
        break;
      case 'White Noise':
        soundPath += 'white_noise.mp3';
        break;
      default:
        return;
    }
    
    try {
      await _audioPlayer!.setAsset(soundPath);
      await _audioPlayer!.setLoopMode(LoopMode.one);
      await _audioPlayer!.setVolume(0.0);
      await _audioPlayer!.play();
      
      // Gradually increase volume
      double volume = 0.0;
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (volume >= 0.8) {
          timer.cancel();
          return;
        }
        volume += 0.1;
        _audioPlayer!.setVolume(volume);
      });
    } catch (e) {
      debugPrint('Error playing ambient sound: $e');
    }
  }
  
  // Preview ambient sound for settings UI
  Future<void> previewAmbientSound(String soundType) async {
    stopSunrise(); // Stop any existing playback
    
    _audioPlayer = AudioPlayer();
    
    String soundPath = 'assets/sounds/';
    switch (soundType) {
      case 'Forest':
        soundPath += 'forest.mp3';
        break;
      case 'Ocean':
        soundPath += 'ocean.mp3';
        break;
      case 'Rain':
        soundPath += 'rain.mp3';
        break;
      case 'White Noise':
        soundPath += 'white_noise.mp3';
        break;
      default:
        return;
    }
    
    try {
      await _audioPlayer!.setAsset(soundPath);
      await _audioPlayer!.setVolume(0.5);
      await _audioPlayer!.play();
      
      // Stop preview after 5 seconds
      Timer(const Duration(seconds: 5), () {
        stopSunrise();
      });
    } catch (e) {
      debugPrint('Error previewing ambient sound: $e');
    }
  }
  
  // Stop the sunrise alarm
  Future<void> stopSunrise() async {
    if (!isActive.value && _audioPlayer == null) return;
    
    isActive.value = false;
    brightness.value = 0.0;
    
    _brightnessTimer?.cancel();
    _brightnessTimer = null;
    
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }
    
    if (_overlayShown) {
      try {
        await FlutterOverlayWindow.closeOverlay();
        _overlayShown = false;
      } catch (e) {
        debugPrint('Error closing overlay: $e');
      }
    }
  }
} 