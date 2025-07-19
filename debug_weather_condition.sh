#!/bin/bash

echo "=== Weather Condition Debug Script ==="
echo "This will help debug why weather conditions aren't matching"
echo ""

# Function to wait for user input
wait_for_input() {
    read -p "Press Enter to continue..."
}

echo "1. What weather does Google show for your location?"
read -p "Enter the weather condition (e.g., sunny, cloudy, rainy, windy, stormy): " google_weather
echo "   Google shows: $google_weather"

echo ""
echo "2. Set an alarm with weather condition option 1 and select '$google_weather'"
echo "   Then come back here and run the alarm test"
wait_for_input

echo ""
echo "3. Clearing logs and monitoring weather service..."
adb logcat -c

echo ""
echo "4. Monitoring weather API data and condition evaluation:"
echo "   Looking for actual API values vs expected conditions"
echo ""

# Monitor weather service logs
adb logcat | grep -E "WeatherFetcherService|WeatherCondition|Weather data|WeatherMatch" --line-buffered | while read line; do
    echo "[$(date '+%H:%M:%S')] $line"
done &

LOGCAT_PID=$!

echo "5. Trigger the alarm and watch the logs above"
echo "   Key things to check:"
echo "   - Weather data: rain=X, windSpeed=X, cloudCover=X"
echo "   - Current weather: (detected weather condition)"
echo "   - Selected Weather Types: (your selected condition)"
echo "   - Weather Matches Selection: (true/false)"
echo "   - RING_WHEN_MATCH: shouldRing = (true/false)"
echo ""
echo "Press Ctrl+C when done monitoring"

# Wait for Ctrl+C
trap "kill $LOGCAT_PID 2>/dev/null; echo ''; echo 'Analysis complete. Check the values above.'; exit" INT
wait