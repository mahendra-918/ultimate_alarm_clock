package com.ccextractor.ultimate_alarm_clock

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import android.app.AlarmManager
import android.app.PendingIntent
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreSettings
import com.google.firebase.firestore.QuerySnapshot
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.time.Duration
import java.time.LocalTime
import java.util.*
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.delay

// Firestore instance with offline persistence (initialized lazily)
private val firestoreInstance by lazy {
    val db = FirebaseFirestore.getInstance()
    val settings = FirebaseFirestoreSettings.Builder()
        .setPersistenceEnabled(true)
        .setCacheSizeBytes(FirebaseFirestoreSettings.CACHE_SIZE_UNLIMITED)
        .build()
    
    try {
        db.firestoreSettings = settings
    } catch (e: Exception) {
        Log.e("Firestore", "Failed to set Firestore settings: ${e.message}")
    }
    
    db
}

fun getLatestAlarm(db: SQLiteDatabase, wantNextAlarm: Boolean, profile: String, context: Context): Map<String, *>? {
    // Firestore is initialized lazily when needed
    
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

    // Get user ID from SharedPreferences for Firestore queries
    val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    val userId = sharedPreferences.getString("flutter.userId", null)

    // Get alarms from SQLite
    val cursor = db.rawQuery(
        """
        SELECT * FROM alarms
        WHERE isEnabled = 1 
        AND (profile = ? OR ringOn = 1)
        """, arrayOf(profile)
    )
    
    Log.d("Alarm", "SQLite alarms count: ${cursor.count}")

    // Process SQLite alarms
    var sqliteIntervalToAlarm = Long.MAX_VALUE
    var sqliteNearestAlarm: AlarmModel? = null
    
    if (cursor.count > 0) {
        cursor.moveToFirst()
        do {
            val alarm = AlarmModel.fromCursor(cursor)
            val intervalToThisAlarm = calculateIntervalToAlarm(alarm, currentDay)
            
            if (intervalToThisAlarm > -1L && intervalToThisAlarm < sqliteIntervalToAlarm) {
                sqliteIntervalToAlarm = intervalToThisAlarm
                sqliteNearestAlarm = alarm
            }
        } while (cursor.moveToNext())
        cursor.close()
    } else {
        cursor.close()
    }
    
    // Log the nearest SQLite alarm
    if (sqliteNearestAlarm != null) {
        Log.d("Alarm", "Nearest SQLite alarm is at ${sqliteNearestAlarm.alarmTime} in ${sqliteIntervalToAlarm} ms")
    } else {
        Log.d("Alarm", "No eligible SQLite alarms found")
    }
    
    // Get alarms from Firestore if user is logged in
    var firestoreIntervalToAlarm = Long.MAX_VALUE
    var firestoreNearestAlarm: AlarmModel? = null
    
    if (userId != null) {
        Log.d("FirestoreTest", "User is logged in with ID: $userId - attempting to fetch Firestore alarms")
        try {
            val firestoreAlarms = getFirestoreAlarms(userId, context)
            if (firestoreAlarms.isNotEmpty()) {
                Log.d("FirestoreTest", "Successfully retrieved ${firestoreAlarms.size} Firestore alarms")
                
                // Find the nearest Firestore alarm
                for (alarm in firestoreAlarms) {
                    val intervalToThisAlarm = calculateIntervalToAlarm(alarm, currentDay)
                    
                    if (intervalToThisAlarm > -1L && intervalToThisAlarm < firestoreIntervalToAlarm) {
                        firestoreIntervalToAlarm = intervalToThisAlarm
                        firestoreNearestAlarm = alarm
                    }
                }
                
                // Log the nearest Firestore alarm
                if (firestoreNearestAlarm != null) {
                    Log.d("Alarm", "Nearest Firestore alarm is at ${firestoreNearestAlarm.alarmTime} in ${firestoreIntervalToAlarm} ms")
                } else {
                    Log.d("Alarm", "No eligible Firestore alarms found")
                }
            }
        } catch (e: Exception) {
            Log.e("Alarm", "Error fetching Firestore alarms: ${e.message}")
            // Continue with SQLite alarms only if Firestore fails
        }
    }
    
    // Select the nearest alarm from both sources
    var finalIntervalToAlarm = Long.MAX_VALUE
    var finalAlarm: AlarmModel? = null
    
    if (sqliteNearestAlarm != null && firestoreNearestAlarm != null) {
        // Both sources have alarms, pick the nearest one
        if (sqliteIntervalToAlarm <= firestoreIntervalToAlarm) {
            finalIntervalToAlarm = sqliteIntervalToAlarm
            finalAlarm = sqliteNearestAlarm
            Log.d("Alarm", "Selected SQLite alarm as it's closer (${sqliteIntervalToAlarm} ms vs ${firestoreIntervalToAlarm} ms)")
        } else {
            finalIntervalToAlarm = firestoreIntervalToAlarm
            finalAlarm = firestoreNearestAlarm
            Log.d("FirestoreTest", "SELECTED FIRESTORE ALARM as it's closer (${firestoreIntervalToAlarm} ms vs ${sqliteIntervalToAlarm} ms)")
            Log.d("FirestoreTest", "Selected Firestore alarm details: time=${firestoreNearestAlarm.alarmTime}, id=${firestoreNearestAlarm.alarmId}")
        }
    } else if (sqliteNearestAlarm != null) {
        // Only SQLite has an alarm
        finalIntervalToAlarm = sqliteIntervalToAlarm
        finalAlarm = sqliteNearestAlarm
        Log.d("Alarm", "Selected SQLite alarm as no Firestore alarm is available")
    } else if (firestoreNearestAlarm != null) {
        // Only Firestore has an alarm
        finalIntervalToAlarm = firestoreIntervalToAlarm
        finalAlarm = firestoreNearestAlarm
        Log.d("FirestoreTest", "SELECTED FIRESTORE ALARM as no SQLite alarm is available")
        Log.d("FirestoreTest", "Selected Firestore alarm details: time=${firestoreNearestAlarm.alarmTime}, id=${firestoreNearestAlarm.alarmId}")
    } else {
        // No alarms from either source
        Log.d("Alarm", "No eligible alarms found from either source")
        return null
    }

    if (finalAlarm != null) {
        Log.d("Alarm", "Final alarm selected: ${finalAlarm.alarmTime} in ${finalIntervalToAlarm} ms")

        // Add the latest alarm details to the LOG table
        val logDetails = """
            Alarm Scheduled for ${finalAlarm.alarmTime}
        """.trimIndent()
        logdbHelper.insertLog(
            "Alarm Scheduled for ${finalAlarm.alarmTime}",
            LogDatabaseHelper.Status.SUCCESS,
            LogDatabaseHelper.LogType.DEV
        )

        // Return the latest alarm details
        val a = mapOf(
            "interval" to finalIntervalToAlarm,
            "isActivity" to finalAlarm.activityMonitor,
            "isLocation" to finalAlarm.isLocationEnabled,
            "location" to finalAlarm.location,
            "isWeather" to finalAlarm.isWeatherEnabled,
            "weatherTypes" to finalAlarm.weatherTypes,
            "alarmID" to finalAlarm.alarmId
        )
        Log.d("s", "sdsd ${a}")
        return a
    }
    
    return null
}

// Helper function to calculate interval to an alarm
private fun calculateIntervalToAlarm(alarm: AlarmModel, currentDay: Int): Long {
    if (alarm.ringOn == 0) {
        var dayfromToday = 0
        var timeDif = getTimeDifferenceInMillis(alarm.alarmTime)

        if ((alarm.days[currentDay] == '1' || alarm.days == "0000000") && timeDif > -1L) {
            return timeDif
                } else {
                    dayfromToday = getDaysUntilNextAlarm(alarm.days, currentDay)
                    if (dayfromToday == 0) {
                        if (alarm.days == "0000000") {
                            var timeDif =
                                getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight()
                    if (timeDif > -1L) {
                        return timeDif
                            }
                        } else {
                            var timeDif =
                                getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight() + 86400000 * 6
                    if (timeDif > -1L) {
                        return timeDif
                            }
                        }
                    } else if (dayfromToday == 1) {
                        var timeDif =
                            getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight()
                if (timeDif > -1L) {
                    return timeDif
                        }
                    } else {
                        var timeDif =
                            getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight() + 86400000 * (dayfromToday - 1)
                if (timeDif > -1L) {
                    return timeDif
                        }
                    }
                }
            } else {
                val dayfromToday = getDaysFromCurrentDate(alarm.alarmDate)
                if (dayfromToday == 0L) {
                    var timeDif = getTimeDifferenceInMillis(alarm.alarmTime)
                    if (alarm.days[currentDay] == '1' && timeDif > -1L) {
                return timeDif
                    }
                } else if (dayfromToday == 1L) {
                    var timeDif =
                        getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight()
            return timeDif
                } else {
                    var timeDif =
                        getTimeDifferenceFromMidnight(alarm.alarmTime) + getMillisecondsUntilMidnight() + 86400000 * (dayfromToday - 1)
            if (timeDif > -1L) {
                return timeDif
            }
        }
    }
    
    return -1L  // Alarm is not eligible or in the past
}

// Function to fetch alarms from Firestore
@SuppressLint("Range")
fun getFirestoreAlarms(userId: String, context: Context): List<AlarmModel> {
    val alarms = mutableListOf<AlarmModel>()
    
    Log.d("FirestoreTest", "Starting Firestore alarm fetch for user: $userId")
    try {
        // Use runBlocking to make synchronous Firestore calls
        runBlocking {
            // Use the lazy-initialized Firestore instance 
            
            // Query for alarms where user is the owner
            val ownerQuery = firestoreInstance.collection("sharedAlarms")
                .whereEqualTo("isEnabled", true)
                .whereEqualTo("ownerId", userId)
            
            // Query for alarms shared with this user
            val sharedQuery = firestoreInstance.collection("sharedAlarms")
                .whereEqualTo("isEnabled", true)
                .whereArrayContains("sharedUserIds", userId)
            
            // Execute both queries with retry mechanism
            Log.d("FirestoreTest", "Executing owner query: ${ownerQuery.whereEqualTo("ownerId", userId)}")
            val ownerResults = withRetry(3) {
                withContext(Dispatchers.IO) {
                    ownerQuery.get().await()
                }
            }
            Log.d("FirestoreTest", "Owner query results: ${ownerResults?.documents?.size ?: 0} documents")
            
            Log.d("FirestoreTest", "Executing shared query: ${sharedQuery.whereArrayContains("sharedUserIds", userId)}")
            val sharedResults = withRetry(3) {
                withContext(Dispatchers.IO) {
                    sharedQuery.get().await()
                }
            }
            Log.d("FirestoreTest", "Shared query results: ${sharedResults?.documents?.size ?: 0} documents")
            
            // Process owner alarms
            if (ownerResults != null) {
                for (document in ownerResults.documents) {
                    try {
                        val alarm = createAlarmModelFromFirestore(document.data, userId, context)
                        if (alarm != null) {
                            alarms.add(alarm)
                        }
                    } catch (e: Exception) {
                        Log.e("Alarm", "Error parsing owner alarm: ${e.message}")
                    }
                }
            }
            
            // Process shared alarms
            if (sharedResults != null) {
                for (document in sharedResults.documents) {
                    try {
                        // Verify the userId is actually in the sharedUserIds array
                        val sharedUserIds = document.data?.get("sharedUserIds") as? List<String>
                        if (sharedUserIds != null && sharedUserIds.contains(userId)) {
                            val alarm = createAlarmModelFromFirestore(document.data, userId, context)
                            if (alarm != null) {
                                alarms.add(alarm)
                                Log.d("Alarm", "Added shared alarm with ID ${alarm.alarmId} for user $userId")
                            }
                        } else {
                            Log.d("Alarm", "Skipped shared alarm as user $userId is not in sharedUserIds list")
                        }
                    } catch (e: Exception) {
                        Log.e("Alarm", "Error parsing shared alarm: ${e.message}")
                    }
                }
            }
        }
    } catch (e: Exception) {
        Log.e("FirestoreTest", "Error in Firestore query: ${e.message}", e)
    }
    
    Log.d("FirestoreTest", "Finished Firestore fetch with ${alarms.size} alarms")
    if (alarms.isNotEmpty()) {
        alarms.forEach { alarm ->
            Log.d("FirestoreTest", "Retrieved alarm: time=${alarm.alarmTime}, days=${alarm.days}, id=${alarm.alarmId}")
        }
    }
    
    return alarms
}

// Helper function to retry Firestore operations
private suspend fun <T> withRetry(maxRetries: Int, block: suspend () -> T): T? {
    var retries = 0
    var lastException: Exception? = null
    
    while (retries < maxRetries) {
        try {
            return block()
        } catch (e: Exception) {
            lastException = e
            Log.w("Firestore", "Operation failed, retry ${retries + 1}/$maxRetries: ${e.message}")
            retries++
            // Exponential backoff
            delay(1000L * (1 shl retries))
        }
    }
    
    Log.e("Firestore", "Operation failed after $maxRetries retries: ${lastException?.message}")
    return null
}

// Helper function to create an AlarmModel from Firestore data
@SuppressLint("Range")
fun createAlarmModelFromFirestore(data: Map<String, Any>?, userId: String, context: Context): AlarmModel? {
    if (data == null) return null
    
    try {
        val id = 0 // We'll use a dummy ID for Firestore alarms
        val minutesSinceMidnight = (data["minutesSinceMidnight"] as? Long)?.toInt() ?: 0
        
        // Get the original alarm time
        val originalAlarmTime = data["alarmTime"] as? String ?: ""
        
        // Check if there are offset details for this alarm
        var alarmTime = originalAlarmTime
        val offsetDetails = data["offsetDetails"] as? Map<String, Any>
        
        // If there are offset details and user ID is in the offset details, use the offsetted time
        if (offsetDetails != null && offsetDetails.containsKey(userId)) {
            try {
                val userOffset = offsetDetails[userId] as? Map<String, Any>
                if (userOffset != null) {
                    val offsettedTime = userOffset["offsettedTime"] as? String
                    if (offsettedTime != null) {
                        // Use the offsetted time instead of the original time
                        alarmTime = offsettedTime
                        Log.d("Alarm", "Using offsetted time $offsettedTime instead of $originalAlarmTime for user $userId")
                    }
                }
            } catch (e: Exception) {
                // Handle property access errors
                Log.e("Alarm", "Error accessing offset details: ${e.message}")
            }
        }
        
        // Convert days from array to string format with error handling
        val daysArray = try {
            data["days"] as? List<Boolean> ?: listOf()
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing days array: ${e.message}")
            listOf<Boolean>()
        }
        val days = daysArray.joinToString("") { if (it) "1" else "0" }
        
        // Safely access boolean properties with error handling
        val isOneTime = try {
            if (data["isOneTime"] as? Boolean == true) 1 else 0
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing isOneTime: ${e.message}")
            0
        }
        
        val activityMonitor = try {
            if (data["activityMonitor"] as? Boolean == true) 1 else 0
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing activityMonitor: ${e.message}")
            0
        }
        
        val isWeatherEnabled = try {
            if (data["isWeatherEnabled"] as? Boolean == true) 1 else 0
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing isWeatherEnabled: ${e.message}")
            0
        }
        
        val weatherTypes = try {
            data["weatherTypes"] as? String ?: "[]"
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing weatherTypes: ${e.message}")
            "[]"
        }
        
        val isLocationEnabled = try {
            if (data["isLocationEnabled"] as? Boolean == true) 1 else 0
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing isLocationEnabled: ${e.message}")
            0
        }
        
        val location = try {
            data["location"] as? String ?: ""
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing location: ${e.message}")
            ""
        }
        
        val alarmDate = try {
            data["alarmDate"] as? String ?: SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing alarmDate: ${e.message}")
            SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        }
        
        val alarmId = try {
            data["alarmID"] as? String ?: ""
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing alarmID: ${e.message}")
            ""
        }
        
        val ringOn = try {
            if (data["ringOn"] as? Boolean == true) 1 else 0
        } catch (e: Exception) {
            Log.e("Alarm", "Error accessing ringOn: ${e.message}")
            0
        }
        
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
            ringOn
        )
    } catch (e: Exception) {
        Log.e("Alarm", "Error creating alarm from Firestore: ${e.message}")
        return null
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

object AlarmUtils {
    @SuppressLint("ScheduleExactAlarm")
    fun scheduleAlarm(
        context: Context,
        milliSeconds: Long,
        activityMonitor: Int,
        locationMonitor: Int,
        setLocation: String,
        isWeather: Int,
        weatherTypes: String
    ) {
        val triggerTimeMs = System.currentTimeMillis() + milliSeconds
        val triggerDate = java.util.Date(triggerTimeMs)
        val sdf = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", java.util.Locale.getDefault())
        
        Log.d("AlarmUtils", "Scheduling alarm for ${milliSeconds}ms from now (${sdf.format(triggerDate)})")
        
        try {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, AlarmReceiver::class.java)
            
            // Add extras to the intent to help debugging
            intent.putExtra("alarm_trigger_time", triggerTimeMs)
            intent.putExtra("alarm_scheduled_at", System.currentTimeMillis())
            
            // Use a fixed request code (100) for the main alarm to ensure consistent replacement
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                100, // Fixed request code for better predictability
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

        // These variables are now declared lower down in the code

            // Reset screen activity tracking values to ensure a clean start
            val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val editor = sharedPreferences.edit()
            editor.putLong("flutter.is_screen_off", 0L)
            editor.putLong("flutter.is_screen_on", 0L)
            editor.apply() // Use a single apply() for better performance
            
            // Calculate pre-trigger time (10 minutes before main alarm)
            val preTriggerTime = triggerTimeMs - 600000L
            
            // Setup activity monitoring if enabled
            if (activityMonitor == 1) {
                Log.d("AlarmUtils", "Setting up activity monitoring to start at $preTriggerTime")
                // Reuse the previously declared intent
                activityCheckIntent.putExtra("triggerTime", preTriggerTime)
                // Create a new pending intent
                val monitorPendingIntent = PendingIntent.getService(
                    context, 
                    101, // Fixed request code
                    activityCheckIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )
                
                try {
                    // Start the service separately to ensure it's running
                    context.startService(activityCheckIntent)
                    Log.d("AlarmUtils", "Started ScreenMonitorService immediately")
                    
                    // Also set an alarm with the monitoring service
                    val monitorAlarmInfo = AlarmManager.AlarmClockInfo(preTriggerTime, pendingIntent)
                    alarmManager.setAlarmClock(monitorAlarmInfo, monitorPendingIntent)
                    Log.d("AlarmUtils", "Activity monitor alarm set for $preTriggerTime")
                } catch (e: Exception) {
                    Log.e("AlarmUtils", "Failed to start ScreenMonitorService: ${e.message}")
                }
            }
            
            // Handle location monitoring
            if (locationMonitor == 1) {
                Log.d("AlarmUtils", "Setting up location monitoring for: $setLocation")
                editor.putString("flutter.set_location", setLocation)
                editor.putInt("flutter.is_location_on", 1)
                editor.apply()
                
                val locationAlarmIntent = Intent(context, LocationFetcherService::class.java)
                val pendingLocationAlarmIntent = PendingIntent.getService(
                    context,
                    102, // Fixed request code
                    locationAlarmIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )
                
                // Set location alarm to trigger shortly before the main alarm
                val locationTriggerTime = triggerTimeMs - 10000 // 10 seconds before
                try {
                    val locationAlarmInfo = AlarmManager.AlarmClockInfo(locationTriggerTime, pendingIntent)
                    alarmManager.setAlarmClock(locationAlarmInfo, pendingLocationAlarmIntent)
                    Log.d("AlarmUtils", "Location alarm set for $locationTriggerTime")
                } catch (e: Exception) {
                    Log.e("AlarmUtils", "Failed to set location alarm: ${e.message}")
                }
            } 
            // Handle weather conditions
            else if (isWeather == 1) {
                val weatherConditions = getWeatherConditions(weatherTypes)
                Log.d("AlarmUtils", "Setting up weather monitoring with conditions: $weatherConditions")
                editor.putString("flutter.weatherTypes", weatherConditions)
                editor.apply()
                
                val weatherAlarmIntent = Intent(context, WeatherFetcherService::class.java)
                val pendingWeatherAlarmIntent = PendingIntent.getService(
                    context,
                    103, // Fixed request code
                    weatherAlarmIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )
                
                // Set weather alarm to trigger shortly before the main alarm
                val weatherTriggerTime = triggerTimeMs - 10000 // 10 seconds before
                try {
                    val weatherAlarmInfo = AlarmManager.AlarmClockInfo(weatherTriggerTime, pendingIntent)
                    alarmManager.setAlarmClock(weatherAlarmInfo, pendingWeatherAlarmIntent)
                    Log.d("AlarmUtils", "Weather alarm set for $weatherTriggerTime")
                } catch (e: Exception) {
                    Log.e("AlarmUtils", "Failed to set weather alarm: ${e.message}")
                }
            }
            
            // Set the main alarm with AlarmManager.setExactAndAllowWhileIdle for more reliability
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerTimeMs, pendingIntent)
                Log.d("AlarmUtils", "Alarm set with setExactAndAllowWhileIdle for ${sdf.format(triggerDate)}")
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMs, pendingIntent)
                Log.d("AlarmUtils", "Alarm set with setExact for ${sdf.format(triggerDate)}")
            }
            
            // Also set with AlarmClockInfo for user visibility and reliability
            val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTimeMs, pendingIntent)
            alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
            Log.d("AlarmUtils", "Alarm also set with setAlarmClock for backup")
            
            // Log the next scheduled alarm time
            val nextAlarmTime = alarmManager.nextAlarmClock?.triggerTime
            val nextAlarmDate = if (nextAlarmTime != null) sdf.format(Date(nextAlarmTime)) else "none"
            Log.d("AlarmUtils", "Next system alarm time: $nextAlarmDate")
            
        } catch (e: Exception) {
            Log.e("AlarmUtils", "Error scheduling alarm: ${e.message}", e)
        }
    }

    private fun getWeatherConditions(weatherTypes: String): String {
        // Return the weather types as is since it's already in the correct format
        return weatherTypes
    }
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
    val ringOn: Int
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
                ringOn
            )
        }
    }
}