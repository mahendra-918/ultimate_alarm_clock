#!/bin/bash

echo "=== Weather Alarm Debug Script ==="
echo "This script will help debug weather alarm issues"
echo ""

# Check if device is connected
echo "1. Checking device connection..."
adb devices

echo ""
echo "2. Checking weather alarm logs..."
adb logcat -d | grep -i "weather\|Weather" | tail -20

echo ""
echo "3. Checking alarm receiver logs..."
adb logcat -d | grep -i "AlarmReceiver" | tail -10

echo ""
echo "4. Checking if weather service is running..."
adb shell "ps | grep -i weather"

echo ""
echo "5. Checking recent alarm logs from database..."
adb logcat -d | grep -i "alarm.*weather\|weather.*alarm" | tail -15

echo ""
echo "6. Checking foreground service logs..."
adb logcat -d | grep -i "foreground.*service\|service.*foreground" | grep -i weather | tail -10

echo ""
echo "To run live monitoring, use:"
echo "adb logcat | grep -i weather"
echo ""
echo "To test weather alarm manually:"
echo "1. Set a weather alarm in the app"
echo "2. Wait for it to trigger"
echo "3. Check logs with: adb logcat | grep -i weather"