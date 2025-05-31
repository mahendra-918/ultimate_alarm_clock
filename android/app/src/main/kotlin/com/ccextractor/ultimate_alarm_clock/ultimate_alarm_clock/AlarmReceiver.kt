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
            Log.e("AlarmReceiver", "Received null context or intent")
            return
        }

        // Get all intent extras for debugging
        val extras = intent.extras
        Log.d("AlarmReceiver", "All intent extras: ${extras?.keySet()?.joinToString(", ") { "$it: ${extras.get(it)}" }}")

        val isSharedAlarm = intent.getBooleanExtra("isSharedAlarm", false)
        val currentTime = System.currentTimeMillis()
        val alarmType = if (isSharedAlarm) "shared" else "local"
        
        Log.d("AlarmReceiver", "===== ALARM FIRED: $alarmType ALARM =====")
        
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

            // Make sure we're setting all the required flags
            putExtra("initialRoute", "/")
            putExtra("alarmRing", "true")
            putExtra("isAlarm", "true")
            
            // Pass along if this is a shared alarm to help Flutter identify it
            if (isSharedAlarm) {
                putExtra("isSharedAlarm", true)
                Log.d("AlarmReceiver", "Setting isSharedAlarm=true in Flutter intent")
            } else {
                // Explicitly set to false to avoid any ambiguity
                putExtra("isSharedAlarm", false)
                Log.d("AlarmReceiver", "This is a local alarm - setting isSharedAlarm=false")
            }
        }
        
        val sharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Log the alarm type for debugging
        Log.d("AlarmReceiver", "ALARM TRIGGERED: $alarmType alarm at ${getCurrentTime()}")
        println("ANDROID ALARM TRIGGERED: $alarmType alarm at ${getCurrentTime()}")
        
        // Check if other alarm types are still scheduled
        checkOtherScheduledAlarms(context, isSharedAlarm)
        
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

    /**
     * Checks if there are any other alarm types still scheduled
     */
    private fun checkOtherScheduledAlarms(context: Context, isCurrentAlarmShared: Boolean) {
        try {
            // Check for the opposite alarm type
            val requestCode = if (isCurrentAlarmShared) 
                MainActivity.REQUEST_CODE_LOCAL_ALARM 
            else 
                MainActivity.REQUEST_CODE_SHARED_ALARM
                
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                if (!isCurrentAlarmShared) {
                    putExtra("isSharedAlarm", true)
                }
            }
            
            val pendingIntent = android.app.PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                android.app.PendingIntent.FLAG_NO_CREATE or android.app.PendingIntent.FLAG_MUTABLE
            )
            
            val otherAlarmType = if (isCurrentAlarmShared) "local" else "shared"
            
            if (pendingIntent != null) {
                Log.d("AlarmReceiver", "CONFIRMED: $otherAlarmType alarm is still scheduled")
            } else {
                Log.d("AlarmReceiver", "WARNING: No $otherAlarmType alarm is currently scheduled")
            }
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "Error checking for other alarm types: ${e.message}")
        }
    }

    private fun getCurrentTime(): String {
        val formatter = SimpleDateFormat("HH:mm:ss", Locale.getDefault())
        return formatter.format(Date())
    }
}