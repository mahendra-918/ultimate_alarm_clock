import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_alarm_clock/app/data/providers/get_storage_provider.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ultimate_alarm_clock/app/utils/language.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/custom_error_screen.dart';
import 'app/routes/app_pages.dart';

Locale? loc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request necessary permissions
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  
  // Request storage permissions for database access
  await Permission.storage.isDenied.then((value) {
    if (value) {
      Permission.storage.request();
    }
  });
  
  // Additional permissions that might be needed on newer Android versions
  if (Platform.isAndroid) {
    await Permission.manageExternalStorage.isDenied.then((value) {
      if (value) {
        Permission.manageExternalStorage.request();
      }
    });
  }

  await Firebase.initializeApp();

  // Initialize SharedPreferences and add to GetX dependency injection
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences);

  await Get.putAsync(() => GetStorageProvider().init());

  final storage = Get.find<GetStorageProvider>();
  loc = await storage.readLocale();

  final ThemeController themeController = Get.put(ThemeController());

  AudioPlayer.global.setAudioContext(
    const AudioContext(
      android: AudioContextAndroid(
        audioMode: AndroidAudioMode.ringtone,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.alarm,
        audioFocus: AndroidAudioFocus.gainTransient,
      ),
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    const UltimateAlarmClockApp(),
  );
}


class UltimateAlarmClockApp extends StatelessWidget {
  const UltimateAlarmClockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: kLightThemeData,
      darkTheme: kThemeData,
      themeMode: ThemeMode.system,
      title: 'UltiClock',
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      translations: AppTranslations(),
      locale: loc,
      fallbackLocale: Locale('en', 'US'),
      builder: (BuildContext context, Widget? error) {
        ErrorWidget.builder = (FlutterErrorDetails? error) {
          return CustomErrorScreen(errorDetails: error!);
        };
        return error!;
      },
    );
  }
}
