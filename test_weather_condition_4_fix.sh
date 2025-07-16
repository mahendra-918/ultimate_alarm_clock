#!/bin/bash

echo "🧪 Testing Weather Condition 4 (CANCEL_WHEN_DIFFERENT) Fix"
echo "============================================================"

echo "📱 Starting real-time log monitoring..."
adb logcat -c

echo "🎯 Testing Process:"
echo "1. Create alarm with weather condition 4 (CANCEL_WHEN_DIFFERENT)"
echo "2. Selected weather: Cloudy [1] (same as current weather)" 
echo "3. Expected result: Alarm should RING (weather is same, condition is CANCEL_WHEN_DIFFERENT)"
echo ""

echo "⏰ Please create an alarm for the next minute with:"
echo "   - Weather Condition: CANCEL_WHEN_DIFFERENT (4)"
echo "   - Weather Types: Cloudy [1]"
echo "   - Current weather: cloudy"
echo ""

echo "📊 Monitoring logs for:"
echo "   - Alarm scheduling success"
echo "   - AlarmReceiver firing"
echo "   - WeatherFetcherService execution"
echo "   - Weather condition evaluation"
echo ""

# Monitor logs in real-time for weather condition testing
adb logcat | grep -E "(flutter|AlarmReceiver|WeatherFetcher|WeatherCondition|MainActivity)" --line-buffered | while read line; do
    echo "$(date '+%H:%M:%S') | $line"
done 