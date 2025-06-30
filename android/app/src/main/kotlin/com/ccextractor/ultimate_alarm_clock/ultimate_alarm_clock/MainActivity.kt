package com.ccextractor.ultimate_alarm_clock

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.AlarmManager
import android.app.KeyguardManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import com.ccextractor.ultimate_alarm_clock.getLatestTimer
import com.ccextractor.ultimate_alarm_clock.ultimate_alarm_clock.AlarmUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Date
import java.util.Calendar
import java.text.SimpleDateFormat
import java.util.Locale
import android.app.NotificationChannel
import android.graphics.Color
import androidx.core.app.NotificationCompat


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
        
        
        alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }
    
    override fun onDestroy() {
        super.onDestroy()
        
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
            
            
            isSharedAlarm = intent.getBooleanExtra(SHARED_ALARM_KEY, false)
            if (isSharedAlarm) {
                alarmConfig["isSharedAlarm"] = true
                println("NATIVE RECEIVED SHARED ALARM FLAG")
            } else {
            
                alarmConfig["isSharedAlarm"] = false
                println("NATIVE RECEIVED LOCAL ALARM FLAG")
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
                val weatherTypes = call.argument<String>("weatherTypes") ?: "[]"
                val alarmID = call.argument<String>("alarmID") ?: ""
                
            
                if (isSharedAlarm) {
                    println("CANCELING ONLY SHARED ALARMS BEFORE SCHEDULING")
                    cancelAlarm(REQUEST_CODE_SHARED_ALARM, true)
                    cancelAlarm(REQUEST_CODE_SHARED_ACTIVITY, true)
                    } else {
                    println("CANCELING ONLY LOCAL ALARMS BEFORE SCHEDULING")
                    cancelAlarm(REQUEST_CODE_LOCAL_ALARM, false)
                    cancelAlarm(REQUEST_CODE_LOCAL_ACTIVITY, false)
                }

                
                if (isSharedAlarm) {
                    val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    val editor = sharedPreferences.edit()
                    editor.putBoolean("flutter.has_active_shared_alarm", true)
                    editor.putString("flutter.shared_alarm_id", alarmID)
                    
                
                    val calendar = Calendar.getInstance()
                    calendar.timeInMillis = System.currentTimeMillis() + intervalToAlarm
                    val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())
                    val alarmTime = timeFormat.format(calendar.time)
                    editor.putString("flutter.shared_alarm_time", alarmTime)
                    
                
                    editor.putInt("flutter.shared_alarm_activity", if (isActivityEnabled) 1 else 0)
                    editor.putInt("flutter.shared_alarm_location", if (isLocationEnabled) 1 else 0)
                    editor.putString("flutter.shared_alarm_location_data", location)
                    editor.putInt("flutter.shared_alarm_weather", if (isWeatherEnabled) 1 else 0)
                    editor.putString("flutter.shared_alarm_weather_types", weatherTypes)
                    editor.apply()
                    
                    Log.d("Scheduling shared alarm", "Time to ring: $intervalToAlarm")
                } else {
                    Log.d("Scheduling local alarm", "Time to ring: $intervalToAlarm")
                }

                AlarmUtils.scheduleAlarm(
                    context,
                        intervalToAlarm,
                        if (isActivityEnabled) 1 else 0,
                        if (isLocationEnabled) 1 else 0,
                        location,
                        if (isWeatherEnabled) 1 else 0,
                    weatherTypes,
                    isSharedAlarm,
                    alarmID
                    )

                result.success("Alarm scheduled")
            } else if (call.method == "cancelAllAlarms") {
                println("FLUTTER CALLED CANCEL ALARMS")
                cancelAllAlarms()
                result.success("All alarms canceled")
            } else if (call.method == "cancelSpecificAlarm") {
                
                val isSharedAlarm = call.argument<Boolean>("isSharedAlarm") ?: false
                println("FLUTTER CALLED CANCEL SPECIFIC ALARM: ${if (isSharedAlarm) "SHARED" else "LOCAL"}")
                cancelSpecificAlarm(isSharedAlarm)
                result.success("Specific alarm canceled")
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
            } else if (call.method == "cancelAlarmById") {
                
                val alarmID = call.argument<String>("alarmID") ?: ""
                val isSharedAlarm = call.argument<Boolean>("isSharedAlarm") ?: false
                
                println("FLUTTER CALLED CANCEL ALARM BY ID: $alarmID, isShared: $isSharedAlarm")
                
                
                AlarmUtils.cancelAlarmById(context, alarmID, isSharedAlarm)
                
                result.success("Alarm canceled by ID")
            } else if (call.method == "updateSharedAlarmCache") {
                
                val alarmTime = call.argument<String>("alarmTime") ?: ""
                val alarmID = call.argument<String>("alarmID") ?: ""
                val intervalToAlarm = call.argument<Number>("intervalToAlarm")?.toLong() ?: 0L
                val isActivityEnabled = call.argument<Boolean>("isActivityEnabled") ?: false
                val isLocationEnabled = call.argument<Boolean>("isLocationEnabled") ?: false
                val location = call.argument<String>("location") ?: "0.0,0.0"
                val isWeatherEnabled = call.argument<Boolean>("isWeatherEnabled") ?: false
                val weatherTypes = call.argument<String>("weatherTypes") ?: "[]"
                
                Log.d("MainActivity", "Updating shared alarm cache with time: $alarmTime, ID: $alarmID")
                
                val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val editor = sharedPreferences.edit()
                editor.putBoolean("flutter.has_active_shared_alarm", true)
                editor.putString("flutter.shared_alarm_time", alarmTime)
                editor.putString("flutter.shared_alarm_id", alarmID)
                editor.putInt("flutter.shared_alarm_activity", if (isActivityEnabled) 1 else 0)
                editor.putInt("flutter.shared_alarm_location", if (isLocationEnabled) 1 else 0)
                editor.putString("flutter.shared_alarm_location_data", location)
                editor.putInt("flutter.shared_alarm_weather", if (isWeatherEnabled) 1 else 0)
                editor.putString("flutter.shared_alarm_weather_types", weatherTypes)
                editor.apply()
                
                Log.d("MainActivity", "Successfully updated shared alarm cache")
                result.success("Shared alarm cache updated")
            } else if (call.method == "clearSharedAlarmCache") {
                
                val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val editor = sharedPreferences.edit()
                editor.putBoolean("flutter.has_active_shared_alarm", false)
                editor.remove("flutter.shared_alarm_time")
                editor.remove("flutter.shared_alarm_id")
                editor.remove("flutter.shared_alarm_activity")
                editor.remove("flutter.shared_alarm_location")
                editor.remove("flutter.shared_alarm_location_data")
                editor.remove("flutter.shared_alarm_weather")
                editor.remove("flutter.shared_alarm_weather_types")
                editor.apply()
                
                Log.d("MainActivity", "Cleared shared alarm cache")
                result.success(null)
            } else if (call.method == "showAlarmUpdateNotification") {
                
                val title = call.argument<String>("title") ?: "Alarm Updated"
                val message = call.argument<String>("message") ?: "Your shared alarm has been updated"
                val alarmTime = call.argument<String>("alarmTime") ?: ""
                
                showAlarmUpdateNotification(title, message, alarmTime)
                result.success(null)
            } else if (call.method == "checkPersistedSharedAlarm") {
                
                val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val hasActiveSharedAlarm = sharedPreferences.getBoolean("flutter.has_active_shared_alarm", false)
                
                if (hasActiveSharedAlarm) {
                    val alarmTime = sharedPreferences.getString("flutter.shared_alarm_time", "")
                    val alarmId = sharedPreferences.getString("flutter.shared_alarm_id", "")
                    val isActivityEnabled = sharedPreferences.getInt("flutter.shared_alarm_activity", 0) == 1
                    val isLocationEnabled = sharedPreferences.getInt("flutter.shared_alarm_location", 0) == 1
                    val location = sharedPreferences.getString("flutter.shared_alarm_location_data", "0.0,0.0") ?: "0.0,0.0"
                    val isWeatherEnabled = sharedPreferences.getInt("flutter.shared_alarm_weather", 0) == 1
                    val weatherTypes = sharedPreferences.getString("flutter.shared_alarm_weather_types", "[]") ?: "[]"
                    
                    val persistedAlarmData = mapOf(
                        "alarmTime" to alarmTime,
                        "alarmId" to alarmId,
                        "isActivityEnabled" to isActivityEnabled,
                        "isLocationEnabled" to isLocationEnabled,
                        "location" to location,
                        "isWeatherEnabled" to isWeatherEnabled,
                        "weatherTypes" to weatherTypes
                    )
                    
                    Log.d("MainActivity", "Found persisted shared alarm: $persistedAlarmData")
                    result.success(persistedAlarmData)
                } else {
                    Log.d("MainActivity", "No persisted shared alarm found")
                    result.success(null)
                }
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
        
        cancelAlarm(REQUEST_CODE_LOCAL_ALARM, false)
        cancelAlarm(REQUEST_CODE_SHARED_ALARM, true)
        cancelAlarm(REQUEST_CODE_LOCAL_ACTIVITY, false)
        cancelAlarm(REQUEST_CODE_SHARED_ACTIVITY, true)
        
        
        clearSharedAlarmData()
        
        lastScheduledAlarmTime = 0
        lastScheduledAlarmType = ""
        
        Log.d("MainActivity", "All alarms canceled")
    }
    
    
    
    private fun cancelSpecificAlarm(isShared: Boolean) {
        Log.d("MainActivity", "===== CANCELING SPECIFIC ALARM: ${if (isShared) "SHARED" else "LOCAL"} =====")
        
        if (isShared) {

            cancelAlarm(REQUEST_CODE_SHARED_ALARM, true)
            cancelAlarm(REQUEST_CODE_SHARED_ACTIVITY, true)
            clearSharedAlarmData() // Clear shared alarm data since it just rang
            Log.d("MainActivity", "Shared alarm canceled - Local alarms should be preserved")
            
            
            try {
                val pendingIntent = PendingIntent.getBroadcast(
                    this,
                    REQUEST_CODE_LOCAL_ALARM,
                    Intent(this, AlarmReceiver::class.java),
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_MUTABLE
                )
                if (pendingIntent != null) {
                    Log.d("MainActivity", "CONFIRMED: Local alarm is still active after shared alarm cancellation")
                } else {
                    Log.d("MainActivity", "WARNING: No local alarm found after shared alarm cancellation")
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Error checking for local alarms: ${e.message}")
            }
        } else {
            // Cancel only the local alarm that just rang
            cancelAlarm(REQUEST_CODE_LOCAL_ALARM, false)
            cancelAlarm(REQUEST_CODE_LOCAL_ACTIVITY, false)
            Log.d("MainActivity", "Local alarm canceled - Shared alarms should be preserved")
            
            
            try {
                val pendingIntent = PendingIntent.getBroadcast(
                    this,
                    REQUEST_CODE_SHARED_ALARM,
                    Intent(this, AlarmReceiver::class.java).apply {
                        putExtra("isSharedAlarm", true)
                    },
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_MUTABLE
                )
                if (pendingIntent != null) {
                    Log.d("MainActivity", "CONFIRMED: Shared alarm is still active after local alarm cancellation")
                } else {
                    Log.d("MainActivity", "WARNING: No shared alarm found after local alarm cancellation")
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Error checking for shared alarms: ${e.message}")
            }
        }
    }
    
    private fun clearSharedAlarmData() {
        val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putBoolean("flutter.has_active_shared_alarm", false)
        editor.remove("flutter.shared_alarm_time")
        editor.remove("flutter.shared_alarm_id")
        editor.remove("flutter.shared_alarm_activity")
        editor.remove("flutter.shared_alarm_location")
        editor.remove("flutter.shared_alarm_location_data")
        editor.remove("flutter.shared_alarm_weather")
        editor.remove("flutter.shared_alarm_weather_types")
        editor.apply()
        
        Log.d("MainActivity", "Cleared shared alarm data")
    }
    
    private fun cancelAlarm(requestCode: Int, isShared: Boolean) {
        Log.d("MainActivity", "Attempting to cancel alarm with request code: $requestCode, isShared: $isShared")
        
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            if (isShared) {
                putExtra("isSharedAlarm", true)
            }
        }
        
        
        val checkIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_MUTABLE
        )
        
        if (checkIntent == null) {
            Log.d("MainActivity", "No alarm found to cancel for request code: $requestCode, isShared: $isShared")
            return
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
            Log.d("MainActivity", "Successfully canceled alarm with request code: $requestCode, isShared: $isShared")
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
        
        
        if (triggerAtMillis == lastScheduledAlarmTime && alarmType == lastScheduledAlarmType) {
            Log.d("MainActivity", "Skipping duplicate alarm schedule: $alarmType at ${Date(triggerAtMillis)}")
            return
        }
        
        
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
        
        
        val requestCode = if (isShared) REQUEST_CODE_SHARED_ALARM else REQUEST_CODE_LOCAL_ALARM
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        
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
            
        
            lastScheduledAlarmTime = triggerAtMillis
            lastScheduledAlarmType = alarmType
            
            Log.d("MainActivity", "$alarmType alarm scheduled for ${Date(triggerAtMillis)}")
            
        
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
        
        
        val requestCode = if (isShared) REQUEST_CODE_SHARED_ACTIVITY else REQUEST_CODE_LOCAL_ACTIVITY
        
        val pendingActivityCheckIntent = PendingIntent.getService(
            this,
            requestCode,
            activityCheckIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        
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

    private fun scheduleNextAlarm() {
        try {
            val profile = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.profile", "Default") ?: "Default"
            
            
            val nextAlarm = determineNextAlarm(context, profile)
            
            if (nextAlarm == null) {
                Log.d("MainActivity", "No alarms to schedule")
                return
            }
            
            val intervalToAlarm = nextAlarm["interval"] as Long
            val isActivity = nextAlarm["isActivity"] as Int
            val isLocation = nextAlarm["isLocation"] as Int
            val location = nextAlarm["location"] as String
            val isWeather = nextAlarm["isWeather"] as Int
            val weatherTypes = nextAlarm["weatherTypes"] as String
            val isShared = nextAlarm["isSharedAlarm"] as Boolean
            
            Log.d("MainActivity", "Scheduling next alarm: isShared=$isShared, interval=$intervalToAlarm")
            
            // Schedule the alarm
            scheduleAlarmInternal(
                intervalToAlarm,
                isActivity,
                isLocation,
                location,
                isWeather,
                weatherTypes,
                isShared
            )
            
            Log.d("MainActivity", "Successfully scheduled ${if (isShared) "shared" else "local"} alarm")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error scheduling next alarm: ${e.message}")
        }
    }

    private fun showAlarmUpdateNotification(title: String, message: String, alarmTime: String) {
        try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "alarm_updates",
                    "Alarm Updates",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifications for shared alarm updates"
                    enableLights(true)
                    lightColor = Color.BLUE
                    enableVibration(true)
                    vibrationPattern = longArrayOf(100, 200, 300, 400)
                }
                notificationManager.createNotificationChannel(channel)
            }
            
            
            val notification = NotificationCompat.Builder(this, "alarm_updates")
                .setContentTitle(title)
                .setContentText(message)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                .build()
            
            notificationManager.notify(System.currentTimeMillis().toInt(), notification)
            Log.d("MainActivity", "📬 Showed alarm update notification: $title - $message")
        } catch (e: Exception) {
            Log.e("MainActivity", "❌ Error showing alarm update notification: ${e.message}")
        }
    }
}