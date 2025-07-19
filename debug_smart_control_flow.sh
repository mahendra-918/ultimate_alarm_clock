#!/bin/bash

echo "=== Smart Control Alarm Flow Debug ==="
echo "This will trace the complete flow of smart control alarms"
echo ""

echo "1. What type of smart control alarm are you testing?"
echo "   1) Weather condition"
echo "   2) Location condition"
echo "   3) Activity condition"
read -p "Enter choice (1-3): " choice

case $choice in
    1) 
        SERVICE_NAME="WeatherFetcherService"
        CONDITION_TYPE="weather"
        ;;
    2)
        SERVICE_NAME="LocationFetcherService"
        CONDITION_TYPE="location"
        ;;
    3)
        SERVICE_NAME="ScreenMonitorService"
        CONDITION_TYPE="activity"
        ;;
    *)
        echo "Invalid choice, defaulting to weather"
        SERVICE_NAME="WeatherFetcherService"
        CONDITION_TYPE="weather"
        ;;
esac

echo ""
echo "2. Set up your $CONDITION_TYPE alarm and come back here"
read -p "Press Enter after setting the alarm..."

echo ""
echo "3. Clearing logs and monitoring complete flow..."
adb logcat -c

echo ""
echo "4. Monitoring $SERVICE_NAME and alarm flow:"
echo "   - AlarmReceiver triggering"
echo "   - Service startup"
echo "   - Service execution"
echo "   - Condition evaluation"
echo "   - Final decision"
echo ""

# Monitor comprehensive flow
adb logcat | grep -E "AlarmReceiver.*$CONDITION_TYPE|$SERVICE_NAME|SCHEDULED.*ALARM|CANCELLED.*ALARM|shouldRing|ringAlarm|cancelAlarm|WakeLock|foreground.*service" --line-buffered | while read line; do
    echo "[$(date '+%H:%M:%S')] $line"
done &

LOGCAT_PID=$!

echo "Expected flow:"
echo "1. AlarmReceiver should trigger and start $SERVICE_NAME"
echo "2. $SERVICE_NAME should start as foreground service"
echo "3. Service should evaluate $CONDITION_TYPE condition"
echo "4. Service should make decision: ringAlarm() or cancelAlarm()"
echo "5. Service should stopSelf() after completion"
echo ""
echo "Watch for any errors or unexpected cancellations!"
echo "Press Ctrl+C when done monitoring"

# Wait for Ctrl+C
trap "kill $LOGCAT_PID 2>/dev/null; echo ''; echo 'Flow analysis complete. Check for any unexpected cancellations or errors.'; exit" INT
wait