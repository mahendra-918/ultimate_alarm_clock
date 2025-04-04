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



        val logdbHelper = LogDatabaseHelper(context)
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
        val isNegativeActivity = sharedPreferences.getInt("flutter.is_negative_activity", 0) == 1
        val activityThreshold = 180000 // 3 minutes in milliseconds

        val screenActivity = Math.abs(screenOnTimeInMillis - screenOffTimeInMillis)
        val isUnderThreshold = screenActivity < activityThreshold || screenActivity == 0L

        // Determine if we should ring based on activity and negative flag
        // isNegativeActivity true: ring if NOT active (isUnderThreshold true)
        // isNegativeActivity false: ring if active (isUnderThreshold true)
        val shouldRing = if (isNegativeActivity) {
            !isUnderThreshold // Ring if NOT under threshold (activity is high)
        } else {
            isUnderThreshold // Ring if under threshold (activity is low)
        }

        if (shouldRing) {
            println("ANDROID STARTING APP")
            context.startActivity(flutterIntent)

            if (screenActivity == 0L) {
                // if alarm rings (no smart controls used)
                logdbHelper.insertLog(
                    "Alarm is ringing",
                    status = LogDatabaseHelper.Status.SUCCESS,
                    type = LogDatabaseHelper.LogType.NORMAL,
                    hasRung = 1
                )
                return
            }

            val message = if (isNegativeActivity) {
                "Alarm is ringing. Your Screen Activity was MORE than what you specified"
            } else {
                "Alarm is ringing. Your Screen Activity was LESS than what you specified"
            }
            
            logdbHelper.insertLog(
                message,
                status = LogDatabaseHelper.Status.SUCCESS,
                type = LogDatabaseHelper.LogType.NORMAL,
                hasRung = 1
            )
            return
        }

        val message = if (isNegativeActivity) {
            "Alarm didn't ring. Your Screen Activity was LESS than what you specified"
        } else {
            "Alarm didn't ring. Your Screen Activity was MORE than what you specified"
        }
        
        logdbHelper.insertLog(
            message,
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
