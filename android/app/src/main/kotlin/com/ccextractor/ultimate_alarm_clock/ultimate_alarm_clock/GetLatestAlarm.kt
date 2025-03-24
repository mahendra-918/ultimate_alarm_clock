package com.ccextractor.ultimate_alarm_clock

import android.annotation.SuppressLint
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.location.LocationManager
import android.util.Log
import java.text.SimpleDateFormat
import java.time.Duration
import java.time.LocalTime
import java.util.*
import java.util.concurrent.TimeUnit

fun getLatestAlarm(db: SQLiteDatabase, wantNextAlarm: Boolean, profile: String,context: Context): Map<String, *>? {
    val now = Calendar.getInstance()
    var nowInMinutes = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
    var nowInSeconds = nowInMinutes * 60 + now.get(Calendar.SECOND)

    if (wantNextAlarm) {
        nowInMinutes++
    }
    val currentDay = Calendar.getInstance().get(Calendar.DAY_OF_WEEK) - 1
    val currentTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
    Log.d("d", "cd ${currentDay}")

    // Initialize DatabaseHelper
    val logdbHelper = LogDatabaseHelper(context)

    val cursor = db.rawQuery(
        """
        SELECT * FROM alarms
        WHERE isEnabled = 1 
        AND (profile = ? OR ringOn = 1)
        """, arrayOf(profile)
    )
    var selectedAlarm = null
    Log.d("Alarm", cursor.count.toString())

    return if (cursor.count > 0) {
        // Parse the cursor into an AlarmModel object
        cursor.moveToFirst()
        var alarm = AlarmModel.fromCursor(cursor)
        var intervaltoAlarm = Long.MAX_VALUE
        var setAlarm: AlarmModel? = null
        do {
            alarm = AlarmModel.fromCursor(cursor)
            if (alarm.ringOn == 0) {

                var dayfromToday = 0
                var timeDif = getTimeDifferenceInMillis(alarm.alarmTime)
                Log.d("d", "timeDiff ${timeDif}")

                if ((alarm.days[currentDay] == '1' || alarm.days == "0000000") && timeDif > -1L) {
                    if (timeDif < intervaltoAlarm) {
                        intervaltoAlarm = timeDif
                        setAlarm = alarm
                    }
                } else {
                    dayfromToday = getDaysUntilNextAlarm(alarm.days, currentDay)
                    if (dayfromToday == 0) {

                        if (alarm.days == "0000000") {

                            var timeDif =
                                getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight()
                            if (timeDif < intervaltoAlarm && timeDif > -1L) {
                                intervaltoAlarm = timeDif
                                setAlarm = alarm
                            }
                        } else {

                            var timeDif =
                                getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight() + 86400000 * 6
                            if (timeDif < intervaltoAlarm && timeDif > -1L) {
                                intervaltoAlarm = timeDif
                                setAlarm = alarm
                            }
                        }
                    } else if (dayfromToday == 1) {
                        var timeDif =
                            getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight()
                        Log.d("d", "timeDiff ${timeDif}")

                        if (timeDif < intervaltoAlarm && timeDif > -1L) {
                            intervaltoAlarm = timeDif
                            setAlarm = alarm
                        }
                    } else {
                        var timeDif =
                            getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight() + 86400000 * (dayfromToday - 1)
                        if (timeDif < intervaltoAlarm && timeDif > -1L) {
                            intervaltoAlarm = timeDif
                            setAlarm = alarm
                        }
                    }

                }
            } else {
                val dayfromToday = getDaysFromCurrentDate(alarm.alarmDate)
                if (dayfromToday == 0L) {
                    var timeDif = getTimeDifferenceInMillis(alarm.alarmTime)
                    if (alarm.days[currentDay] == '1' && timeDif > -1L) {
                        if (timeDif < intervaltoAlarm) {
                            intervaltoAlarm = timeDif
                            setAlarm = alarm
                        }
                    }
                } else if (dayfromToday == 1L) {
                    var timeDif =
                        getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight()
                    if (timeDif < intervaltoAlarm) {
                        intervaltoAlarm = timeDif
                        setAlarm = alarm
                    }
                } else {

                    var timeDif =
                        getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight() + 86400000 * (dayfromToday - 1)
                    if (timeDif < intervaltoAlarm && timeDif > -1L) {
                        intervaltoAlarm = timeDif
                        setAlarm = alarm
                    }
                }

            }

        } while (cursor.moveToNext())
        cursor.close()

        if (setAlarm != null) {
            Log.d("Alarm", intervaltoAlarm.toString())

            // Add the latest alarm details to the LOG table
            val alarmType = when {
                setAlarm.activityMonitor == 1 -> "Screen Activity Based"
                setAlarm.isLocationEnabled == 1 -> "Location Based"
                setAlarm.isWeatherEnabled == 1 -> "Weather Based"
                else -> "Normal"
            }
            
            val weatherTypesString = if (setAlarm.isWeatherEnabled == 1) {
                val weatherMap = mapOf(
                    0 to "sunny",
                    1 to "cloudy",
                    2 to "rainy",
                    3 to "windy",
                    4 to "stormy"
                )

                val indices = setAlarm.weatherTypes
                    .removeSurrounding("[", "]")
                    .split(",")
                    .map { it.trim().toInt() }

                val conditions = indices.mapNotNull { weatherMap[it] }
                if (conditions.isNotEmpty()) {
                    "Weather Types: ${conditions.joinToString(", ")}"
                } else {
                    "Weather Types: None"
                }
            } else ""

            val repeatDays = if (setAlarm.days.isNotEmpty()) {
                val dayNames = listOf("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
                val selectedDays = setAlarm.days.mapIndexedNotNull { index, char -> 
                    if (char == '1') dayNames[index] else null 
                }
                if (selectedDays.isNotEmpty()) {
                    "Repeat Days: ${selectedDays.joinToString(", ")}"
                } else {
                    "Repeat Days: None"
                }
            } else "Repeat Days: None"
            
            val logDetails = """
                Alarm Scheduled for ${setAlarm.alarmTime}
                Type: $alarmType
                Label: ${setAlarm.label}
                $repeatDays
                ${if (setAlarm.isOneTime == 1) "One-time Alarm" else ""}
                ${if (setAlarm.activityMonitor == 1) "Activity Monitor: Enabled (${setAlarm.activityInterval/60000} minutes)" else ""}
                ${if (setAlarm.isLocationEnabled == 1) "Location: ${setAlarm.location}" else ""}
                $weatherTypesString
                ${if (setAlarm.isMathsEnabled == 1) "Math Challenge: Enabled (${setAlarm.numMathsQuestions} questions, Difficulty: ${setAlarm.mathsDifficulty})" else ""}
                ${if (setAlarm.isShakeEnabled == 1) "Shake Challenge: Enabled (${setAlarm.shakeTimes} times)" else ""}
                ${if (setAlarm.isQrEnabled == 1) "QR Challenge: Enabled" else ""}
                ${if (setAlarm.isPedometerEnabled == 1) "Pedometer Challenge: Enabled (${setAlarm.numberOfSteps} steps)" else ""}
                ${if (setAlarm.isGuardian == 1) "Guardian Mode: Enabled (${setAlarm.guardianTimer} minutes)" else ""}
                ${if (setAlarm.isCall == 1) "Call Mode: Enabled" else ""}
                ${if (setAlarm.isSharedAlarmEnabled == 1) "Shared Alarm: Enabled" else ""}
                ${if (setAlarm.showMotivationalQuote == 1) "Motivational Quote: Enabled" else ""}
                ${if (setAlarm.deleteAfterGoesOff == 1) "Delete After Trigger: Enabled" else ""}
                Volume: ${setAlarm.volMin} to ${setAlarm.volMax}
                Gradient: ${setAlarm.gradient} seconds
                Snooze Duration: ${setAlarm.snoozeDuration} minutes
                Ringtone: ${setAlarm.ringtoneName}
                ${if (setAlarm.note.isNotEmpty()) "Note: ${setAlarm.note}" else ""}
            """.trimIndent()
            logdbHelper.insertLog(logDetails)

            // Return the latest alarm details
            val a = mapOf(
                "interval" to intervaltoAlarm,
                "isActivity" to setAlarm.activityMonitor,
                "isLocation" to setAlarm.isLocationEnabled,
                "location" to setAlarm.location,
                "isWeather" to setAlarm.isWeatherEnabled,
                "weatherTypes" to setAlarm.weatherTypes,
                "alarmID" to setAlarm.alarmId,
                "isInLocation" to isInTargetLocation(context, setAlarm.location),
                "shouldCancel" to (setAlarm.isLocationEnabled == 1 && isInTargetLocation(context, setAlarm.location))
            )
            Log.d("s", "sdsd ${a}")
            return a
        }
        null
    } else {
        null
    }
}

fun getTimeDifferenceInMillis(timeString: String): Long {
    // Define the time format
    val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())

    // Get the current time
    val currentTime = Calendar.getInstance()

    // Parse the received time string into a Date object
    val receivedTime: Date? = timeFormat.parse(timeString)

    // Create a Calendar object for the received time
    val receivedCalendar = Calendar.getInstance().apply {
        time = receivedTime!!
        set(Calendar.YEAR, currentTime.get(Calendar.YEAR))  // Set the same day as today
        set(Calendar.MONTH, currentTime.get(Calendar.MONTH))
        set(Calendar.DAY_OF_MONTH, currentTime.get(Calendar.DAY_OF_MONTH))
    }

    // Compare the received time with the current time
    return if (receivedCalendar.after(currentTime)) {
        receivedCalendar.timeInMillis - currentTime.timeInMillis
    } else {
        -1  // Return -1 if the received time is less than or equal to current time
    }
}


fun getDaysUntilNextAlarm(alarmDays: String, currentDay: Int): Int {
    // Validate that the alarmDays string has exactly 7 characters
    if (alarmDays.length != 7) {
        throw IllegalArgumentException("The alarmDays string must have exactly 7 characters")
    }

    // Convert the string into a list of integers (0 or 1) representing the alarm status for each day
    val alarms = alarmDays.map { it.toString().toInt() }

    // Loop through the days starting from the current day to find the next "on" (1)
    for (i in 0 until 7) {
        val dayToCheck = (currentDay + i) % 7  // Wrap around the week using modulo
        if (alarms[dayToCheck] == 1) {
            return i  // Return the number of days until the next alarm is on
        }
    }

    // If no alarms are on in the week, return -1
    return 0
}

fun getTimeDifferenceFromMidnight(timeString: String): Long {
    // Define the time format
    val timeFormat = SimpleDateFormat("HH:mm", Locale.getDefault())

    // Parse the received time string into a Date object
    val receivedTime: Date? = timeFormat.parse(timeString)

    // Get the reference time for midnight ("00:00")
    val midnight = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }

    // Create a Calendar object for the received time
    val receivedCalendar = Calendar.getInstance().apply {
        time = receivedTime!!
        set(Calendar.YEAR, midnight.get(Calendar.YEAR))  // Keep the same day (midnight)
        set(Calendar.MONTH, midnight.get(Calendar.MONTH))
        set(Calendar.DAY_OF_MONTH, midnight.get(Calendar.DAY_OF_MONTH))
    }

    // Return the difference between the received time and midnight in milliseconds
    return receivedCalendar.timeInMillis - midnight.timeInMillis
}

fun getMillisecondsUntilMidnight(): Long {
    // Get the current time
    val currentTime = Calendar.getInstance()

    // Create a Calendar object for the next midnight
    val nextMidnight = Calendar.getInstance().apply {
        add(Calendar.DAY_OF_MONTH, 1)  // Move to the next day
        set(Calendar.HOUR_OF_DAY, 0)   // Set the time to midnight
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }

    // Calculate the difference in milliseconds
    return nextMidnight.timeInMillis - currentTime.timeInMillis
}

fun getDaysFromCurrentDate(dateString: String): Long {
    // Define the date format
    val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())

    // Parse the received date string into a Date object
    val receivedDate: Date? = dateFormat.parse(dateString)

    // Get the current date
    val currentDate = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }.time

    // Ensure received date is not null
    if (receivedDate == null) {
        throw IllegalArgumentException("Invalid date format")
    }

    // Calculate the difference in milliseconds between the two dates
    val differenceInMillis = receivedDate.time - currentDate.time

    // If the received date is in the past, return -1
    if (differenceInMillis < 0) {
        return -1
    }

    // Convert the difference in milliseconds to days
    return TimeUnit.MILLISECONDS.toDays(differenceInMillis)
}


data class AlarmModel(
    val id: Int,
    val minutesSinceMidnight: Int,
    val alarmTime: String,
    val days: String,
    val isOneTime: Int,
    val activityMonitor: Int,
    val isWeatherEnabled: Int,
    val weatherTypes: String,
    val isLocationEnabled: Int,
    val location: String,
    val alarmDate: String,
    val alarmId: String,
    val ringOn: Int,
    val isMathsEnabled: Int = 0,
    val numMathsQuestions: Int = 0,
    val mathsDifficulty: Int = 0,
    val isShakeEnabled: Int = 0,
    val shakeTimes: Int = 0,
    val isQrEnabled: Int = 0,
    val isPedometerEnabled: Int = 0,
    val numberOfSteps: Int = 0,
    val isGuardian: Int = 0,
    val guardianTimer: Int = 0,
    val guardian: String = "",
    val isCall: Int = 0,
    val isSharedAlarmEnabled: Int = 0,
    val showMotivationalQuote: Int = 0,
    val deleteAfterGoesOff: Int = 0,
    val volMin: Double = 0.0,
    val volMax: Double = 0.0,
    val gradient: Int = 0,
    val snoozeDuration: Int = 0,
    val ringtoneName: String = "",
    val note: String = "",
    val label: String = "",
    val activityInterval: Int = 0
) {
    companion object {
        @SuppressLint("Range")
        fun fromCursor(cursor: Cursor): AlarmModel {
            val id = cursor.getInt(cursor.getColumnIndex("id"))
            val minutesSinceMidnight = cursor.getInt(cursor.getColumnIndex("minutesSinceMidnight"))
            val alarmTime = cursor.getString(cursor.getColumnIndex("alarmTime"))
            val days = cursor.getString(cursor.getColumnIndex("days"))
            val isOneTime = cursor.getInt(cursor.getColumnIndex("isOneTime"))
            val activityMonitor = cursor.getInt(cursor.getColumnIndex("activityMonitor"))
            val isWeatherEnabled = cursor.getInt(cursor.getColumnIndex("isWeatherEnabled"))
            val weatherTypes = cursor.getString(cursor.getColumnIndex("weatherTypes"))
            val isLocationEnabled = cursor.getInt(cursor.getColumnIndex("isLocationEnabled"))
            val location = cursor.getString(cursor.getColumnIndex("location"))
            val alarmDate = cursor.getString(cursor.getColumnIndex("alarmDate"))
            val alarmId = cursor.getString(cursor.getColumnIndex("alarmID"))
            val ringOn = cursor.getInt(cursor.getColumnIndex("ringOn"))
            val isMathsEnabled = cursor.getInt(cursor.getColumnIndex("isMathsEnabled"))
            val numMathsQuestions = cursor.getInt(cursor.getColumnIndex("numMathsQuestions"))
            val mathsDifficulty = cursor.getInt(cursor.getColumnIndex("mathsDifficulty"))
            val isShakeEnabled = cursor.getInt(cursor.getColumnIndex("isShakeEnabled"))
            val shakeTimes = cursor.getInt(cursor.getColumnIndex("shakeTimes"))
            val isQrEnabled = cursor.getInt(cursor.getColumnIndex("isQrEnabled"))
            val isPedometerEnabled = cursor.getInt(cursor.getColumnIndex("isPedometerEnabled"))
            val numberOfSteps = cursor.getInt(cursor.getColumnIndex("numberOfSteps"))
            val isGuardian = cursor.getInt(cursor.getColumnIndex("isGuardian"))
            val guardianTimer = cursor.getInt(cursor.getColumnIndex("guardianTimer"))
            val guardian = cursor.getString(cursor.getColumnIndex("guardian"))
            val isCall = cursor.getInt(cursor.getColumnIndex("isCall"))
            val isSharedAlarmEnabled = cursor.getInt(cursor.getColumnIndex("isSharedAlarmEnabled"))
            val showMotivationalQuote = cursor.getInt(cursor.getColumnIndex("showMotivationalQuote"))
            val deleteAfterGoesOff = cursor.getInt(cursor.getColumnIndex("deleteAfterGoesOff"))
            val volMin = cursor.getDouble(cursor.getColumnIndex("volMin"))
            val volMax = cursor.getDouble(cursor.getColumnIndex("volMax"))
            val gradient = cursor.getInt(cursor.getColumnIndex("gradient"))
            val snoozeDuration = cursor.getInt(cursor.getColumnIndex("snoozeDuration"))
            val ringtoneName = cursor.getString(cursor.getColumnIndex("ringtoneName"))
            val note = cursor.getString(cursor.getColumnIndex("note"))
            val label = cursor.getString(cursor.getColumnIndex("label"))
            val activityInterval = cursor.getInt(cursor.getColumnIndex("activityInterval"))
            
            return AlarmModel(
                id,
                minutesSinceMidnight,
                alarmTime,
                days,
                isOneTime,
                activityMonitor,
                isWeatherEnabled,
                weatherTypes,
                isLocationEnabled,
                location,
                alarmDate,
                alarmId,
                ringOn,
                isMathsEnabled,
                numMathsQuestions,
                mathsDifficulty,
                isShakeEnabled,
                shakeTimes,
                isQrEnabled,
                isPedometerEnabled,
                numberOfSteps,
                isGuardian,
                guardianTimer,
                guardian,
                isCall,
                isSharedAlarmEnabled,
                showMotivationalQuote,
                deleteAfterGoesOff,
                volMin,
                volMax,
                gradient,
                snoozeDuration,
                ringtoneName,
                note,
                label,
                activityInterval
            )
        }
    }
}

private fun isInTargetLocation(context: Context, targetLocation: String): Boolean {
    // Get the current location
    val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    val lastKnownLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
    
    if (lastKnownLocation == null) {
        Log.d("LocationDebug", "No last known location available")
        return false
    }

    // Parse the target location string (assuming format: "latitude,longitude,radius")
    val parts = targetLocation.split(",")
    if (parts.size != 3) {
        Log.d("LocationDebug", "Invalid location format: $targetLocation")
        return false
    }

    val targetLat = parts[0].toDoubleOrNull() ?: run {
        Log.d("LocationDebug", "Invalid latitude: ${parts[0]}")
        return false
    }
    val targetLng = parts[1].toDoubleOrNull() ?: run {
        Log.d("LocationDebug", "Invalid longitude: ${parts[1]}")
        return false
    }
    val radius = parts[2].toDoubleOrNull() ?: run {
        Log.d("LocationDebug", "Invalid radius: ${parts[2]}")
        return false
    }

    // Log the coordinates
    Log.d("LocationDebug", "Current Location: ${lastKnownLocation.latitude}, ${lastKnownLocation.longitude}")
    Log.d("LocationDebug", "Target Location: $targetLat, $targetLng")
    Log.d("LocationDebug", "Target Radius: $radius meters")

    // Calculate distance between current and target location
    val results = FloatArray(1)
    android.location.Location.distanceBetween(
        lastKnownLocation.latitude,
        lastKnownLocation.longitude,
        targetLat,
        targetLng,
        results
    )

    val distanceInMeters = results[0]
    Log.d("LocationDebug", "Distance to target: $distanceInMeters meters")
    Log.d("LocationDebug", "Is within 500m: ${distanceInMeters <= 500}")

    return distanceInMeters <= 500 // Return true if within 500 meters
}