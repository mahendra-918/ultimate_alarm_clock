package com.ccextractor.ultimate_alarm_clock

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Date


class MainActivity : FlutterActivity() {
    companion object {
        const val CHANNEL1 = "ulticlock"
        const val CHANNEL2 = "timer"
        const val ACTION_START_FLUTTER_APP = "com.ccextractor.ultimate_alarm_clock"
        const val EXTRA_KEY = "alarmRing"
        const val ALARM_TYPE = "isAlarm"
        const val SHARED_ALARM_KEY = "isSharedAlarm"
        private var isAlarm: String? = "true"
        private var isSharedAlarm: Boolean = false
        val alarmConfig = hashMapOf("shouldAlarmRing" to false, "alarmIgnore" to false, "isSharedAlarm" to false)
        private var ringtone: Ringtone? = null
        
        // Define specific request codes for different alarm types
        const val REQUEST_CODE_LOCAL_ALARM = 101
        const val REQUEST_CODE_SHARED_ALARM = 102
        const val REQUEST_CODE_LOCAL_ACTIVITY = 201
        const val REQUEST_CODE_SHARED_ACTIVITY = 202
    }
    
    private var timerNotification: TimerNotification? = null
    private var alarmManager: AlarmManager? = null
    private var lastScheduledAlarmTime: Long = 0
    private var lastScheduledAlarmType: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var intentFilter = IntentFilter()
        intentFilter.addAction("com.ccextractor.ultimate_alarm_clock.START_TIMERNOTIF")
        intentFilter.addAction("com.ccextractor.ultimate_alarm_clock.STOP_TIMERNOTIF")
        timerNotification = TimerNotification()
        context.registerReceiver(timerNotification, intentFilter, Context.RECEIVER_EXPORTED)
        
        // Initialize alarm manager once
        alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Unregister the receiver to prevent memory leaks
        if (timerNotification != null) {
            try {
                context.unregisterReceiver(timerNotification)
                timerNotification = null
            } catch (e: Exception) {
                Log.e("MainActivity", "Error unregistering receiver: ${e.message}")
            }
        }
    }


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        var methodChannel1 = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL1)
        var methodChannel2 = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL2)

        val intent = intent

        if (intent != null && intent.hasExtra(EXTRA_KEY)) {
            val receivedData = intent.getStringExtra(EXTRA_KEY)
            if (receivedData == "true") {
                alarmConfig["shouldAlarmRing"] = true
            }
            isAlarm = intent.getStringExtra(ALARM_TYPE)
            
            // Check for shared alarm flag
            isSharedAlarm = intent.getBooleanExtra(SHARED_ALARM_KEY, false)
            if (isSharedAlarm) {
                alarmConfig["isSharedAlarm"] = true
                println("NATIVE RECEIVED SHARED ALARM FLAG")
            }
            
            val cleanIntent = Intent(intent)
            cleanIntent.removeExtra(EXTRA_KEY)
            cleanIntent.removeExtra(SHARED_ALARM_KEY)
            setIntent(cleanIntent)
            println("NATIVE SAID OK")
        } else {
            println("NATIVE SAID NO")
        }

        if (isAlarm == "true") {
            val cleanIntent = Intent(intent)
            cleanIntent.removeExtra(EXTRA_KEY)
            cleanIntent.removeExtra(SHARED_ALARM_KEY)
            methodChannel1.invokeMethod("appStartup", alarmConfig)
            alarmConfig["shouldAlarmRing"] = false
            alarmConfig["isSharedAlarm"] = false
        }
        methodChannel2.setMethodCallHandler { call, result ->
            if (call.method == "playDefaultAlarm") {
                playDefaultAlarm(this)
                result.success(null)
            } else if (call.method == "stopDefaultAlarm") {
                stopDefaultAlarm()
                result.success(null)
            } else if (call.method == "runtimerNotif") {
                val startTimerIntent =
                    Intent("com.ccextractor.ultimate_alarm_clock.START_TIMERNOTIF")
                context.sendBroadcast(startTimerIntent)

            } else if (call.method == "clearTimerNotif") {
                val stopTimerIntent = Intent("com.ccextractor.ultimate_alarm_clock.STOP_TIMERNOTIF")
                context.sendBroadcast(stopTimerIntent)
                var notificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.cancel(1)
            } else {
                result.notImplemented()
            }
        }
        methodChannel1.setMethodCallHandler { call, result ->
            if (call.method == "scheduleAlarm") {
                println("FLUTTER CALLED SCHEDULE")

                val isSharedAlarm = call.argument<Boolean>("isSharedAlarm") ?: false
                val isActivityEnabled = call.argument<Boolean>("isActivityEnabled") ?: false
                val isLocationEnabled = call.argument<Boolean>("isLocationEnabled") ?: false
                val location = call.argument<String>("location") ?: ""
                val isWeatherEnabled = call.argument<Boolean>("isWeatherEnabled") ?: false
                val intervalToAlarm = call.argument<Number>("intervalToAlarm")?.toLong() ?: 0L
                val weatherTypesJson = call.argument<String>("weatherTypes") ?: "[]"
                
                // Always cancel all scheduled alarms first to avoid duplicates
                println("CANCELING ALL ALARMS BEFORE SCHEDULING")
                cancelAllAlarms()

                if (!isSharedAlarm) {
                    val dbHelper = DatabaseHelper(context)
                    val db = dbHelper.readableDatabase
                    val sharedPreferences =
                        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    val profile = sharedPreferences.getString("flutter.profile", "Default")
                    val ringTime = getLatestAlarm(db, true, profile ?: "Default", context)
                    if (ringTime != null) {
                        android.util.Log.d("Scheduling local alarm", "Time to ring: ${ringTime["interval"]}")
                        scheduleAlarmInternal(
                            ringTime["interval"]!! as Long,
                            ringTime["isActivity"]!! as Int,
                            ringTime["isLocation"]!! as Int,
                            ringTime["location"]!! as String,
                            ringTime["isWeather"]!! as Int,
                            ringTime["weatherTypes"]!! as String,
                            false // not shared
                        )
                    } else {
                        println("NO LOCAL ALARMS TO SCHEDULE")
                    }
                } else {
                    android.util.Log.d("Scheduling shared alarm", "Time to ring: ${intervalToAlarm}")
                    scheduleAlarmInternal(
                        intervalToAlarm,
                        if (isActivityEnabled) 1 else 0,
                        if (isLocationEnabled) 1 else 0,
                        location,
                        if (isWeatherEnabled) 1 else 0,
                        weatherTypesJson,
                        true // shared alarm
                    )
                }
                result.success(null)
            } else if (call.method == "cancelAllScheduledAlarms") {
                println("FLUTTER CALLED CANCEL ALARMS")
                cancelAllAlarms()
                result.success(null)
            } else if (call.method == "bringAppToForeground") {
                bringAppToForeground(this)
                result.success(null)
            } else if (call.method == "minimizeApp") {
                minimizeApp()
                result.success(null)
            } else if (call.method == "playDefaultAlarm") {
                playDefaultAlarm(this)
                result.success(null)
            } else if (call.method == "stopDefaultAlarm") {
                stopDefaultAlarm()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }


    fun bringAppToForeground(context: Context) {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager?
        val appTasks = activityManager?.appTasks
        appTasks?.forEach { task ->
            if (task.taskInfo.baseIntent.component?.packageName == context.packageName) {
                task.moveToFront()
                return@forEach
            }
        }
    }


    private fun minimizeApp() {
        moveTaskToBack(true)
    }

    private fun cancelAllAlarms() {
        // Cancel all possible alarms to be absolutely sure nothing is left
        cancelAlarm(REQUEST_CODE_LOCAL_ALARM, false)
        cancelAlarm(REQUEST_CODE_SHARED_ALARM, true)
        cancelAlarm(REQUEST_CODE_LOCAL_ACTIVITY, false)
        cancelAlarm(REQUEST_CODE_SHARED_ACTIVITY, true)
        
        lastScheduledAlarmTime = 0
        lastScheduledAlarmType = ""
        
        Log.d("MainActivity", "All alarms canceled")
    }
    
    private fun cancelAlarm(requestCode: Int, isShared: Boolean) {
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            if (isShared) {
                putExtra("isSharedAlarm", true)
            }
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        try {
            alarmManager?.cancel(pendingIntent)
            pendingIntent.cancel()
            Log.d("MainActivity", "Canceled alarm with request code: $requestCode, isShared: $isShared")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error canceling alarm: ${e.message}")
        }
    }

    private fun playDefaultAlarm(context: Context) {
        val alarmUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        ringtone = RingtoneManager.getRingtone(context, alarmUri)
        ringtone?.play()
    }

    private fun stopDefaultAlarm() {
        ringtone?.stop()
    }

    private fun openAndroidPermissionsMenu() {
        val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
        intent.data = Uri.parse("package:${packageName}")
        startActivity(intent)
    }

    private fun scheduleAlarmInternal(
        intervalToAlarm: Long,
        isActivity: Int,
        isLocation: Int, 
        location: String,
        isWeather: Int,
        weatherTypesJson: String,
        isShared: Boolean
    ) {
        val triggerAtMillis = System.currentTimeMillis() + intervalToAlarm
        val alarmType = if (isShared) "shared" else "local"
        
        // Check if we're trying to schedule the same alarm again
        if (triggerAtMillis == lastScheduledAlarmTime && alarmType == lastScheduledAlarmType) {
            Log.d("MainActivity", "Skipping duplicate alarm schedule: $alarmType at ${Date(triggerAtMillis)}")
            return
        }
        
        // Create the alarm intent
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("isActivity", isActivity)
            putExtra("isLocation", isLocation)
            putExtra("location", location)
            putExtra("isWeather", isWeather)
            putExtra("weatherTypes", weatherTypesJson)
            if (isShared) {
                putExtra("isSharedAlarm", true)
            }
        }
        
        // Use the appropriate request code
        val requestCode = if (isShared) REQUEST_CODE_SHARED_ALARM else REQUEST_CODE_LOCAL_ALARM
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        // Schedule the main alarm
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager?.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            } else {
                alarmManager?.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            }
            
            // Save this as the last scheduled alarm
            lastScheduledAlarmTime = triggerAtMillis
            lastScheduledAlarmType = alarmType
            
            Log.d("MainActivity", "$alarmType alarm scheduled for ${Date(triggerAtMillis)}")
            
            // For activity monitoring (if enabled)
            if (isActivity == 1) {
                scheduleActivityMonitoring(isShared, triggerAtMillis)
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error scheduling $alarmType alarm: ${e.message}")
        }
    }
    
    private fun scheduleActivityMonitoring(isShared: Boolean, triggerAtMillis: Long) {
        val activityCheckIntent = Intent(this, ScreenMonitorService::class.java).apply {
            if (isShared) {
                putExtra("isSharedAlarm", true)
            }
        }
        
        // Use the appropriate request code
        val requestCode = if (isShared) REQUEST_CODE_SHARED_ACTIVITY else REQUEST_CODE_LOCAL_ACTIVITY
        
        val pendingActivityCheckIntent = PendingIntent.getService(
            this,
            requestCode,
            activityCheckIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        // Schedule the activity check to run 15 minutes before the alarm
        val activityCheckTime = triggerAtMillis - (15 * 60 * 1000)
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager?.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    activityCheckTime,
                    pendingActivityCheckIntent
                )
            } else {
                alarmManager?.setExact(
                    AlarmManager.RTC_WAKEUP,
                    activityCheckTime,
                    pendingActivityCheckIntent
                )
            }
            
            val alarmType = if (isShared) "shared" else "local"
            Log.d("MainActivity", "Activity monitoring for $alarmType alarm scheduled for ${Date(activityCheckTime)}")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error scheduling activity monitoring: ${e.message}")
        }
    }
}
