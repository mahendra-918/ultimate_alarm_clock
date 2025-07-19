#!/bin/bash

echo "=== Debug Automatic Alarm Cancellation ==="
echo "This will help identify why smart control alarms are being automatically cancelled"
echo ""

echo "1. Clearing logs..."
adb logcat -c

echo ""
echo "2. Set up a smart control alarm (weather, location, or activity)"
echo "   - Choose any smart control condition"
echo "   - Set it for a few minutes from now"
echo "   - Come back here after setting the alarm"
read -p "Press Enter after setting the alarm..."

echo ""
echo "3. Monitoring for automatic cancellation..."
echo "   Looking for cancellation logs and service behavior"
echo ""

# Monitor for cancellation-related logs
adb logcat | grep -E "CANCELLED.*ALARM|cancel.*alarm|alarm.*cancel|stopSelf|WeatherFetcherService.*cancel|LocationFetcherService.*cancel|ringAlarm.*Failed|Failed.*start.*service|ERROR.*scheduling" --line-buffered | while read line; do
    echo "[$(date '+%H:%M:%S')] $line"
done &

LOGCAT_PID=$!

echo "Key things to watch for:"
echo "- 'CANCELLED ... ALARM' messages (unexpected cancellation)"
echo "- 'Failed to start ...Service' messages (service startup failures)"
echo "- 'ERROR scheduling' messages (scheduling failures)"
echo "- 'stopSelf' messages (premature service termination)"
echo ""
echo "Let it run until the alarm time passes, then press Ctrl+C"
echo ""

# Wait for Ctrl+C
trap "kill $LOGCAT_PID 2>/dev/null; echo ''; echo 'Debug complete. Review the logs above for cancellation causes.'; exit" INT
wait