#!/bin/bash

echo "=== Weather Background Service Test ==="
echo "This will test weather alarms when app is killed"
echo ""

# Function to wait for user input
wait_for_input() {
    read -p "Press Enter to continue..."
}

echo "1. First, let's clear the logs and monitor the service"
adb logcat -c
echo "   Logs cleared"

echo ""
echo "2. Now set up a weather alarm in the app (set for 2 minutes from now)"
echo "   - Open the app"
echo "   - Create a new alarm"
echo "   - Enable weather condition"
echo "   - Set it for 2 minutes from now"
wait_for_input

echo ""
echo "3. Kill the app completely"
adb shell am force-stop com.ccextractor.ultimate_alarm_clock
echo "   App killed"

echo ""
echo "4. Monitoring logs for weather service activity..."
echo "   Looking for service startup, location fetch, and API calls"
echo "   Wait for alarm time to trigger..."

# Monitor specific logs
adb logcat | grep -E "WeatherFetcherService|AlarmReceiver.*weather|Weather.*alarm" --line-buffered | while read line; do
    echo "[$(date '+%H:%M:%S')] $line"
done &

LOGCAT_PID=$!

echo ""
echo "5. Let it run for 3-4 minutes, then press Ctrl+C to stop monitoring"
echo "   Check if:"
echo "   - AlarmReceiver starts WeatherFetcherService"
echo "   - WeatherFetcherService starts foreground service"
echo "   - Location is fetched successfully"
echo "   - Weather API is called"
echo "   - Weather condition is evaluated"
echo "   - Alarm rings or is cancelled based on condition"

# Wait for Ctrl+C
trap "kill $LOGCAT_PID 2>/dev/null; echo ''; echo 'Test completed. Check the logs above.'; exit" INT
wait