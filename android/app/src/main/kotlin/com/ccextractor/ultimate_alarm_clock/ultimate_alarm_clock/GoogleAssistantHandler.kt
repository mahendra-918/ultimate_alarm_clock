package com.ccextractor.ultimate_alarm_clock

import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

/**
 * Handler for Google Assistant commands for the Ultimate Alarm Clock app.
 * This class processes intents from Google Assistant and communicates with the Flutter app
 * through the MethodChannel.
 */
class GoogleAssistantHandler {
    companion object {
        private const val TAG = "GoogleAssistantHandler"
        
        /**
         * Process an intent from Google Assistant
         * @param intent The intent received from Google Assistant
         * @param methodChannel The method channel to communicate with Flutter
         * @return true if the intent was handled, false otherwise
         */
        fun handleIntent(intent: Intent, methodChannel: MethodChannel): Boolean {
            val action = intent.action
            val data = intent.data
            
            if (action != Intent.ACTION_VIEW || data == null) {
                return false
            }
            
            Log.d(TAG, "Received intent: $action with data: $data")
            
            return when (data.host) {
                "create_alarm" -> handleCreateAlarm(data, methodChannel)
                "cancel_alarm" -> handleCancelAlarm(data, methodChannel)
                "enable_alarm" -> handleEnableAlarm(data, methodChannel)
                "disable_alarm" -> handleDisableAlarm(data, methodChannel)
                else -> false
            }
        }
        
        /**
         * Handle create alarm intent
         * @param data The URI data from the intent
         * @param methodChannel The method channel to communicate with Flutter
         * @return true if the intent was handled, false otherwise
         */
        private fun handleCreateAlarm(data: Uri, methodChannel: MethodChannel): Boolean {
            try {
                val timeParam = data.getQueryParameter("time") ?: return false
                val labelParam = data.getQueryParameter("label") ?: ""
                val recurrenceParam = data.getQueryParameter("recurrence") ?: ""
                
                Log.d(TAG, "Creating alarm with time: $timeParam, label: $labelParam, recurrence: $recurrenceParam")
                
                // Convert the time string to a format that Flutter can understand
                val time = parseTimeParameter(timeParam)
                
                // Convert recurrence to days array
                val days = parseRecurrenceParameter(recurrenceParam)
                
                // Send the command to Flutter
                val params = HashMap<String, Any>()
                params["command"] = "create_alarm"
                params["time"] = time
                params["label"] = labelParam
                params["days"] = days
                
                methodChannel.invokeMethod("handleGoogleAssistant", params)
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Error handling create alarm intent", e)
                return false
            }
        }
        
        /**
         * Handle cancel alarm intent
         * @param data The URI data from the intent
         * @param methodChannel The method channel to communicate with Flutter
         * @return true if the intent was handled, false otherwise
         */
        private fun handleCancelAlarm(data: Uri, methodChannel: MethodChannel): Boolean {
            try {
                val labelParam = data.getQueryParameter("label") ?: return false
                
                Log.d(TAG, "Canceling alarm with label: $labelParam")
                
                // Send the command to Flutter
                val params = HashMap<String, Any>()
                params["command"] = "cancel_alarm"
                params["label"] = labelParam
                
                methodChannel.invokeMethod("handleGoogleAssistant", params)
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Error handling cancel alarm intent", e)
                return false
            }
        }
        
        /**
         * Handle enable alarm intent
         * @param data The URI data from the intent
         * @param methodChannel The method channel to communicate with Flutter
         * @return true if the intent was handled, false otherwise
         */
        private fun handleEnableAlarm(data: Uri, methodChannel: MethodChannel): Boolean {
            try {
                val labelParam = data.getQueryParameter("label") ?: return false
                
                Log.d(TAG, "Enabling alarm with label: $labelParam")
                
                // Send the command to Flutter
                val params = HashMap<String, Any>()
                params["command"] = "enable_alarm"
                params["label"] = labelParam
                
                methodChannel.invokeMethod("handleGoogleAssistant", params)
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Error handling enable alarm intent", e)
                return false
            }
        }
        
        /**
         * Handle disable alarm intent
         * @param data The URI data from the intent
         * @param methodChannel The method channel to communicate with Flutter
         * @return true if the intent was handled, false otherwise
         */
        private fun handleDisableAlarm(data: Uri, methodChannel: MethodChannel): Boolean {
            try {
                val labelParam = data.getQueryParameter("label") ?: return false
                
                Log.d(TAG, "Disabling alarm with label: $labelParam")
                
                // Send the command to Flutter
                val params = HashMap<String, Any>()
                params["command"] = "disable_alarm"
                params["label"] = labelParam
                
                methodChannel.invokeMethod("handleGoogleAssistant", params)
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Error handling disable alarm intent", e)
                return false
            }
        }
        
        /**
         * Parse time parameter from Google Assistant
         * @param timeParam The time parameter from Google Assistant
         * @return The time in HH:mm format
         */
        private fun parseTimeParameter(timeParam: String): String {
            // Google Assistant may send time in different formats
            // We'll try to handle common formats and convert to HH:mm
            try {
                // If it's already in HH:mm format
                if (timeParam.matches(Regex("\\d{1,2}:\\d{2}"))) {
                    return timeParam
                }
                
                // If it's a timestamp
                if (timeParam.toLongOrNull() != null) {
                    val date = Date(timeParam.toLong())
                    val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
                    return formatter.format(date)
                }
                
                // Default fallback
                return timeParam
            } catch (e: Exception) {
                Log.e(TAG, "Error parsing time parameter", e)
                return timeParam
            }
        }
        
        /**
         * Parse recurrence parameter from Google Assistant
         * @param recurrenceParam The recurrence parameter from Google Assistant
         * @return Array of 7 booleans representing days of week (Monday to Sunday)
         */
        private fun parseRecurrenceParameter(recurrenceParam: String): BooleanArray {
            val days = BooleanArray(7) { false }
            
            try {
                when (recurrenceParam.lowercase(Locale.getDefault())) {
                    "daily" -> {
                        for (i in 0..6) {
                            days[i] = true
                        }
                    }
                    "weekdays" -> {
                        for (i in 0..4) {
                            days[i] = true
                        }
                    }
                    "weekends" -> {
                        days[5] = true
                        days[6] = true
                    }
                    "monday" -> days[0] = true
                    "tuesday" -> days[1] = true
                    "wednesday" -> days[2] = true
                    "thursday" -> days[3] = true
                    "friday" -> days[4] = true
                    "saturday" -> days[5] = true
                    "sunday" -> days[6] = true
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error parsing recurrence parameter", e)
            }
            
            return days
        }
    }
}
