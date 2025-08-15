package com.ccextractor.ultimate_alarm_clock


import android.app.AlarmManager
import android.content.Context
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import java.util.Date
import java.util.Locale
import android.util.Log
import android.icu.text.SimpleDateFormat
import com.ccextractor.ultimate_alarm_clock.MainActivity
import com.ccextractor.ultimate_alarm_clock.ultimate_alarm_clock.AlarmUtils
import com.ccextractor.ultimate_alarm_clock.LogDatabaseHelper
import java.util.Calendar
import android.app.PendingIntent
import android.content.Intent
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat
import android.app.ActivityManager

class FirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        Log.d("FCM", "📱 FCM Message received: ${remoteMessage.data}")
        Log.d("FCM", "📱 Notification: ${remoteMessage.notification}")
        Log.d("FCM", "📱 App state: ${if (isAppInForeground()) "FOREGROUND" else "BACKGROUND/KILLED"}")
        
        val data = remoteMessage.data
        val notificationType = data["type"]
        val silent = data["silent"]
        
        Log.d("FCM", "🔍 Notification type: $notificationType, Silent: $silent")
        
        // Handle silent notifications (don't show UI notification)
        if (silent == "true") {
            Log.d("FCM", "🔇 Silent notification - processing without UI")
            when (notificationType) {
                "rescheduleAlarm" -> handleRescheduleAlarm(data)
                "sharedAlarm" -> handleSharedAlarmData(data)
            }
            return
        }
        
        // Handle notifications that should show UI
        when (notificationType) {
            "rescheduleAlarm" -> {
                Log.d("FCM", "🔔 Received reschedule alarm notification")
                handleRescheduleAlarm(data)
                
                val alarmTime = data["newAlarmTime"] ?: "Unknown"
                val ownerName = data["ownerName"] ?: "Someone"
                showNotification(
                    "🔔 Shared Alarm Updated!",
                    "$ownerName updated your shared alarm to $alarmTime",
                    "alarm_updates"
                )
            }
            "sharedAlarm", "sharedItem" -> {
                Log.d("FCM", "🔔 Received shared alarm notification")
                handleSharedAlarmData(data)
                
                val title = remoteMessage.notification?.title ?: "🔔 New Shared Alarm!"
                val body = remoteMessage.notification?.body ?: "You have received a new shared alarm"
                
                showNotification(title, body, "shared_alarms")
            }
            else -> {
                Log.d("FCM", "🔔 Received general notification")
                
                if (remoteMessage.notification != null) {
                    showNotification(
                        remoteMessage.notification!!.title ?: "Notification",
                        remoteMessage.notification!!.body ?: "You have a new notification",
                        "default_channel"
                    )
                }
            }
        }
    }

    private fun handleSharedAlarmData(data: Map<String, String>) {
        try {
            Log.d("FCM", "🔄 Processing shared alarm data: $data")
            
            val sharedItemId = data["sharedItemId"]
            val message = data["message"]
            
            Log.d("FCM", "📦 Shared item ID: $sharedItemId")
            Log.d("FCM", "💬 Message: $message")
            
            // Store received shared alarm info for app to process
            val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            
            editor.putString("flutter.last_received_shared_alarm_id", sharedItemId ?: "")
            editor.putString("flutter.last_received_shared_alarm_message", message ?: "")
            editor.putLong("flutter.last_received_shared_alarm_timestamp", System.currentTimeMillis())
            editor.apply()
            
            Log.d("FCM", "✅ Shared alarm data stored for app processing")
        } catch (e: Exception) {
            Log.e("FCM", "❌ Error processing shared alarm data: ${e.message}")
        }
    }

    private fun handleRescheduleAlarm(data: Map<String, String>) {
        try {
            val alarmId = data["alarmId"] ?: data["firestoreAlarmId"] ?: ""
            val newAlarmTime = data["newAlarmTime"] ?: ""
            
            Log.d("FCM", "🔄 Handling reschedule for alarm: $alarmId to time: $newAlarmTime")
            
            if (alarmId.isEmpty() || newAlarmTime.isEmpty()) {
                Log.e("FCM", "❌ Missing required data for reschedule: alarmId=$alarmId, newTime=$newAlarmTime")
                return
            }
            
            
            val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            
            val currentAlarmId = sharedPreferences.getString("flutter.shared_alarm_id", "")
            val hasActiveSharedAlarm = sharedPreferences.getBoolean("flutter.has_active_shared_alarm", false)
            
            Log.d("FCM", "📋 Current state - hasActiveAlarm: $hasActiveSharedAlarm, currentId: $currentAlarmId")
            
            if (!hasActiveSharedAlarm || currentAlarmId != alarmId) {
                Log.d("FCM", "⚠️ This alarm is not currently active on this device, ignoring reschedule")
                return
            }
            
            
            Log.d("FCM", "🗑️ Canceling existing shared alarm")
            cancelSharedAlarm()
            
            
            val newIntervalToAlarm = parseAlarmTimeToInterval(newAlarmTime)
            if (newIntervalToAlarm <= 0) {
                Log.e("FCM", "❌ New alarm time is in the past or invalid: $newAlarmTime")
                // Clear the shared alarm data since it's no longer valid
                clearSharedAlarmData()
                return
            }
            
            
            val isActivityEnabled = sharedPreferences.getInt("flutter.shared_alarm_activity", 0) == 1
            val isLocationEnabled = sharedPreferences.getInt("flutter.shared_alarm_location", 0) == 1
            val location = sharedPreferences.getString("flutter.shared_alarm_location_data", "0.0,0.0") ?: "0.0,0.0"
            val locationConditionType = sharedPreferences.getInt("flutter.shared_alarm_location_condition", 2)
            val isWeatherEnabled = sharedPreferences.getInt("flutter.shared_alarm_weather", 0) == 1
            val weatherTypes = sharedPreferences.getString("flutter.shared_alarm_weather_types", "[]") ?: "[]"
            val weatherConditionType = sharedPreferences.getInt("flutter.shared_alarm_weather_condition", 2)
            
            Log.d("FCM", "🔧 Rescheduling with config - activity: $isActivityEnabled, location: $isLocationEnabled, weather: $isWeatherEnabled")
            
            
            AlarmUtils.scheduleAlarm(
                this,
                newIntervalToAlarm,
                if (isActivityEnabled) 1 else 0,
                if (isLocationEnabled) 1 else 0,
                location,
                locationConditionType,
                if (isWeatherEnabled) 1 else 0,
                weatherTypes,
                weatherConditionType,
                true, // isShared = true
                alarmId
            )
            
            
            val editor = sharedPreferences.edit()
            editor.putString("flutter.shared_alarm_time", newAlarmTime)
            editor.apply()
            
            Log.d("FCM", "✅ Successfully rescheduled shared alarm to: $newAlarmTime")
            
            // Log the rescheduling
            val logdbHelper = LogDatabaseHelper(this)
            logdbHelper.insertLog(
                "Shared alarm rescheduled remotely to $newAlarmTime (ID: $alarmId)",
                status = LogDatabaseHelper.Status.SUCCESS,
                type = LogDatabaseHelper.LogType.DEV,
                hasRung = 0,
                alarmID = alarmId
            )
            
            showNotification(
                "Alarm Updated",
                "Your shared alarm has been updated to $newAlarmTime"
            )
            
        } catch (e: Exception) {
            Log.e("FCM", "❌ Error handling reschedule alarm: ${e.message}")
            
            // Log the error
            val logdbHelper = LogDatabaseHelper(this)
            logdbHelper.insertLog(
                "Failed to reschedule shared alarm remotely: ${e.message}",
                status = LogDatabaseHelper.Status.ERROR,
                type = LogDatabaseHelper.LogType.DEV,
                hasRung = 0
            )
        }
    }
    
    private fun parseAlarmTimeToInterval(alarmTime: String): Long {
        try {
            
            val parts = alarmTime.split(":")
            if (parts.size != 2) return 0
            
            val hour = parts[0].toInt()
            val minute = parts[1].toInt()
            
            val calendar = Calendar.getInstance()
            val now = Calendar.getInstance()
            
            calendar.set(Calendar.HOUR_OF_DAY, hour)
            calendar.set(Calendar.MINUTE, minute)
            calendar.set(Calendar.SECOND, 0)
            calendar.set(Calendar.MILLISECOND, 0)
            
            
            if (calendar.before(now)) {
                calendar.add(Calendar.DAY_OF_MONTH, 1)
            }
            
            val intervalToAlarm = calendar.timeInMillis - now.timeInMillis
            Log.d("FCM", "⏰ Parsed alarm time $alarmTime to interval: ${intervalToAlarm}ms")
            
            return intervalToAlarm
        } catch (e: Exception) {
            Log.e("FCM", "❌ Error parsing alarm time $alarmTime: ${e.message}")
            return 0
        }
    }
    
    private fun cancelSharedAlarm() {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("isSharedAlarm", true)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                MainActivity.REQUEST_CODE_SHARED_ALARM,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            Log.d("FCM", "🗑️ Canceled existing shared alarm")
        } catch (e: Exception) {
            Log.e("FCM", "❌ Error canceling shared alarm: ${e.message}")
        }
    }
    
    private fun clearSharedAlarmData() {
        val sharedPreferences = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putBoolean("flutter.has_active_shared_alarm", false)
        editor.remove("flutter.shared_alarm_time")
        editor.remove("flutter.shared_alarm_id")
        editor.remove("flutter.shared_alarm_activity")
        editor.remove("flutter.shared_alarm_location")
        editor.remove("flutter.shared_alarm_location_data")
        editor.remove("flutter.shared_alarm_location_condition")
        editor.remove("flutter.shared_alarm_weather")
        editor.remove("flutter.shared_alarm_weather_types")
        editor.remove("flutter.shared_alarm_weather_condition")
        editor.apply()
        
        Log.d("FCM", "🧹 Cleared shared alarm data")
    }

    private fun showNotification(title: String, message: String, channelId: String = "alarm_updates") {
        try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Create notification channels
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                createNotificationChannels(notificationManager)
            }
            
            // Create intent for when notification is tapped
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                putExtra("from_notification", true)
                putExtra("notification_type", channelId)
            }
            
            val pendingIntent = PendingIntent.getActivity(
                this, 
                System.currentTimeMillis().toInt(), 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            
            val notification = NotificationCompat.Builder(this, channelId)
                .setContentTitle(title)
                .setContentText(message)
                .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setContentIntent(pendingIntent)
                .build()
            
            val notificationId = System.currentTimeMillis().toInt()
            notificationManager.notify(notificationId, notification)
            
            Log.d("FCM", "📬 Notification shown: $title - $message (Channel: $channelId, ID: $notificationId)")
        } catch (e: Exception) {
            Log.e("FCM", "❌ Error showing notification: ${e.message}")
        }
    }

    private fun createNotificationChannels(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Alarm updates channel
            val alarmUpdatesChannel = NotificationChannel(
                "alarm_updates",
                "Alarm Updates", 
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for shared alarm updates"
                enableVibration(true)
                enableLights(true)
                setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI, null)
            }
            
            // Shared alarms channel
            val sharedAlarmsChannel = NotificationChannel(
                "shared_alarms",
                "Shared Alarms",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for new shared alarms"
                enableVibration(true)
                enableLights(true)
                setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI, null)
            }
            
            // Default channel
            val defaultChannel = NotificationChannel(
                "default_channel",
                "General Notifications",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "General app notifications"
            }
            
            notificationManager.createNotificationChannel(alarmUpdatesChannel)
            notificationManager.createNotificationChannel(sharedAlarmsChannel)
            notificationManager.createNotificationChannel(defaultChannel)
            
            Log.d("FCM", "✅ Notification channels created")
        }
    }

    private fun isAppInForeground(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val appProcesses = activityManager.runningAppProcesses ?: return false
        
        val packageName = packageName
        for (appProcess in appProcesses) {
            if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND 
                && appProcess.processName == packageName) {
                return true
            }
        }
        return false
    }
}