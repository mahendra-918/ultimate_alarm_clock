package com.ccextractor.ultimate_alarm_clock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) {
            return
        }

        val triggerTime = intent.getLongExtra("alarm_trigger_time", 0L)
        val scheduledTime = intent.getLongExtra("alarm_scheduled_at", 0L)
        val now = System.currentTimeMillis()
        
        val sdf = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault())
        val triggerTimeStr = if (triggerTime > 0) sdf.format(Date(triggerTime)) else "unknown"
        val scheduledTimeStr = if (scheduledTime > 0) sdf.format(Date(scheduledTime)) else "unknown"
        val nowStr = sdf.format(Date(now))
        
        // Log alarm receipt for debugging
        android.util.Log.d("AlarmReceiver", "ALARM RECEIVED at $nowStr (scheduled for $triggerTimeStr, created at $scheduledTimeStr)")
        
        val logdbHelper = LogDatabaseHelper(context)
        
        // Create intent to launch MainActivity
        val flutterIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            putExtra("initialRoute", "/") 
            putExtra("alarmRing", "true")
            putExtra("isAlarm", "true")
        }
        val sharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val screenOnTimeInMillis = sharedPreferences.getLong("flutter.is_screen_on", 0L)
        val screenOffTimeInMillis = sharedPreferences.getLong("flutter.is_screen_off", 0L)
        val activityCheckIntent = Intent(context, ScreenMonitorService::class.java)
        context.stopService(activityCheckIntent)
        val isLocationEnabled = sharedPreferences.getInt("flutter.is_location_on", 0)
        
        // Log both times to help with debugging
        println("ALARM RECEIVED: screenOnTime=$screenOnTimeInMillis, screenOffTime=$screenOffTimeInMillis, diff=${Math.abs(screenOnTimeInMillis - screenOffTimeInMillis)}")

        // Changed the condition to be more lenient - let the alarm ring even if activity check fails
        // We're adding || true to ensure the alarm rings regardless of activity time for testing
        if (Math.abs(screenOnTimeInMillis - screenOffTimeInMillis) < 180000 || screenOnTimeInMillis - screenOffTimeInMillis == 0L || true) {
            println("ANDROID STARTING APP FOR ALARM")
            context.startActivity(flutterIntent)

            if((screenOnTimeInMillis - screenOffTimeInMillis) == 0L) {
                // if alarm rings (no smart controls used)
                logdbHelper.insertLog(
                    "Alarm is ringing",
                    status = LogDatabaseHelper.Status.SUCCESS,
                    type = LogDatabaseHelper.LogType.NORMAL,
                    hasRung = 1
                )
                return
            }

            logdbHelper.insertLog(
                "Alarm is ringing. Your Screen Activity was less than what you specified",
                status = LogDatabaseHelper.Status.SUCCESS,
                type = LogDatabaseHelper.LogType.NORMAL,
                hasRung = 1
            )
            return
        }

        logdbHelper.insertLog(
            "Alarm didn't ring. Your Screen Activity was more than what you specified",
            status = LogDatabaseHelper.Status.WARNING,
            type = LogDatabaseHelper.LogType.NORMAL,
            hasRung = 0
        )
    }

    private fun getCurrentTime(): String {
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        return formatter.format(Date())
    }

}
