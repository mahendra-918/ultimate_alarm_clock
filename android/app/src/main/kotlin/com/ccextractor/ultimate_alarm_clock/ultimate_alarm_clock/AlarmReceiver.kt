package com.ccextractor.ultimate_alarm_clock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class AlarmReceiver : BroadcastReceiver() {
    companion object {
        // Keep track of recently triggered alarms to prevent duplicates
        private var lastTriggeredTime = 0L
        private var lastTriggeredType = ""
        private const val DUPLICATE_PREVENTION_WINDOW = 10000 // 10 seconds
    }
    
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) {
            return
        }

        val isSharedAlarm = intent.getBooleanExtra("isSharedAlarm", false)
        val currentTime = System.currentTimeMillis()
        val alarmType = if (isSharedAlarm) "shared" else "local"
        
        // Check for duplicate alarms firing too close together
        if (currentTime - lastTriggeredTime < DUPLICATE_PREVENTION_WINDOW && 
            alarmType == lastTriggeredType) {
            Log.d("AlarmReceiver", "Preventing duplicate $alarmType alarm trigger (within ${DUPLICATE_PREVENTION_WINDOW}ms)")
            return
        }
        
        // Update last triggered info
        lastTriggeredTime = currentTime
        lastTriggeredType = alarmType
        
        val logdbHelper = LogDatabaseHelper(context)
        val flutterIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)

            putExtra("initialRoute", "/")
            putExtra("alarmRing", "true")
            putExtra("isAlarm", "true")
            
            // Pass along if this is a shared alarm to help Flutter identify it
            if (isSharedAlarm) {
                putExtra("isSharedAlarm", true)
            }
        }
        
        val sharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Log the alarm type for debugging
        Log.d("AlarmReceiver", "ALARM TRIGGERED: $alarmType alarm at ${getCurrentTime()}")
        println("ANDROID ALARM TRIGGERED: $alarmType alarm at ${getCurrentTime()}")
        
        // Determine which set of preferences to use based on alarm type
        val prefix = if (isSharedAlarm) "flutter.shared_" else "flutter."
        val screenOnTimeInMillis = sharedPreferences.getLong("${prefix}is_screen_on", 0L)
        val screenOffTimeInMillis = sharedPreferences.getLong("${prefix}is_screen_off", 0L)
        
        // Stop the activity monitoring service
        val activityCheckIntent = Intent(context, ScreenMonitorService::class.java)
        context.stopService(activityCheckIntent)
        
        val isLocationEnabled = sharedPreferences.getInt("flutter.is_location_on", 0)

        // Only check screen activity if the alarm has activity monitoring enabled
        val isActivityEnabled = intent.getIntExtra("isActivity", 0) == 1
        
        if (!isActivityEnabled || Math.abs(screenOnTimeInMillis - screenOffTimeInMillis) < 180000 || screenOnTimeInMillis - screenOffTimeInMillis == 0L) {
            println("ANDROID STARTING APP")
            context.startActivity(flutterIntent)

            if (isSharedAlarm) {
                logdbHelper.insertLog(
                    "Shared alarm is ringing at ${getCurrentTime()}",
                    status = LogDatabaseHelper.Status.SUCCESS,
                    type = LogDatabaseHelper.LogType.NORMAL,
                    hasRung = 1
                )
                return
            }
            
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
        val formatter = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        return formatter.format(Date())
    }
}
