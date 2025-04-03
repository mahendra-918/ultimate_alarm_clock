import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// The main entry point for the overlay window application
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayWindowApp());
}

/// The main application for the overlay window
class OverlayWindowApp extends StatelessWidget {
  const OverlayWindowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sunrise Alarm',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const SunriseOverlay(),
    );
  }
}

class SunriseOverlay extends StatefulWidget {
  const SunriseOverlay({Key? key}) : super(key: key);

  @override
  State<SunriseOverlay> createState() => _SunriseOverlayState();
}

class _SunriseOverlayState extends State<SunriseOverlay> {
  final RxDouble brightness = 0.0.obs;
  StreamSubscription? _dataListener;

  @override
  void initState() {
    super.initState();
    _setupDataListener();
  }

  void _setupDataListener() {
    _dataListener = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null && event['brightness'] != null) {
        double value = event['brightness'];
        brightness.value = value;
      }
    });
  }

  @override
  void dispose() {
    _dataListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Obx(
        () => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: Colors.yellow.withOpacity(brightness.value),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Visibility(
              visible: brightness.value > 0.8,
              child: const Text(
                'Rise and shine!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 