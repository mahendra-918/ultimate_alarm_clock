#!/bin/bash

# Quick Location Testing Helper Script

echo "🔍 Location Condition Testing - Log Monitor"
echo "==========================================="
echo ""
echo "This script will monitor location condition logs in real-time."
echo "Keep this running while testing different location conditions."
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

# Clear existing logs
echo "Clearing existing logs..."
adb logcat -c

echo "Starting log monitor for location conditions..."
echo ""

# Monitor location-specific logs with timestamps
adb logcat -v time LocationCondition:D AlarmReceiver:D Location:D *:S 