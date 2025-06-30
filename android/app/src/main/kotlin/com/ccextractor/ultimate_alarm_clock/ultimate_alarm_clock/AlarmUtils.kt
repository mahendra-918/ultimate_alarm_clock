package com.ccextractor.ultimate_alarm_clock.ultimate_alarm_clock

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.annotation.SuppressLint
import com.ccextractor.ultimate_alarm_clock.AlarmReceiver
import com.ccextractor.ultimate_alarm_clock.MainActivity
import com.ccextractor.ultimate_alarm_clock.ScreenMonitorService
import java.util.*

object AlarmUtils {
    @SuppressLint("ScheduleExactAlarm")
    fun scheduleAlarm(
        context: Context,
        intervalToAlarm: Long,
        isActivity: Int,
        isLocation: Int,
        location: String,
        isWeather: Int,
        weatherTypes: String,
        isShared: Boolean = false,
        alarmID: String = ""
    ) {
        val alarmType = if (isShared) "shared" else "local"
        
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val triggerAtMillis = System.currentTimeMillis() + intervalToAlarm
        
            Log.d("AlarmUtils", "Scheduling $alarmType alarm for ${Date(triggerAtMillis)} with ID: $alarmID")
        
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                putExtra("isActivity", isActivity)
                putExtra("isLocation", isLocation)
                putExtra("location", location)
                putExtra("isWeather", isWeather)
                putExtra("weatherTypes", weatherTypes)
                if (isShared) {
                    putExtra("isSharedAlarm", true)
                    Log.d("AlarmUtils", "Setting isSharedAlarm flag in intent")
                }
                if (alarmID.isNotEmpty()) {
                    putExtra("alarmID", alarmID)
                }
            }
        
            val requestCode = if (isShared) 
                MainActivity.REQUEST_CODE_SHARED_ALARM 
            else 
                MainActivity.REQUEST_CODE_LOCAL_ALARM
            
            Log.d("AlarmUtils", "Using request code $requestCode for $alarmType alarm")
        
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
            }
            
            Log.d("AlarmUtils", "$alarmType alarm successfully scheduled for ${Date(triggerAtMillis)}")
            
            if (isActivity == 1) {
                scheduleActivityMonitoring(context, alarmManager, isShared, triggerAtMillis)
            }
        } catch (e: Exception) {
            Log.e("AlarmUtils", "Error scheduling $alarmType alarm: ${e.message}")
        }
    }

    fun cancelAlarmById(context: Context, alarmID: String, isShared: Boolean) {
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, AlarmReceiver::class.java)
            
            val requestCode = if (isShared) 
                MainActivity.REQUEST_CODE_SHARED_ALARM 
            else 
                MainActivity.REQUEST_CODE_LOCAL_ALARM
            
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            
            alarmManager.cancel(pendingIntent)
            
            val alarmType = if (isShared) "shared" else "local"
            Log.d("AlarmUtils", "Canceled $alarmType alarm with ID: $alarmID")
        } catch (e: Exception) {
            Log.e("AlarmUtils", "Error canceling alarm with ID $alarmID: ${e.message}")
        }
    }

    private fun scheduleActivityMonitoring(
        context: Context,
        alarmManager: AlarmManager,
        isShared: Boolean,
        triggerAtMillis: Long
    ) {
        val activityCheckIntent = Intent(context, ScreenMonitorService::class.java).apply {
            if (isShared) {
                putExtra("isSharedAlarm", true)
            }
        }
        
        val requestCode = if (isShared) 
            MainActivity.REQUEST_CODE_SHARED_ACTIVITY 
        else 
            MainActivity.REQUEST_CODE_LOCAL_ACTIVITY
        
        val pendingActivityCheckIntent = PendingIntent.getService(
            context,
            requestCode,
            activityCheckIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        
        val activityCheckTime = triggerAtMillis - (15 * 60 * 1000)
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    activityCheckTime,
                    pendingActivityCheckIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    activityCheckTime,
                    pendingActivityCheckIntent
                )
            }
            
            val alarmType = if (isShared) "shared" else "local"
            Log.d("AlarmUtils", "Activity monitoring for $alarmType alarm scheduled for ${Date(activityCheckTime)}")
        } catch (e: Exception) {
            Log.e("AlarmUtils", "Error scheduling activity monitoring: ${e.message}")
        }
    }
} 