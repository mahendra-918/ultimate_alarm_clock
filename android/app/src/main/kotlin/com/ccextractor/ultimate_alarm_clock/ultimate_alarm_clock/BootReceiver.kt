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
import com.ccextractor.ultimate_alarm_clock.ultimate_alarm_clock.AlarmUtils


class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {

        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
           val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val profile = sharedPreferences.getString("flutter.profile", "Default")

           // Use the determineNextAlarm function that handles both local and shared alarms
           val nextAlarm = determineNextAlarm(context, profile ?: "Default")
           
           if (nextAlarm != null) {
               val isSharedAlarm = nextAlarm["isSharedAlarm"] as? Boolean ?: false
               
               // Use the updated AlarmUtils that takes an isShared parameter
               AlarmUtils.scheduleAlarm(
                   context,
                   nextAlarm["interval"] as Long,
                   nextAlarm["isActivity"] as Int,
                   nextAlarm["isLocation"] as Int,
                   nextAlarm["location"] as String,
                   nextAlarm["isWeather"] as Int,
                   nextAlarm["weatherTypes"] as String,
                   isSharedAlarm
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

    // The scheduleAlarm method is no longer needed as we're using AlarmUtils.scheduleAlarm
    // This removes redundancy and potential conflicts

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