package com.ccextractor.ultimate_alarm_clock

import android.annotation.SuppressLint
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.CountDownTimer
import androidx.core.app.NotificationCompat
import com.ccextractor.ultimate_alarm_clock.getLatestTimer


class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
           val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val profile = sharedPreferences.getString("flutter.profile", "Default")

            val dbHelper = DatabaseHelper(context)
            val logdbHelper = LogDatabaseHelper(context)
            val db = dbHelper.readableDatabase
            val ringTime = getLatestAlarm(db, true, profile?:"Default", context)
            db.close()
            if (ringTime != null) {
                scheduleAlarm(
                    ringTime["interval"]!! as Long,
                    context,
                    ringTime["isActivity"]!! as Int,
                    ringTime["activityConditionType"]!! as Int,
                    ringTime["activityInterval"]!! as Int,
                    ringTime["isLocation"]!! as Int,
                    ringTime["location"]!! as String,
                    ringTime["isWeather"]!! as Int,
                    ringTime["weatherTypes"]!! as String,
                    ringTime["weatherConditionType"]!! as Int
                )
            }

            val timerdbhelper = TimerDatabaseHelper(context)
            val timerdb = timerdbhelper.readableDatabase
            val time = getLatestTimer(timerdb)
            timerdb.close()
            var notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val commonTimer = CommonTimerManager.getCommonTimer(object : TimerListener {
                override fun onTick(millisUntilFinished: Long) {
                    println(millisUntilFinished)
                    showTimerNotification(millisUntilFinished, "Timer", context)

                }

                override fun onFinish() {
                    notificationManager.cancel(1)
                }
            })
            createNotificationChannel(context)



            if (time != null) {

                // Start or stop the timer based on your requirements
                commonTimer.startTimer(time.second)

            }


        }
    }

    @SuppressLint("ScheduleExactAlarm")
    fun scheduleAlarm(
        milliSeconds: Long,
        context: Context,
        activityMonitor: Int,
        activityConditionType: Int,
        activityInterval: Int,
        locationMonitor: Int,
        setLocation: String,
        isWeather: Int,
        weatherTypes: String,
        weatherConditionType: Int
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        val activityCheckIntent = Intent(context, ScreenMonitorService::class.java)
        val pendingActivityCheckIntent = PendingIntent.getService(
            context,
            4,
            activityCheckIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        // Schedule the alarm
        val tenMinutesInMilliseconds = 600000L
        val preTriggerTime =
            System.currentTimeMillis() + (milliSeconds - tenMinutesInMilliseconds)
        val triggerTime = System.currentTimeMillis() + milliSeconds
        
        if (activityMonitor == 1) {
            
            val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putInt("flutter.activity_condition_type", activityConditionType)
            editor.putInt("flutter.activity_interval", activityInterval)
            editor.apply()
            
            val alarmClockInfo = AlarmManager.AlarmClockInfo(preTriggerTime, pendingIntent)
            alarmManager.setAlarmClock(
                alarmClockInfo,
                pendingActivityCheckIntent
            )
        } else {
            val sharedPreferences =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putLong("flutter.is_screen_off", 0L)
            editor.putLong("flutter.is_screen_on", 0L)
            editor.putInt("flutter.activity_condition_type", 0)
            editor.putInt("flutter.activity_interval", 30)
            editor.apply()
        }
        
        if (locationMonitor > 0) {
            val sharedPreferences =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString("flutter.set_location", setLocation)
            editor.putInt("flutter.location_condition_type", locationMonitor)
            editor.apply()
            editor.putInt("flutter.is_location_on", 1)
            editor.apply()
            val locationAlarmIntent = Intent(context, LocationFetcherService::class.java)
            val pendingLocationAlarmIntent = PendingIntent.getService(
                context,
                5,
                locationAlarmIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            
            val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTime - 10000, pendingLocationAlarmIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingLocationAlarmIntent)
        } else if (isWeather == 1) {
            val sharedPreferences =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putString("flutter.weatherTypes", getWeatherConditions(weatherTypes))
            editor.putInt("flutter.weatherConditionType", weatherConditionType)
            editor.apply()
            val weatherAlarmIntent = Intent(context, WeatherFetcherService::class.java)
            val pendingWeatherAlarmIntent = PendingIntent.getService(
                context,
                6,
                weatherAlarmIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            
            val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTime - 10000, pendingWeatherAlarmIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingWeatherAlarmIntent)
        } else {
            
            val clockInfo = AlarmManager.AlarmClockInfo(triggerTime, pendingIntent)
            alarmManager.setAlarmClock(clockInfo, pendingIntent)
        }
    }



    private fun createNotificationChannel(context: Context) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                TimerService.TIMER_CHANNEL_ID,
                "Timer Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }


    private fun showTimerNotification(milliseconds: Long, timerName: String, context: Context) {
        var notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val deleteIntent = Intent(context, TimerNotification::class.java)
        deleteIntent.action = "com.ccextractor.ultimate_alarm_clock.STOP_TIMERNOTIF"
        val deletePendingIntent = PendingIntent.getBroadcast(
            context, 5, deleteIntent,
            PendingIntent.FLAG_IMMUTABLE
        )
        val notification = NotificationCompat.Builder(context, TimerService.TIMER_CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentText("$timerName")
            .setContentText(formatDuration(milliseconds))
            .setOnlyAlertOnce(true)
            .setDeleteIntent(deletePendingIntent)
            .build()
        notificationManager.notify(1, notification)
    }

    private fun getWeatherConditions(weatherTypes: String): String {
        return weatherTypes
    }

    private fun formatDuration(milliseconds: Long): String {
        val seconds = (milliseconds / 1000) % 60
        val minutes = (milliseconds / (1000 * 60)) % 60
        val hours = (milliseconds / (1000 * 60 * 60)) % 24

        return if (hours > 0) {
            String.format("%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format("%02d:%02d", minutes, seconds)
        }
    }
}