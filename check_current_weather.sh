#!/bin/bash

# Quick Current Weather Check Script
echo "🌤️ Current Weather Detection Check"
echo "=================================="
echo ""
echo "This will show what weather the app would detect right now."
echo "Useful for debugging weather-based alarms."
echo ""

# Check if we have recent weather logs
echo "🔍 Checking recent weather detection logs..."
adb logcat -d | grep -E "(Weather.*Current weather|WeatherCondition.*current weather)" | tail -5

echo ""
echo "🌍 If no recent logs found, you can trigger a weather check by:"
echo "1. Creating a test alarm with weather condition enabled"
echo "2. Setting it to fire in 1-2 minutes"
echo "3. Waiting for it to trigger"
echo ""

# Check network connectivity
echo "📶 Network connectivity check:"
adb shell ping -c 1 api.open-meteo.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Can reach Open-Meteo API"
else
    echo "❌ Cannot reach Open-Meteo API - check internet connection"
fi

echo ""
echo "🔧 To see live weather detection, run: ./quick_weather_test.sh"
echo "" 