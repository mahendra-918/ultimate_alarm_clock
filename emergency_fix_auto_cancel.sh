#!/bin/bash

echo "=== Emergency Fix: Auto-Cancel Debug ==="
echo ""

echo "1. What specific message do you see in the logs?"
echo "   Please share the exact log line that shows the cancellation"
echo ""

echo "2. Testing current alarm scheduling behavior..."
adb logcat -c

echo ""
echo "3. Set a simple alarm (no smart controls) first to test basic functionality"
read -p "Set a regular alarm for 2 minutes from now, then press Enter..."

echo ""
echo "4. Monitoring basic alarm flow..."
adb logcat | grep -E "AlarmReceiver|MainActivity.*schedule|SCHEDULED.*ALARM|CANCELLED.*ALARM" --line-buffered | while read line; do
    echo "[$(date '+%H:%M:%S')] $line"
done &

LOGCAT_PID=$!

echo "If basic alarms work, we'll test smart controls next."
echo "Press Ctrl+C when basic alarm triggers (or fails)"

trap "kill $LOGCAT_PID 2>/dev/null; echo ''; echo 'Basic test complete. Now test smart controls if basic alarms work.'; exit" INT
wait