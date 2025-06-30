package com.ccextractor.ultimate_alarm_clock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) {
            return
        }

        val logdbHelper = LogDatabaseHelper(context)
        val flutterIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            putExtra("initialRoute", "/")
            putExtra("alarmRing", "true")
            putExtra("isAlarm", "true")
        }
        
        val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        
        val screenOnTimeInMillis = sharedPreferences.getLong("flutter.is_screen_on", 0L)
        val screenOffTimeInMillis = sharedPreferences.getLong("flutter.is_screen_off", 0L)
        
        
        val activityConditionType = sharedPreferences.getInt("flutter.activity_condition_type", 0)
        val activityInterval = sharedPreferences.getInt("flutter.activity_interval", 30)
        
        
        val activityCheckIntent = Intent(context, ScreenMonitorService::class.java)
        context.stopService(activityCheckIntent)

        Log.d("AlarmReceiver", "Screen On: $screenOnTimeInMillis, Screen Off: $screenOffTimeInMillis")
        Log.d("AlarmReceiver", "Condition Type: $activityConditionType, Interval: $activityInterval minutes")

        // If no screen activity monitoring (off or no data), ring the alarm
        if (activityConditionType == 0 || (screenOnTimeInMillis == 0L && screenOffTimeInMillis == 0L)) {
            Log.d("AlarmReceiver", "No screen activity monitoring - ringing alarm")
            context.startActivity(flutterIntent)
            logdbHelper.insertLog(
                "Alarm is ringing (no screen activity monitoring)",
                status = LogDatabaseHelper.Status.SUCCESS,
                type = LogDatabaseHelper.LogType.NORMAL,
                hasRung = 1
            )
            return
        }

        val currentTime = System.currentTimeMillis()
        val intervalInMillis = activityInterval * 60 * 1000L // Convert minutes to milliseconds
        
        val lastActivityTime = maxOf(screenOnTimeInMillis, screenOffTimeInMillis)
        val timeSinceLastActivity = currentTime - lastActivityTime
        val isActiveWithinInterval = timeSinceLastActivity <= intervalInMillis
        
        Log.d("AlarmReceiver", "Time since last activity: ${timeSinceLastActivity / 1000} seconds")
        Log.d("AlarmReceiver", "Active within interval ($activityInterval min): $isActiveWithinInterval")

        var shouldRing = false
        var logMessage = ""

        when (activityConditionType) {
            1 -> { // Ring when active
                shouldRing = isActiveWithinInterval
                logMessage = if (shouldRing) {
                    "Alarm is ringing - you have been active within $activityInterval minutes"
                } else {
                    "Alarm cancelled - you have NOT been active within $activityInterval minutes"
                }
            }
            2 -> { // Cancel when active (original behavior)
                shouldRing = !isActiveWithinInterval
                logMessage = if (shouldRing) {
                    "Alarm is ringing - you have NOT been active within $activityInterval minutes"
                } else {
                    "Alarm cancelled - you have been active within $activityInterval minutes"
                }
            }
            3 -> { // Ring when inactive
                shouldRing = !isActiveWithinInterval
                logMessage = if (shouldRing) {
                    "Alarm is ringing - you have been inactive for more than $activityInterval minutes"
                } else {
                    "Alarm cancelled - you have been active within $activityInterval minutes"
                }
            }
            4 -> { // Cancel when inactive
                shouldRing = isActiveWithinInterval
                logMessage = if (shouldRing) {
                    "Alarm is ringing - you have been active within $activityInterval minutes"
                } else {
                    "Alarm cancelled - you have been inactive for more than $activityInterval minutes"
                }
            }
            else -> {
                // Default to ringing if unknown condition type
                shouldRing = true
                logMessage = "Alarm is ringing (unknown condition type: $activityConditionType)"
            }
        }

        Log.d("AlarmReceiver", "Decision: shouldRing = $shouldRing")

        if (shouldRing) {
            println("ANDROID STARTING APP")
            context.startActivity(flutterIntent)
            logdbHelper.insertLog(
                logMessage,
                status = LogDatabaseHelper.Status.SUCCESS,
                type = LogDatabaseHelper.LogType.NORMAL,
                hasRung = 1
            )
        } else {
            logdbHelper.insertLog(
                logMessage,
                status = LogDatabaseHelper.Status.WARNING,
                type = LogDatabaseHelper.LogType.NORMAL,
                hasRung = 0
            )
        }
    }

    private fun getCurrentTime(): String {
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        return formatter.format(Date())
    }
}
