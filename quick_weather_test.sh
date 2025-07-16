#!/bin/bash

# Quick Weather Testing Helper Script

echo "🌤️ Weather Condition Testing - Log Monitor"
echo "=========================================="
echo ""
echo "This script will monitor weather condition logs in real-time."
echo "Keep this running while testing different weather conditions."
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

# Clear existing logs
echo "Clearing existing logs..."
adb logcat -c

echo "Starting log monitor for weather conditions..."
echo ""

# Monitor weather-specific logs with timestamps
adb logcat -v time WeatherFetcherService:D WeatherCondition:D Weather:D WeatherTypes:D WeatherMatch:D AlarmReceiver:D *:S 